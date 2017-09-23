package de.be.thaw.fragments;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.res.Configuration;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.RecyclerView;
import android.text.Html;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import java.io.IOException;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import de.be.thaw.R;
import de.be.thaw.auth.Auth;
import de.be.thaw.auth.Credential;
import de.be.thaw.auth.User;
import de.be.thaw.auth.exception.NoUserStoredException;
import de.be.thaw.cache.BoardUtil;
import de.be.thaw.model.noticeboard.BoardEntry;
import de.be.thaw.util.ThawUtil;
import de.be.thaw.connect.zpa.ZPAConnection;
import de.be.thaw.connect.parser.NoticeBoardParser;

public class NoticeBoardFragment extends Fragment implements MainFragment {

	private static final String TAG = "NoticeBoardFragment";

	/**
	 * Object containing the items for the list view.
	 */
	private ArrayAdapter<BoardEntry> boardAdapter;

	/**
	 * Layout responsible for pull to refresh.
	 */
	private SwipeRefreshLayout swipeContainer;

	public NoticeBoardFragment() {
		// Required empty public constructor
	}

	/**
	 * Use this factory method to create a new instance of
	 * this fragment using the provided parameters.
	 *
	 * @return
	 */
	public static NoticeBoardFragment newInstance() {
		NoticeBoardFragment fragment = new NoticeBoardFragment();

		return fragment;
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
	}

	@Override
	public boolean isRefreshable() {
		return true;
	}

	/**
	 * Refresh Fragment.
	 */
	public void refresh() {
		new GetNewsTask(getActivity()).execute();
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
	}


	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		// Inflate the layout for this fragment
		View view = inflater.inflate(R.layout.fragment_notice_board, container, false);

		boardAdapter = new BoardArrayAdapter(getActivity());

		// Initialize Views
		swipeContainer = (SwipeRefreshLayout) view.findViewById(R.id.boardlist_swipe_layout);
		swipeContainer.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {

			@Override
			public void onRefresh() {
				refresh();
			}

		});
		swipeContainer.setColorSchemeResources(android.R.color.holo_blue_bright,
				android.R.color.holo_green_light,
				android.R.color.holo_orange_light,
				android.R.color.holo_red_light);

		ListView boardList = (ListView) view.findViewById(R.id.boardlist);
		boardList.setAdapter(boardAdapter);

		// Initialize board list
		updateEntries(null);

		return view;
	}

	/**
	 * Update the boards entries.
	 *
	 * @param entries
	 */
	private void updateEntries(BoardEntry[] entries) {
		if (entries == null) { // Retrieve from Storage
			try {
				entries = BoardUtil.retrieve(getActivity());
			} catch (IOException e) {
				e.printStackTrace();
			}

			if (entries == null) { // When there are still no entries -> Update from Server
				refresh();
			}
		} else { // Store
			try {
				BoardUtil.store(entries, getActivity());
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		if (entries != null) {
			boardAdapter.clear();
			boardAdapter.addAll(entries);
		}
	}

	/**
	 * Async task to get all news.
	 */
	private class GetNewsTask extends AsyncTask<Void, Integer, BoardEntry[]> {

		private ProgressDialog progress;
		private Activity activity;
		private Exception e;

		public GetNewsTask(Activity activity) {
			this.activity = activity;

			progress = new ProgressDialog(activity);
			progress.setIndeterminate(true);
			progress.setMessage(activity.getResources().getString(R.string.searchingForBoardEntriesMessage));
		}

		@Override
		protected void onPreExecute() {
			super.onPreExecute();

			if (!swipeContainer.isRefreshing()) {
				progress.show();
			}
		}

		@Override
		protected BoardEntry[] doInBackground(Void... params) {
			User user = null;
			try {
				user = Auth.getInstance().getCurrentUser(getContext());
			} catch (NoUserStoredException e1) {
				this.e = e;
				return null;
			}

			Credential credential = user.getCredential();

			BoardEntry[] entries = null;
			try {
				ZPAConnection connection = new ZPAConnection(credential.getUsername(), credential.getPassword());
				entries = connection.getBoardNews();
			} catch (Exception e) {
				e.printStackTrace();
				this.e = e;
			}

			return entries;
		}

		@Override
		protected void onCancelled() {
			super.onCancelled();

			if (progress.isShowing()) {
				progress.dismiss();
			}

			swipeContainer.setRefreshing(false);
		}

		@Override
		protected void onPostExecute(BoardEntry[] boardEntries) {
			super.onPostExecute(boardEntries);

			if (progress.isShowing()) {
				progress.dismiss();
			}

			swipeContainer.setRefreshing(false);

			if (e != null) {
				new AlertDialog.Builder(activity).setMessage(activity.getResources().getString(R.string.boardEntrySearchError)).show();
			}

			if (boardEntries != null) {
				updateEntries(boardEntries);
			}
		}

	}

	/**
	 * Custom adapter to display board entries.
	 */
	private class BoardArrayAdapter extends ArrayAdapter<BoardEntry> {

		private final Context context;

		/**
		 * Cache parsed html contents in this map for a item position.
		 */
		private Map<Integer, Spanned> contentCache = new HashMap<>();

		public BoardArrayAdapter(Activity activity) {
			super(activity, -1);
			this.context = activity;
		}

		@NonNull
		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			ViewHolder holder = null;

			if (convertView == null) {
				holder = new ViewHolder();

				LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				convertView = inflater.inflate(R.layout.board_entry, parent, false);

				holder.authorView = (TextView) convertView.findViewById(R.id.entry_author);
				holder.titleView = (TextView) convertView.findViewById(R.id.entry_title);
				holder.fromView = (TextView) convertView.findViewById(R.id.entry_from);
				holder.toView = (TextView) convertView.findViewById(R.id.entry_to);
				holder.contentView = (TextView) convertView.findViewById(R.id.entry_content);

				convertView.setTag(holder);

				/*
				 * Make HTML links inside the TextView clickable.
				 */
				holder.contentView.setMovementMethod(LinkMovementMethod.getInstance());
			} else {
				holder = (ViewHolder) convertView.getTag();
			}

			// Set Contents
			final BoardEntry item = getItem(position);

			holder.authorView.setText(item.getAuthor());
			holder.titleView.setText(item.getTitle());

			holder.fromView.setText(NoticeBoardParser.DATE_PARSER.format(item.getFrom()));
			holder.toView.setText(NoticeBoardParser.DATE_PARSER.format(item.getTo()));

			Spanned content = contentCache.get(position);
			if (content == null) {
				content = ThawUtil.fromHTML(item.getContent());
				contentCache.put(position, content);
			}
			holder.contentView.setText(content);

			return convertView;
		}

		/**
		 * Clear cache.
		 */
		private void clearCache() {
			contentCache.clear();
		}

		@Override
		public void notifyDataSetChanged() {
			super.notifyDataSetChanged();

			clearCache();
		}

		/**
		 * View holder for a board entry.
		 */
		private class ViewHolder {

			TextView authorView;
			TextView titleView;
			TextView fromView;
			TextView toView;
			TextView contentView;

		}

	}

}
