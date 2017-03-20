package de.be.thaw.connect.parser.canteen;

import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.parser.Tag;
import org.jsoup.select.Elements;

import de.be.thaw.connect.parser.Parser;
import de.be.thaw.connect.parser.exception.ParseException;

/**
 * Parser used to parse the URL for Lothstraße Canteen.
 *
 * Created by Benjamin Eder on 18.03.2017.
 */
public class CanteenMenuURLParser implements Parser<String> {

	@Override
	public String parse(Document doc) throws ParseException {
		Elements elements = doc.getElementsByClass("js-speiseplaene-liste");

		for (Element element : elements.get(0).children()) {
			if (element.text().contains("Mensa Lothstraße")) {
				if (element.tagName().equalsIgnoreCase("a") && element.hasAttr("href")) {
					return "http://www.studentenwerk-muenchen.de" + element.attr("href");
				}
			}
		}

		throw new ParseException("Could not fetch the URL for Lothstraße Canteen.");
	}

}
