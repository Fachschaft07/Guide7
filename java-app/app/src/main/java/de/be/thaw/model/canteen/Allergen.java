package de.be.thaw.model.canteen;

/**
 * Enum containing all kinds of allergens.
 *
 * Created by Benjamin Eder on 18.03.2017.
 */
public enum Allergen {

	EGGS("Ei"),
	FISH("Fi"),
	GLUTEN("Gl"),

	/*
	 * Various kinds of grain
	 */
	WHEAT("GlW"), // Weizen
	RYE("GlR"), // Roggen
	BARLEY("GlG"), // Gerste
	OATS("GlH"), // Hafer
	DINKEL("GlD"), // Dinkel

	CRAB("Kr"),
	LUPIN("Lu"),
	MILK("Mi"),

	/**
	 * Various kinds of nuts
	 */
	NUTS("Sc"),
	PEANUTS("En"),
	ALMONDS("ScM"),
	HAZELNUTS("ScH"),
	WALNUTS("ScW"),
	CASHEW("ScC"),
	PISTACHIO("ScP"),

	SESAME_SEEDS("Se"),
	MUSTARD("Sf"),
	CELERY("Sl"),
	SOYBEANS("So"),
	SULPHUR_DIOXIDE("Sw"),
	MOLLUSCS("Wt"), // Weichtiere
	GARLIC("Kn"),
	ALCOHOL("99"),
	GELATIN("14"),
	GLAZING_WITH_CACAO("13");


	private final String abbreviation;

	Allergen(String abbreviation) {
		this.abbreviation = abbreviation;
	}

	public String getAbbreviation() {
		return abbreviation;
	}

	/**
	 * Get an Allergen by its abbreviation.
	 * @param abbreviation
	 * @return
	 */
	public static Allergen forAbbreviation(String abbreviation) {
		for (Allergen allergen : values()) {
			if (allergen.getAbbreviation().equals(abbreviation)) {
				return allergen;
			}
		}

		return null;
	}

}
