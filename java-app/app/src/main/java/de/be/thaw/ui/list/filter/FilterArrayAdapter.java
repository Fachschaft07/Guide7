package de.be.thaw.ui.list.filter;

import android.content.Context;
import android.support.annotation.NonNull;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import de.be.thaw.R;
import de.be.thaw.connect.parser.fk07.AppointmentsParser;
import de.be.thaw.fragments.AppointmentFragment;
import de.be.thaw.model.appointments.Appointment;
import de.be.thaw.util.ThawUtil;

/**
 * Filterable Array Adapter.
 * <p>
 * Created by Benjamin Eder on 08.10.2017.
 */
public abstract class FilterArrayAdapter<T> extends ArrayAdapter<T> implements Filterable {

	/**
	 * Context for the array adapter.
	 */
	protected final Context context;

	/**
	 * Model of the adapter.
	 */
	private List<T> model = new ArrayList<>();

	/**
	 * List where the filter mapping is stored.
	 * This is the filter mechanism essence.
	 */
	private List<Integer> filtered;

	/**
	 * AbstractFilter used to filter the model.
	 */
	private final Filter filter = new BasicFilter();

	/**
	 * Create new FilterArrayAdapter.
	 *
	 * @param context where the adapter should be deployed.
	 */
	public FilterArrayAdapter(Context context) {
		super(context, -1);

		this.context = context;
	}

	@Override
	public int getCount() {
		return filtered == null ? model.size() : filtered.size();
	}

	@Override
	public T getItem(int index) {
		return filtered == null ? model.get(index) : model.get(filtered.get(index));
	}

	@Override
	public long getItemId(int index) {
		return index;
	}

	@NonNull
	@Override
	public abstract View getView(int position, View convertView, ViewGroup parent);

	@NonNull
	@Override
	public Filter getFilter() {
		return filter;
	}

	/**
	 * Clear the Adapter model.
	 */
	public void clear() {
		model.clear();

		notifyDataSetChanged();
	}

	@Override
	public void addAll(@NonNull Collection<? extends T> collection) {
		model.addAll(collection);

		notifyDataSetChanged();
	}

	@Override
	public void addAll(T... items) {
		List<T> list = new ArrayList<>();
		for (T item : items) {
			list.add(item);
		}

		addAll(list);
	}

	/**
	 * Apply filter to model.
	 *
	 * @param item to check filter for
	 * @param filter to filter with
	 * @return whether the item applies to the filter
	 */
	public abstract boolean applyFilter(T item, String filter);

	/**
	 * Basic Filter used to filter the adapter.
	 */
	private class BasicFilter extends Filter {

		@Override
		protected FilterResults performFiltering(CharSequence constraint) {
			FilterResults results = new FilterResults();

			if (constraint == null && constraint.length() == 0) {
				results.count = 0;
				results.values = null;
			} else {
				String filter = constraint.toString().toLowerCase();
				List<Integer> filteredIndices = new ArrayList<>();

				for (int i = 0; i < model.size(); i++) {
					T item = model.get(i);

					if (applyFilter(item, filter)) {
						filteredIndices.add(i);
					}
				}

				results.count = filteredIndices.size();
				results.values = filteredIndices;
			}

			return results;
		}

		@Override
		protected void publishResults(CharSequence charSequence, FilterResults filterResults) {
			filtered = (List<Integer>) filterResults.values;
			notifyDataSetChanged();
		}

	}

}
