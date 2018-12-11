package de.be.thaw.connect.parser.canteen;

import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.util.HashMap;
import java.util.Map;

import de.be.thaw.connect.parser.Parser;
import de.be.thaw.connect.parser.exception.ParseException;

/**
 * Parses the price table.
 */

public class PriceParser implements Parser<Document, Map<String, String>> {

    private static final String DISH_IDENTIFIER = "gericht";
    private static final String BIO_DISH = "Biogericht";
    private static final String SPECIAL_DISH = "Aktionsessen";

    @Override
    public Map<String, String> parse(Document toParse) throws ParseException {
        Map<String, String> prices = new HashMap<>();

        String type;
        String price;
        String nr;

        Elements elements = toParse.getElementsByTag("tr");
        for (Element row : elements) {
            type = row.child(0).text();
            if (type.contains(DISH_IDENTIFIER)) {
                price = row.child(1).text();
                if (type.startsWith("Bio")) {
                    nr = type.substring(type.lastIndexOf(" "));
                    prices.put(BIO_DISH + nr, price);
                    prices.put(SPECIAL_DISH + nr, price);
                } else {
                    prices.put(type, price);
                }
            }
        }
        return prices;
    }
}
