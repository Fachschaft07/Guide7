package de.be.thaw.connect.parser.fk07;

import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.MalformedURLException;
import java.net.URL;

import de.be.thaw.connect.parser.Parser;
import de.be.thaw.connect.parser.exception.ParseException;
import de.be.thaw.model.noticeboard.Portrait;

/**
 * Created by barny on 18.02.2018.
 */
public class PortraitParser implements Parser<Document, Portrait> {

	private final String surname;
	private final String givenName;

	public PortraitParser(String surname, String givenName) {
		this.surname = surname;
		this.givenName = givenName;
	}

	@Override
	public Portrait parse(Document toParse) throws ParseException {
		Elements elements = toParse.getElementsByClass("contact-person-list");

		for (Element e : elements) {
			String name = getName(e);

			if (name != null) {
				String[] nameParts = name.split(" ");
				String firstName = nameParts[nameParts.length - 2];
				String lastName = nameParts[nameParts.length - 1];

				if (firstName.contains(givenName) && lastName.contains(surname)) {
					try {
						Portrait portrait = new Portrait();
						portrait.setId(-1);
						portrait.setData(getImage(e));

						return portrait;
					} catch (ParseException exc) {
						break;
					}
				}
			}
		}

		return null;
	}

	private byte[] getImage(Element e) throws ParseException {
		// Get image url
		Elements images = e.getElementsByTag("img");

		if (images != null && !images.isEmpty()) {
			Element image = images.get(0);
			String src = image.attr("src");

			URL url = null;
			try {
				url = new URL(src);
			} catch (MalformedURLException e1) {
				throw new ParseException(e1);
			}

			try {
				BufferedInputStream bis = new BufferedInputStream(url.openStream());
				ByteArrayOutputStream baos = new ByteArrayOutputStream();

				int b;
				while ((b = bis.read()) != -1) {
					baos.write(b);
				}

				bis.close();
				baos.close();

				return baos.toByteArray();
			} catch (IOException e1) {
				throw new ParseException(e1);
			}
		}

		return null;
	}

	private String getName(Element e) {
		Elements images = e.getElementsByTag("img");

		if (images != null && !images.isEmpty()) {
			Element image = images.get(0);
			return image.attr("alt");
		}

		return null;
	}

}
