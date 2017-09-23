package de.be.thaw.connect.zpa;

import android.util.Log;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import net.fortuna.ical4j.data.CalendarBuilder;
import net.fortuna.ical4j.data.ParserException;
import net.fortuna.ical4j.model.Component;
import net.fortuna.ical4j.model.Property;

import org.jsoup.Connection;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.IOException;
import java.net.URL;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

import de.be.thaw.auth.User;
import de.be.thaw.connect.parser.exception.ParseException;
import de.be.thaw.model.freerooms.Room;
import de.be.thaw.model.noticeboard.BoardEntry;
import de.be.thaw.model.schedule.Schedule;
import de.be.thaw.model.schedule.ScheduleDay;
import de.be.thaw.connect.zpa.exception.CouldNotReceiveLoginErrorException;
import de.be.thaw.connect.zpa.exception.CouldNotReceiveMiddlewaretokenException;
import de.be.thaw.connect.zpa.exception.InvalidDateException;
import de.be.thaw.connect.zpa.exception.ZPABadCredentialsException;
import de.be.thaw.connect.zpa.exception.ZPALoginFailedException;
import de.be.thaw.connect.parser.NoticeBoardParser;
import de.be.thaw.connect.parser.WeekPlanParser;
import de.be.thaw.connect.parser.Parser;
import de.be.thaw.model.schedule.ScheduleItem;

public class ZPAConnection {

	/**
	 * Tag for logging.
	 */
	private static final String ZPA_CONNECTION_TAG = "ZPAConnection";

	/**
	 * URL to ZPA.
	 */
	private static final String ZPA_URL = "https://w3-o.cs.hm.edu:8000/";

	private static final String SESSION_ID_KEY = "csrftoken";

	/**
	 * Suffix for the login request.
	 */
	private static final String ZPA_LOGIN_SUFFIX = "login/";

	/**
	 * Suffix for the personal weekplan.
	 */
	public static final String ZPA_STUDENT_WEEKPLAN_SUFFIX = "student/week_plan/";

	/**
	 * Suffix for the schedule plan.
	 */
	public static final String ZPA_STUDENT_PLAN_SUFFIX = "student/plan/";

	/**
	 * Suffix for the public schedule plan.
	 */
	public static final String ZPA_STUDENT_PUBLIC_PLAN_SUFFIX = "student/public_plan/";

	/**
	 * Suffix for the personal notice board.
	 */
	public static final String ZPA_STUDENT_NOTICE_BOARD = "student/notice_board/";

	/**
	 * Suffix for the public notice board.
	 */
	public static final String ZPA_PUBLIC_NOTICE_BOARD = "public/notice_board/";

	/**
	 * ZPA Public Area prefix for fetching free rooms.
	 */
	public static final String ZPA_PUBLIC_FREE_ROOMS = "room_admin/get_free_rooms/";

	/**
	 * Where the free rooms can be viewed on ZPA.
	 */
	public static final String ZPA_PUBLIC_BOOKINGS = "public/bookings/";

	/**
	 * Middlewaretoken Input Elements Name.
	 */
	private static final String ZPA_MIDDLEWARETOKEN_NAME = "csrfmiddlewaretoken";

	/**
	 * Rss feed xml link type from html.
	 */
	private static final String LINK_TYPE_RSS_XML = "application/rss+xml";

	/**
	 * The "SessionId" of the ZPA Cookie
	 */
	private String sessionId;

	/**
	 * Connection to ZPA.
	 */
	private Connection connection;

	/**
	 * The latest middleware token.
	 */
	private String middlewaretoken;

	/**
	 * Create new ZPA Connection without login to only access the public area.
	 * To login anyway, just call <code>login(String, String)</code>.
	 */
	public ZPAConnection() {
		connection = getZPAConnection(ZPA_URL + ZPA_LOGIN_SUFFIX);
		// No login.
	}

	/**
	 * Create new ZPA Connection
	 *
	 * @param username
	 * @param password
	 */
	public ZPAConnection(String username, String password) throws ZPALoginFailedException, ZPABadCredentialsException {
		login(username, password); // Initially log into ZPA
	}

	/**
	 * Create new ZPA Connection and login using the passed user.
	 * The passed user will be filled with additional initial info if wished.
	 *
	 * @param user     the user to login with.
	 * @param fillUser fill the user object with additional info?
	 */
	public ZPAConnection(User user, boolean fillUser) throws ZPALoginFailedException, ZPABadCredentialsException {
		login(user, fillUser);
	}

	/**
	 * Login with the passed user.
	 *
	 * @param user     the user to log in with.
	 * @param fillUser whether to fill the passed user object with additional info.
	 * @throws ZPALoginFailedException
	 * @throws ZPABadCredentialsException
	 */
	private void login(User user, boolean fillUser) throws ZPALoginFailedException, ZPABadCredentialsException {
		Document doc = login(user.getCredential().getUsername(), user.getCredential().getPassword());

		if (fillUser) {
			fillUser(user, doc);
		}
	}

	/**
	 * Try to fill the user with info from the passed document.
	 *
	 * @param user
	 * @param doc
	 */
	private void fillUser(User user, Document doc) {
		// Parse name and group from zpa header.
		try {
			String headerText = doc.getElementsByClass("header").get(0).getElementsByClass("left").text();

			if (headerText != null && !headerText.isEmpty()) {
				String[] components = headerText.split(" ");

				String name = components[components.length - 3] + " " + components[components.length - 2];
				user.setName(name);

				String group = components[components.length - 1];
				group = group.substring(1, group.length() - 1);
				user.setGroup(group);
			}
		} catch (Exception e) {
			// Do nothing. This should not crash the application.
		}
	}

	/**
	 * Try to login into the ZPA.
	 *
	 * @param username
	 * @param password
	 * @return the document got for an successful login.
	 * @throws ZPALoginFailedException
	 */
	public Document login(String username, String password) throws ZPALoginFailedException, ZPABadCredentialsException {
		connection = getZPAConnection(ZPA_URL + ZPA_LOGIN_SUFFIX);

		Document doc = null;

		try {
			Connection.Response response = connection.execute();
			sessionId = response.cookie(SESSION_ID_KEY);

			connection.cookie(SESSION_ID_KEY, sessionId);

			middlewaretoken = getMiddleWareToken(connection);
			connection.data("csrfmiddlewaretoken", middlewaretoken);
			connection.data("username", username);
			connection.data("password", password);

			doc = connection.post();
			middlewaretoken = getMiddleWareToken(doc);
			String login = getLoginError(doc);

			int statusCode = connection.response().statusCode();
			if (statusCode != 200) {
				throw new ZPALoginFailedException("ZPA Login failed due to bad status code: " + statusCode);
			} else if (login != null) {
				throw new ZPABadCredentialsException();
			}
		} catch (Exception e) {
			Log.e(ZPA_CONNECTION_TAG, "ZPA Login failed.");
			throw new ZPALoginFailedException(e);
		}

		Log.i(ZPA_CONNECTION_TAG, "ZPA Login OK!");

		return doc;
	}

	/**
	 * Get a Connection Object.
	 *
	 * @param url
	 * @return
	 */
	private Connection getZPAConnection(String url) {
		Connection connection = Jsoup.connect(url)
				.userAgent("Mozilla/5.0 (Windows; U; WindowsNT 5.1; en-US; rv1.8.1.6) Gecko/20070725 Firefox/2.0.0.6")
				.referrer("http://www.google.com");

		if (sessionId != null) {
			connection.cookie(SESSION_ID_KEY, sessionId);
		}

		return connection;
	}

	/**
	 * Get all private board news.
	 *
	 * @return
	 */
	public BoardEntry[] getBoardNews() throws IOException, ParseException {
		return getBoardNews(true);
	}

	/**
	 * Get all notice board entries (Either personal entries or public ones).
	 * You need to be logged in for personal entries.
	 *
	 * @param personal Personal board entries or public ones?
	 * @return
	 */
	public BoardEntry[] getBoardNews(boolean personal) throws IOException, ParseException {
		Document doc = getZPAUrl(personal ? ZPA_STUDENT_NOTICE_BOARD : ZPA_PUBLIC_NOTICE_BOARD);

		Parser<Document, BoardEntry[]> parser = new NoticeBoardParser();
		return parser.parse(doc);
	}

	/**
	 * Get free rooms for the passed timespan.
	 * NOTICE: Date must be the same to work properly.
	 *
	 * @param start
	 * @param end
	 * @throws InvalidDateException, IOException, ParseException
	 */
	public Room[] getFreeRooms(Calendar start, Calendar end) throws InvalidDateException, IOException, ParseException {
		// Check if is same day, otherwise throw Exception.
		if (!(start.get(Calendar.YEAR) == end.get(Calendar.YEAR) && start.get(Calendar.DAY_OF_YEAR) == end.get(Calendar.DAY_OF_YEAR))) {
			throw new InvalidDateException("Start- and Enddate have to be essentially the same day for the free room search to work propertly.");
		}


		// Build Arguments for the Request
		String dateString = buildDateString(start.getTime(), new SimpleDateFormat("yyyy-MM-dd"));

		DateFormat timeFormatter = new SimpleDateFormat("HHmm");
		String startTimeString = timeFormatter.format(start.getTime());
		String endTimeString = timeFormatter.format(end.getTime());


		// Build request to ZPA Server and send it.
		Map<String, String> parameter = new HashMap<>();
		parameter.put("date", dateString);
		parameter.put("start_time", startTimeString);
		parameter.put("end_time", endTimeString);

		Connection.Response response = connection.url(ZPA_URL + ZPA_PUBLIC_FREE_ROOMS).data(parameter).execute();

		String result = response.body();

		// Turn Result to JSON Object
		ObjectMapper mapper = new ObjectMapper();
		JsonNode jsonRoot = mapper.readTree(result);

		if (jsonRoot == null || jsonRoot.get("error_code").asInt() != 0) {
			throw new ParseException("Could not parse free rooms.");
		}


		// Turn JSON into Room Objects
		List<Room> roomList = new ArrayList<>();

		Iterator<JsonNode> roomJsonIterator = jsonRoot.get("free_rooms").iterator();
		while (roomJsonIterator.hasNext()) {
			JsonNode roomJson = roomJsonIterator.next();

			roomList.add(new Room(roomJson.get(1).asText(), roomJson.get(2).asInt()));
		}

		return roomList.toArray(new Room[roomList.size()]);
	}

	/**
	 * Get weekplan from rss feed.
	 *
	 * @return the parsed schedule events
	 * @throws IOException in case something goes wrong during fetching.
	 */
	public List<ScheduleItem> getRSSWeekplan() throws IOException, ParseException {
		long timer = System.currentTimeMillis();

		List<ScheduleItem> result = getRSSWeekplan(fetchWeekplanRSSURL());
		Log.i(ZPA_CONNECTION_TAG, "Fetching weekplan RSS took " + (System.currentTimeMillis() - timer) + "ms");
		return result;
	}

	/**
	 * Get rss weekplan using the provided url.
	 *
	 * @param rssUrl url where to find the weekplan rss feed.
	 * @return the parsed schedule events
	 * @throws IOException in case something goes wrong during fetching.
	 */
	public List<ScheduleItem> getRSSWeekplan(URL rssUrl) throws IOException, ParseException {
		CalendarBuilder calendarBuilder = new CalendarBuilder();
		net.fortuna.ical4j.model.Calendar calendar = null;
		try {
			calendar = calendarBuilder.build(rssUrl.openStream());
		} catch (ParserException e) {
			throw new ParseException(e);
		}

		return new WeekPlanParser().parse(calendar);
	}

	/**
	 * Fetch weekplan RSS feed url from ZPA.
	 *
	 * @return the weekplans RSS feed url
	 */
	private URL fetchWeekplanRSSURL() throws IOException, ParseException {
		Document doc = getZPAUrl(ZPA_STUDENT_WEEKPLAN_SUFFIX);

		// Fetch rss feed url from document.
		Elements elms = doc.getElementsByAttributeValue("type", LINK_TYPE_RSS_XML);

		// Make sure its only one, otherwise just take the first (And hopefully be right about it).
		if (elms.isEmpty()) {
			throw new ParseException("Did not find any rss urls.");
		}
		Element link = elms.get(0);

		// Check if it's a link element which it must!
		if (!link.tagName().equalsIgnoreCase("a")) {
			throw new ParseException("Did not find a valid rss link.");
		}

		// Get rss feed url.
		String url = link.attr("href");

		// Check if valid url.
		if (url == null || url.isEmpty()) {
			throw new ParseException("Found rss url is invalid.");
		}

		return new URL(url);
	}

	/**
	 * Build a date string
	 *
	 * @param day
	 * @param month
	 * @param year
	 * @param formatter
	 * @return
	 */
	private String buildDateString(int day, int month, int year, DateFormat formatter) {
		Calendar cal = Calendar.getInstance();
		cal.set(year, month, day);

		return buildDateString(cal.getTime(), formatter);
	}

	/**
	 * Build a date string.
	 *
	 * @param date
	 * @param formatter
	 * @return
	 */
	private String buildDateString(Date date, DateFormat formatter) {
		return formatter.format(date);
	}

	/**
	 * Get a Document from the ZPA with the passed URL.
	 *
	 * @param suffix
	 * @return
	 * @throws IOException
	 */
	private Document getZPAUrl(String suffix) throws IOException {
		return connection.url(ZPA_URL + suffix).get();
	}

	/**
	 * Post something and get the returned Document
	 *
	 * @param suffix
	 * @param parameter
	 * @return
	 * @throws IOException
	 */
	public Document postZPAUrl(String suffix, Map<String, String> parameter) throws IOException {
		connection.url(ZPA_URL + suffix).data(parameter);

		if (middlewaretoken != null) {
			connection.data(ZPA_MIDDLEWARETOKEN_NAME, middlewaretoken);
		}

		Document doc = connection.post();

		updateMiddleWareToken(doc);

		return doc;
	}

	/**
	 * Update the Middle ware token.
	 *
	 * @param doc
	 */
	private void updateMiddleWareToken(Document doc) {
		try {
			middlewaretoken = getMiddleWareToken(doc);
		} catch (CouldNotReceiveMiddlewaretokenException e) {
			e.printStackTrace();
		}
	}

	/**
	 * Get Middleware Token from ZPA which is part of the login parameters.
	 *
	 * @param zpaConnection
	 * @return
	 * @throws CouldNotReceiveMiddlewaretokenException
	 */
	private String getMiddleWareToken(Connection zpaConnection) throws CouldNotReceiveMiddlewaretokenException {
		Document zpa;
		try {
			zpa = zpaConnection.get();
		} catch (IOException e) {
			throw new CouldNotReceiveMiddlewaretokenException(e);
		}

		return getMiddleWareToken(zpa);
	}

	/**
	 * Try to parse the Middleware token from ZPA Document.
	 *
	 * @param doc
	 * @return
	 * @throws CouldNotReceiveMiddlewaretokenException
	 */
	private String getMiddleWareToken(Document doc) throws CouldNotReceiveMiddlewaretokenException {
		Elements elements = doc.getElementsByAttributeValue("name", ZPA_MIDDLEWARETOKEN_NAME);
		if (elements.size() == 1) {
			return elements.get(0).attr("value");
		} else {
			throw new CouldNotReceiveMiddlewaretokenException("Failed to fetch Middleware by fetching all middleware input elements.");
		}
	}

	/**
	 * Try to parse the Middleware token from ZPA Document.
	 *
	 * @param doc
	 * @return
	 * @throws CouldNotReceiveLoginErrorException
	 */
	private String getLoginError(Document doc) throws CouldNotReceiveLoginErrorException {
		Elements elements = doc.getElementsByClass("error");

		if (elements.size() == 0) {
			return null;
		} else if (elements.size() == 1) {
			return elements.get(0).text();
		} else {
			throw new CouldNotReceiveLoginErrorException("Failed to fetch Login Error!");
		}
	}

}
