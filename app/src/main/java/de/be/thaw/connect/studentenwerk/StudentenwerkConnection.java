package de.be.thaw.connect.studentenwerk;

import org.jsoup.Connection;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

import java.io.IOException;

import de.be.thaw.connect.parser.canteen.CanteenMenuURLParser;
import de.be.thaw.connect.parser.canteen.MenuParser;
import de.be.thaw.connect.parser.exception.ParseException;
import de.be.thaw.model.canteen.Menu;

/**
 * Object use to get content from the Studentenwerk website.
 *
 * Created by Benjamin Eder on 18.03.2017.
 */
public class StudentenwerkConnection {

	/**
	 * URL to the root of the Studentenwerk Menu (per Location).
	 */
	private static final String MENU_ROOT = "http://www.studentenwerk-muenchen.de/mensa/speiseplan/";

	public StudentenwerkConnection() {

	}

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
	 * Get Menus for Lothstraße Canteen.
	 * @return
	 * @throws IOException
	 * @throws ParseException
	 */
	public Menu[] getMenus() throws IOException, ParseException {
		Connection connection = getConnection(MENU_ROOT);
		Document menuRoot = connection.get();

		// Get URL for Lothstraße Canteen.
		String url = new CanteenMenuURLParser().parse(menuRoot);

		connection = getConnection(url);
		Document menuDoc = connection.get();

		MenuParser parser = new MenuParser();
		return parser.parse(menuDoc);
	}

}
