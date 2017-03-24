package de.be.thaw.connect.zpa;

import android.util.Log;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.jsoup.Connection;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;

import java.io.IOException;
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

import de.be.thaw.connect.parser.exception.ParseException;
import de.be.thaw.connect.studentenwerk.StudentenwerkConnection;
import de.be.thaw.model.canteen.Menu;
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
	 * @param username
	 * @param password
	 */
	public ZPAConnection(String username, String password) throws ZPALoginFailedException, ZPABadCredentialsException {
		login(username, password); // Initially log into ZPA
	}

	/**
	 * Try to login into the ZPA.
	 *
	 * @param username
	 * @param password
	 * @throws ZPALoginFailedException
	 * @return
	 */
	public boolean login(String username, String password) throws ZPALoginFailedException, ZPABadCredentialsException {
		connection = getZPAConnection(ZPA_URL + ZPA_LOGIN_SUFFIX);

		try {
			Connection.Response response = connection.execute();
			sessionId = response.cookie(SESSION_ID_KEY);

			connection.cookie(SESSION_ID_KEY, sessionId);

			middlewaretoken = getMiddleWareToken(connection);
			connection.data("csrfmiddlewaretoken", middlewaretoken);
			connection.data("username", username);
			connection.data("password", password);

			Document doc = connection.post();
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
		return true;
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
	 * Get all valid notice board entries.
	 * @return
	 */
	public BoardEntry[] getBoardNews() throws IOException, ParseException {
		Document doc = connection.url(ZPA_URL + ZPA_PUBLIC_NOTICE_BOARD).get();

		Parser<BoardEntry[]> boardParser = new NoticeBoardParser();

		Menu[] menu = new StudentenwerkConnection().getMenus();

		return boardParser.parse(doc);
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
	 * Get ZPA Weekplan by date.
	 *
	 * @param date
	 * @return
	 * @throws IOException
	 */
	public Schedule getWeekplan(String date) throws ParseException, IOException {
		Map<String, String> parameter = new HashMap<>();
		parameter.put("date", date);

		Document weekplanHTML = postZPAUrl(ZPA_STUDENT_WEEKPLAN_SUFFIX, parameter);

		WeekPlanParser parser = new WeekPlanParser();
		return parser.parse(weekplanHTML);
	}

	/**
	 * Get Schedule for a week.
	 *
	 * @param year
	 * @param month
	 * @param week
	 * @return
	 * @throws IOException
	 */
	public Schedule getWeekplan(int year, int month, int week) throws ParseException, IOException {
		Calendar cal = Calendar.getInstance();
		cal.clear();
		cal.set(Calendar.YEAR, year);
		cal.set(Calendar.WEEK_OF_YEAR, week);

		return getWeekplan(buildDateString(cal.get(Calendar.DAY_OF_MONTH) + 1, month - 1, year, WeekPlanParser.DATE_PARSER));
	}

	/**
	 * Get the schedule of a whole month!
	 * @param month
	 * @param year
	 * @return
	 * @throws ExecutionException
	 * @throws InterruptedException
	 */
	public Schedule getMonthPlan(int month, int year) throws ParseException, IOException {
		int currentDay = 1;

		Calendar calendar = Calendar.getInstance();
		calendar.set(year, month - 1, currentDay); // Month is zero based

		// Get the number of days in that month
		int daysInMonth = calendar.getActualMaximum(Calendar.DAY_OF_MONTH);

		ScheduleDay[] days = new ScheduleDay[daysInMonth];
		int dayIndex = 0;

		while (currentDay <= daysInMonth) {
			calendar.set(year, month - 1, currentDay);

			if (calendar.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY) {
				currentDay++;
			}

			Schedule currentWeek = getWeekplan(buildDateString(currentDay, month - 1, year, WeekPlanParser.DATE_PARSER));

			if (currentWeek != null) {
				// Add ScheduleDays until the daysInMonth is reached.
				for (ScheduleDay day : currentWeek.getWeekdays()) {
					calendar.setTime(day.getDate());
					int m = calendar.get(Calendar.MONTH);
					if (m == (month - 1)) {
						if (dayIndex < daysInMonth) {
							days[dayIndex] = day;
							dayIndex++;
							currentDay++;
						} else {
							break;
						}
					}
				}
			} else {
				break;
			}
		}

		return new Schedule(days);
	}

	/**
	 * Build a date string
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
	 * @param parameter
	 * @return
	 * @throws IOException
	 */
	public Document getZPAUrl(String suffix, Map<String, String> parameter) throws IOException {
		Document doc = connection.url(ZPA_URL + suffix).data(parameter).get();

		updateMiddleWareToken(doc);

		return doc;
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
