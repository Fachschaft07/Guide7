package de.be.thaw.connect.fk07;

import org.jsoup.Connection;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

import java.io.IOException;

import de.be.thaw.connect.parser.Parser;
import de.be.thaw.connect.parser.canteen.CanteenMenuURLParser;
import de.be.thaw.connect.parser.canteen.MenuParser;
import de.be.thaw.connect.parser.exception.ParseException;
import de.be.thaw.connect.parser.fk07.AppointmentsParser;
import de.be.thaw.connect.parser.fk07.PortraitParser;
import de.be.thaw.model.appointments.Appointment;
import de.be.thaw.model.canteen.Menu;
import de.be.thaw.model.noticeboard.Portrait;

/**
 * Object use to get content from the fk07 website.
 */
public class FK07Connection {

	/**
	 * URL to appointments section.
	 */
	private static final String APPOINTMENTS_URL = "http://www.cs.hm.edu/aktuelles/termine/";

	/**
	 * URL for the staff register of fk 07.
	 */
	private static final String STAFF_AZ_URL = "http://www.cs.hm.edu/die_fakultaet/ansprechpartner/personenaz_1/";

	/**
	 * Get a Connection Object.
	 *
	 * @param url
	 * @return
	 */
	private Connection getConnection(String url) {
		return Jsoup.connect(url)
				.userAgent("Mozilla/5.0 (Windows; U; WindowsNT 5.1; en-US; rv1.8.1.6) Gecko/20070725 Firefox/2.0.0.6")
				.referrer("http://www.google.com");
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

	/**
	 * Try to get portrait for staff member of FK07.
	 *
	 * @param surname   of the employee to find a portrait for
	 * @param givenName of the employee to find a portrait for
	 * @return the image as byte array or <code>null</code> if not found
	 */
	public Portrait getStaffPortrait(String surname, String givenName) throws IOException, ParseException {
		if (surname != null && !surname.isEmpty()) {
			Connection con = getConnection(STAFF_AZ_URL + surname.toLowerCase().charAt(0) + ".de.html");
			Document doc = con.get();

			Parser<Document, Portrait> parser = new PortraitParser(surname, givenName);

			return parser.parse(doc);
		}

		return null;
	}

}
