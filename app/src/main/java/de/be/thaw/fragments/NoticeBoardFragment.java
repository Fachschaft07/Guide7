package de.be.thaw.fragments;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.res.Configuration;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import java.io.IOException;

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

		public BoardArrayAdapter(Activity activity) {
			super(activity, -1);
			this.context = activity;
		}

		@NonNull
		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			View view = inflater.inflate(R.layout.board_entry, parent, false);

			TextView authorView = (TextView) view.findViewById(R.id.entry_author);
			TextView titleView = (TextView) view.findViewById(R.id.entry_title);
			TextView fromView = (TextView) view.findViewById(R.id.entry_from);
			TextView toView = (TextView) view.findViewById(R.id.entry_to);
			TextView contentView = (TextView) view.findViewById(R.id.entry_content);

			// Set Contents
			final BoardEntry item = getItem(position);

			authorView.setText(item.getAuthor());
			titleView.setText(item.getTitle());

			fromView.setText(NoticeBoardParser.DATE_PARSER.format(item.getFrom()));
			toView.setText(NoticeBoardParser.DATE_PARSER.format(item.getTo()));

			contentView.setText(ThawUtil.fromHTML(item.getContent()));

			return view;
		}
	}

}
