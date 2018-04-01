package de.be.thaw.fragments;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.res.Configuration;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AlertDialog;
import android.text.Editable;
import android.text.Spanned;
import android.text.TextWatcher;
import android.text.method.LinkMovementMethod;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import com.mikhaellopez.circularimageview.CircularImageView;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import de.be.thaw.R;
import de.be.thaw.auth.Auth;
import de.be.thaw.auth.Credential;
import de.be.thaw.auth.User;
import de.be.thaw.auth.exception.NoUserStoredException;
import de.be.thaw.storage.cache.BoardUtil;
import de.be.thaw.storage.cache.PortraitUtil;
import de.be.thaw.connect.fk07.FK07Connection;
import de.be.thaw.model.noticeboard.BoardEntry;
import de.be.thaw.model.noticeboard.Portrait;
import de.be.thaw.ui.list.filter.FilterArrayAdapter;
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
	 * Layout responsible for pull to onRefresh.
	 */
	private SwipeRefreshLayout swipeContainer;

	/**
	 * TextField used to filter.
	 */
	private EditText filterField;

	/**
	 * Map containing all portraits.
	 */
	private Map<Integer, Portrait> portraitMap = new HashMap<>();

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

	@Override
	public boolean isAddable() {
		return false;
	}

	/**
	 * Refresh Fragment.
	 */
	public void onRefresh() {
		new GetNewsTask(getActivity()).execute();
	}

	@Override
	public void onAdd() {
		// Do nothing
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
				NoticeBoardFragment.this.onRefresh();
			}

		});
		swipeContainer.setColorSchemeResources(android.R.color.holo_blue_bright,
				android.R.color.holo_green_light,
				android.R.color.holo_orange_light,
				android.R.color.holo_red_light);

		ListView boardList = (ListView) view.findViewById(R.id.boardlist);
		boardList.setAdapter(boardAdapter);

		final Button resetFilterButton = (Button) view.findViewById(R.id.notice_board_filter_remove);
		resetFilterButton.setVisibility(Button.INVISIBLE);
		resetFilterButton.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View view) {
				onResetFilter(view);
			}

		});

		filterField = (EditText) view.findViewById(R.id.notice_board_filter);
		filterField.addTextChangedListener(new TextWatcher() {

			@Override
			public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

			}

			@Override
			public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
				boardAdapter.getFilter().filter(charSequence);

				resetFilterButton.setVisibility(charSequence != null && charSequence.length() > 0 ? Button.VISIBLE : Button.INVISIBLE);
			}

			@Override
			public void afterTextChanged(Editable editable) {

			}

		});

		// Initialize board list
		updateEntries(null);

		return view;
	}

	/**
	 * Reset the filter.
	 *
	 * @param view
	 */
	public void onResetFilter(View view) {
		filterField.setText("");
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
				onRefresh();
			} else {
				// Load author portraits from storage.
				portraitMap.clear();
				for (BoardEntry entry : entries) {
					try {
						Portrait portrait = PortraitUtil.retrieve(getActivity(), entry.getPortraitId());

						if (portrait != null) {
							portraitMap.put(portrait.getId(), portrait);
						}
					} catch (IOException e) {
						e.printStackTrace();
					}
				}
			}
		} else { // Store
			try {
				BoardUtil.store(entries, getActivity());
			} catch (IOException e) {
				e.printStackTrace();
			}

			// Store portraits
			for (Portrait portrait : portraitMap.values()) {
				try {
					PortraitUtil.store(portrait, getActivity());
				} catch (IOException e) {
					e.printStackTrace();
				}
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
			User user;
			try {
				user = Auth.getInstance().getCurrentUser(getContext());
			} catch (NoUserStoredException e1) {
				this.e = e1;
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

			// Fetch portraits
			portraitMap.clear();
			if (entries != null) {
				// Fetch distinct author names
				Map<String, List<BoardEntry>> distinctAuthorEntries = new HashMap<>();
				for (BoardEntry entry : entries) {
					List<BoardEntry> l = distinctAuthorEntries.get(entry.getAuthor());

					if (l == null) {
						l = new ArrayList<>();
						distinctAuthorEntries.put(entry.getAuthor(), l);
					}

					l.add(entry);
				}

				int i = 0;
				for (Map.Entry<String, List<BoardEntry>> e : distinctAuthorEntries.entrySet()) {
					String[] nameParts = e.getKey().split(",");
					String surname = nameParts[0];
					String firstName = nameParts[1].trim().charAt(0) + "";

					FK07Connection con = new FK07Connection();
					try {
						Portrait portrait = con.getStaffPortrait(surname, firstName);

						if (portrait != null) {
							portrait.setId(i++);
							portraitMap.put(portrait.getId(), portrait);

							for (BoardEntry boardEntry : e.getValue()) {
								boardEntry.setPortraitId(portrait.getId());
							}
						}
					} catch (Exception exc) {
						exc.printStackTrace();
						this.e = exc;
					}
				}
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
	private class BoardArrayAdapter extends FilterArrayAdapter<BoardEntry> {

		/**
		 * Cache parsed html contents in this map for a item position.
		 */
		private Map<Integer, Spanned> contentCache = new HashMap<>();

		public BoardArrayAdapter(Activity activity) {
			super(activity);
		}

		@NonNull
		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			ViewHolder holder = null;

			if (convertView == null) {
				holder = new ViewHolder();

				LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				convertView = inflater.inflate(R.layout.board_entry, parent, false);

				holder.authorView = convertView.findViewById(R.id.entry_author);
				holder.titleView = convertView.findViewById(R.id.entry_title);
				holder.fromView = convertView.findViewById(R.id.entry_from);
				holder.toView = convertView.findViewById(R.id.entry_to);
				holder.contentView = convertView.findViewById(R.id.entry_content);
				holder.imageView = convertView.findViewById(R.id.image_test);

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

			Portrait p = portraitMap.get(item.getPortraitId());
			if (p != null) {
				ByteArrayInputStream bais = new ByteArrayInputStream(p.getData());
				Drawable drawable = Drawable.createFromStream(bais, "");
				holder.imageView.setImageDrawable(drawable);
			} else {
				holder.imageView.setImageResource(R.drawable.prof_avatar);
			}

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

		@Override
		public boolean applyFilter(BoardEntry item, String filter) {
			return item.getContent().toLowerCase().contains(filter) || item.getTitle().toLowerCase().contains(filter) || item.getAuthor().toLowerCase().contains(filter);
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
			CircularImageView imageView;

		}

	}

}
