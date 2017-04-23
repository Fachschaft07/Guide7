package de.be.thaw.connect.fk07;

import org.jsoup.Connection;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

import java.io.IOException;

import de.be.thaw.connect.parser.canteen.CanteenMenuURLParser;
import de.be.thaw.connect.parser.canteen.MenuParser;
import de.be.thaw.connect.parser.exception.ParseException;
import de.be.thaw.connect.parser.fk07.AppointmentsParser;
import de.be.thaw.model.appointments.Appointment;
import de.be.thaw.model.canteen.Menu;

/**
 * Object use to get content from the fk07 website.
 */
public class FK07Connection {

	/**
	 * URL to appointments section.
	 */
	private static final String APPOINTMENTS_URL = "http://www.cs.hm.edu/aktuelles/termine/";

	/**
	 * Get a Connection Object.
	 *
	 * @param url
	 * @return
	 */
	private Connection getConnection(String url) {
		Connection connection = Jsoup.connect(url)
				.userAgent("Mozilla/5.0 (Windows; U; WindowsNT 5.1; en-US; rv1.8.1.6) Gecko/20070725 Firefox/2.0.0.6")
				.referrer("http://www.google.com");

		return connection;
	}

	/**
	 * Get appointments from the fk07 website.
	 *
	 * @return
	 * @throws IOException
	 * @throws ParseException
	 */
	public Appointment[] getAppointments() throws IOException, ParseException {
		Connection connection = getConnection(APPOINTMENTS_URL);
		Document doc = connection.get();

		AppointmentsParser parser = new AppointmentsParser();
		return parser.parse(doc);
	}

}
