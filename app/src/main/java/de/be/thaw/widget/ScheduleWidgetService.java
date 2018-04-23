package de.be.thaw.widget;

import android.app.Application;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;

import java.io.IOException;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import de.be.thaw.R;
import de.be.thaw.model.schedule.ScheduleItem;
import de.be.thaw.model.schedule.custom.CustomScheduleItem;
import de.be.thaw.storage.CustomEntryUtil;
import de.be.thaw.storage.cache.ScheduleUtil;
import de.be.thaw.util.job.jobs.UpdateScheduleWidget;

/**
 * Created by GN on 2018-04-15.
 */

public class ScheduleWidgetService extends RemoteViewsService {
	@Override
	public RemoteViewsFactory onGetViewFactory(Intent intent) {
		return new ScheduleRemoteViewsFactory(this.getApplicationContext());
	}

	/**
	 * Notifying widgets of charged data set.
	 */
	public static void notifyDataChanged(Context context) {
		Intent intent = new Intent(context, ScheduleWidgetProvider.class);
		intent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
		String s = context.getPackageName();
		int[] ids = AppWidgetManager.getInstance(context)
				.getAppWidgetIds(new ComponentName("de.be.thaw", "de.be.thaw.widget.ScheduleWidgetProvider"));
		intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids);
		context.sendBroadcast(intent);
	}
}

class ScheduleRemoteViewsFactory implements RemoteViewsService.RemoteViewsFactory {

	private final Context context;

	private List<ScheduleItem> nextEvents = new ArrayList<>();

	ScheduleRemoteViewsFactory(Context context) {
		this.context = context;
	}

	@Override
	public void onCreate() {

	}

	@Override
	public void onDataSetChanged() {
		List<ScheduleItem> items;
		try {
			items = ScheduleUtil.retrieve(context);
			List<CustomScheduleItem> list = CustomEntryUtil.retrieve(context);
			items.addAll(list);
		} catch (IOException e) {
			e.printStackTrace();
			return;
		}

		setNextEvents(items);


		if (!items.isEmpty()) {
			UpdateScheduleWidget.scheduleJob(nextEvents.get(0).getEnd().getTime() -
					Calendar.getInstance().getTimeInMillis());
		}
	}

	/**
	 * Sets the nextEvents variable to the next group of upcoming events that occur on the same day.
	 * @param items List of events to search in
	 */
	private void setNextEvents(List<ScheduleItem> items) {
		nextEvents.clear();
		ScheduleItem nextEvent = getNextEvent(items);

		if (nextEvent != null) {
			nextEvents.addAll(getItemsOnSameDayAfter(items, nextEvent.getStart()));
		}

		Collections.sort(nextEvents, new Comparator<ScheduleItem>() {
			@Override
			public int compare(ScheduleItem o1, ScheduleItem o2) {
				if (o1.getStart().before(o2.getStart())) {
					return -1;
				} else if(o1.getStart().after(o2.getStart())) {
					return 1;
				}
				return 0;
			}
		});
	}

	/**
	 * Gets the current or next event.
	 * @param items List oy items to search in.
	 * @return
	 */
	private ScheduleItem getNextEvent(List<ScheduleItem> items) {
		Calendar cal = Calendar.getInstance();
		Calendar eventCal = Calendar.getInstance();
		ScheduleItem nextEvent = null;
		if (items != null) {
			long difference = Long.MAX_VALUE;

			for (ScheduleItem item : items) {
				eventCal.setTime(item.getStart());

				long newDiff = eventCal.getTimeInMillis() - cal.getTimeInMillis();
				if (newDiff < 0) {
					eventCal.setTime(item.getEnd());
					if (cal.before(eventCal)) {
						nextEvent = item;
						break;
					}
				} else if(newDiff < difference) {
					difference = newDiff;
					nextEvent = item;
				}
			}
		}

		return nextEvent;
	}

	/**
	 * Gets all items, that are after the specified date on the same day.
	 * @param items List of items, to look in
	 * @param day Specified date and time
	 * @return List of events on the same day after the specified date.
	 */
	private List<ScheduleItem> getItemsOnSameDayAfter(List<ScheduleItem> items, Date day) {
		Calendar reference = Calendar.getInstance();
		reference.setTime(day);

		Calendar test = Calendar.getInstance();

		List<ScheduleItem> afterItems = new ArrayList<>();

		for (ScheduleItem item : items) {
			test.setTime(item.getStart());
			if (reference.get(Calendar.YEAR) == test.get(Calendar.YEAR) &&
					reference.get(Calendar.DAY_OF_YEAR) == test.get(Calendar.DAY_OF_YEAR) &&
					!test.before(reference)) {
				afterItems.add(item);
			}
		}

		return afterItems;
	}

	@Override
	public void onDestroy() {

	}

	@Override
	public int getCount() {
		return nextEvents.size();
	}

	@Override
	public RemoteViews getViewAt(int position) {

		RemoteViews rv;
		if (position == 0) {
			rv = new RemoteViews(context.getPackageName(), R.layout.widget_scrhedule_top_entry);
			rv.setTextViewText(R.id.next_date, dateDescriptionDecider(nextEvents.get(position).getStart()));
		} else {
			rv = new RemoteViews(context.getPackageName(), R.layout.widget_schedule_entry);
		}

		populateView(rv, nextEvents.get(position));

		return rv;
	}

	/**
	 * Sets the TextViews for the views.
	 * @param rv view with the textViews
	 * @param item contains the values to set
	 */
	private void populateView(RemoteViews rv, ScheduleItem item) {
		rv.setTextViewText(R.id.next_title, item.getTitle());
		rv.setTextViewText(R.id.next_location, item.getLocation());
		rv.setTextViewText(R.id.next_time, createTimeString(item.getStart(), item.getEnd()));
	}

	/**
	 * Sets the date textView appropriately to today, tomorrow or the date.
	 * @param date date of the first event
	 * @return string with today, tomorrow or the date
	 */
	private String dateDescriptionDecider(Date date) {
		String value;
		Calendar current = Calendar.getInstance();
		Calendar check = Calendar.getInstance();
		check.setTime(date);

		if (current.get(Calendar.YEAR) == check.get(Calendar.YEAR) &&
				current.get(Calendar.DAY_OF_YEAR) == check.get(Calendar.DAY_OF_YEAR)) {
			value = context.getResources().getString(R.string.schedule_widget_today);
		} else {
			current.add(Calendar.DAY_OF_YEAR, 1);
			if (current.get(Calendar.YEAR) == check.get(Calendar.YEAR) &&
					current.get(Calendar.DAY_OF_YEAR) == check.get(Calendar.DAY_OF_YEAR)) {
				value = context.getResources().getString(R.string.schedule_widget_tomorrow);
			} else {
				value = DateFormat.getDateInstance().format(date);
			}
		}

		return value;
	}

	private String createTimeString(Date start, Date end) {
		return String.format("%s - %s", formatTime(start), formatTime(end));
	}

	private String formatTime(Date date) {
		return String.format(Locale.GERMAN, "%02d:%02d", date.getHours(), date.getMinutes());
	}

	@Override
	public RemoteViews getLoadingView() {
		return null;
	}

	@Override
	public int getViewTypeCount() {
		return 2;
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public boolean hasStableIds() {
		return false;
	}
}
