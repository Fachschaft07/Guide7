package de.be.thaw.ui.weekview;

import com.alamkanak.weekview.WeekViewEvent;
import com.alamkanak.weekview.WeekViewLoader;

import java.util.Calendar;
import java.util.List;

/**
 * A WeekViewLoader loading events weekly wise.
 *
 * Created by Benjamin Eder on 22.03.2017.
 */
public class WeeklyLoader implements WeekViewLoader {

	private WeekChangeListener weekChangeListener;

	public WeeklyLoader(WeekChangeListener listener) {
		this.weekChangeListener = listener;
	}

	@Override
	public double toWeekViewPeriodIndex(Calendar instance) {
		return instance.get(Calendar.YEAR) * 10000 + (instance.get(Calendar.MONTH) + 1) * 100 + instance.get(Calendar.WEEK_OF_YEAR);
	}

	@Override
	public List<? extends WeekViewEvent> onLoad(int periodIndex) {
		int year = periodIndex / 10000;

		int month = periodIndex % 10000 / 100;
		int week = periodIndex % 10000 % 100;
		return weekChangeListener.onWeekChange(year, month, week);
	}

	public WeekChangeListener getWeekChangeListener() {
		return weekChangeListener;
	}

	public void setWeekChangeListener(WeekChangeListener weekChangeListener) {
		this.weekChangeListener = weekChangeListener;
	}

	public interface WeekChangeListener {

		/**
		 * Method called when a new week has been reached without content!
		 * This should create new WeekEvents based on the current week.
		 *
		 * @param newYear
		 * @param newMonth
		 * @param newWeek
		 * @return
		 */
		List<? extends WeekViewEvent> onWeekChange(int newYear, int newMonth, int newWeek);

	}

}
