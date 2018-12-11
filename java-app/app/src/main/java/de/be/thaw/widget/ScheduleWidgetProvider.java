package de.be.thaw.widget;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.widget.RemoteViews;

import de.be.thaw.R;

/**
 * WidgetProvider for the schedule widget
 */

public class ScheduleWidgetProvider extends AppWidgetProvider {
	@Override
	public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
		super.onUpdate(context, appWidgetManager, appWidgetIds);
		for (int widget : appWidgetIds) {
			Intent intent = new Intent(context, ScheduleWidgetService.class);
			intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widget);
			intent.setData(Uri.parse(intent.toUri(Intent.URI_INTENT_SCHEME)));

			RemoteViews rv = new RemoteViews(context.getPackageName(), R.layout.widget_schedule);

			rv.setRemoteAdapter(widget, R.id.widget_schedule_view, intent);

			rv.setEmptyView(R.id.widget_schedule_view, R.id.widget_schedule_view);

			appWidgetManager.notifyAppWidgetViewDataChanged(widget, R.id.widget_schedule_view);
			appWidgetManager.updateAppWidget(widget, rv);
		}
	}
}
