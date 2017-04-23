package de.be.thaw.connect.parser.fk07;

import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import de.be.thaw.connect.parser.Parser;
import de.be.thaw.connect.parser.exception.ParseException;
import de.be.thaw.model.appointments.Appointment;
import de.be.thaw.model.canteen.Allergen;
import de.be.thaw.model.canteen.Meal;
import de.be.thaw.model.canteen.MealInfo;
import de.be.thaw.model.canteen.Menu;

/**
 * Created by Benjamin Eder on 18.03.2017.
 */
public class AppointmentsParser implements Parser<Appointment[]> {

	private static final String CONTENT_TABLE_CLASS = "table-faculty-seven";

	public static final DateFormat MONTH_YEAR_FORMAT = new SimpleDateFormat("MMM yyyy");

	@Override
	public Appointment[] parse(Document doc) throws ParseException {
		List<Appointment> appointmentList = new ArrayList<>();

		for (Element monthTable : doc.getElementsByClass(CONTENT_TABLE_CLASS)) {
			Elements rowElements = monthTable.getElementsByTag("TR");

			if (rowElements != null && !rowElements.isEmpty()) {
				// Get Month from first row.
				Calendar cal = Calendar.getInstance();

				try {
					cal.setTime(MONTH_YEAR_FORMAT.parse(rowElements.get(0).text()));
				} catch (java.text.ParseException e) {
					throw new ParseException(e);
				}

				for (int i = 1; i < rowElements.size(); i++) {
					Element row = rowElements.get(i);

					if (row.childNodeSize() == 2) {
						Element timeSpanTD = row.children().get(0);
						Element descriptionTD = row.children().get(1);

						appointmentList.add(new Appointment(cal, timeSpanTD.text(), descriptionTD.text()));
					}
				}
			}
		}

		return appointmentList.toArray(new Appointment[appointmentList.size()]);
	}

}
