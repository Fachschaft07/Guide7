package de.be.thaw.connect.parser.canteen;

import android.util.Log;

import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import de.be.thaw.connect.parser.Parser;
import de.be.thaw.connect.parser.exception.ParseException;
import de.be.thaw.model.canteen.Allergen;
import de.be.thaw.model.canteen.Meal;
import de.be.thaw.model.canteen.MealInfo;
import de.be.thaw.model.canteen.Menu;

/**
 * Created by Benjamin Eder on 18.03.2017.
 */

public class MenuParser implements Parser<Menu[]> {

	public static final DateFormat DATE_FORMAT = new SimpleDateFormat("EEEE, dd.MM.yyyy");

	@Override
	public Menu[] parse(Document doc) throws ParseException {
		Elements elements = doc.getElementsByClass("c-schedule__item"); // Get all menu elements

		List<Menu> menus = new ArrayList<>();
		for (Element element : elements) {
			// Get Headline containing the menus date.
			Elements headlineElements = element.getElementsByClass("c-schedule__header");
			Element headlineElm = null;
			for (Element headlineElement : headlineElements) {
				if (headlineElement.childNodeSize() > 0) {
					headlineElm = headlineElement;
					break;
				}
			}

			// Parse date of menu
			String headline = headlineElm.children().get(0).text();
			Date date = null;
			try {
				date = DATE_FORMAT.parse(headline);
			} catch (java.text.ParseException e) {
				throw new ParseException(e);
			}


			// Parse Meals
			Elements mealElements = element.getElementsByClass("c-schedule__description");

			List<Meal> meals = new ArrayList<>();
			for (Element mealElement : mealElements) {
				String name = mealElement.text();

				if (name == null || name.isEmpty()) {
					throw new ParseException("Meal name cannot be empty.");
				}

				Elements meatlessElements = mealElement.getElementsByClass("fleischlos");
				Elements veganElements = mealElement.getElementsByClass("vegan");

				// Parse MealInfo
				MealInfo mealInfo = null;
				if (veganElements != null && !veganElements.isEmpty()) {
					mealInfo = MealInfo.VEGAN;
				} else if (meatlessElements != null && !meatlessElements.isEmpty()) {
					mealInfo = MealInfo.MEATLESS;
				} else {
					mealInfo = MealInfo.MEAT;
				}

				// Parse Allergens
				List<Allergen> allergens = new ArrayList<>();
				int start = name.indexOf('[');
				if (start != -1) {
					int end = name.indexOf(']', start);

					if (end != -1) {
						try {
							String allergensString = name.substring(start + 1, end);
							if (!allergensString.isEmpty()) {
								String[] allergenAbbreviations = allergensString.split(",");

								for (String allergenAbbreviation : allergenAbbreviations) {
									Allergen allergen = Allergen.forAbbreviation(allergenAbbreviation);

									if (allergen != null) {
										allergens.add(allergen);
									}
								}
							}
						} catch (Exception e) {
							throw new ParseException("An error occurred while parsing allergens.");
						}
					}
				}


				// Shorten Name
				if (start != -1) {
					name = name.substring(0, start);
				}

				Meal meal = new Meal(name);
				meal.setMealInfo(mealInfo);
				meal.setAllergens(allergens.toArray(new Allergen[allergens.size()]));
				meals.add(meal);
			}


			Menu menu = new Menu(date, meals.toArray(new Meal[meals.size()]));
			menus.add(menu);
		}

		return menus.toArray(new Menu[menus.size()]);
	}

}
