package de.be.thaw.model.canteen;

/**
 * Created by Benjamin Eder on 18.03.2017.
 */

public class Meal {

	private String name;

	private MealInfo mealInfo;

	private Allergen[] allergens;

	private String type;

	private String price;

	public Meal() {

	}

	public Meal(String name) {
		this.name = name;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public MealInfo getMealInfo() {
		return mealInfo;
	}

	public void setMealInfo(MealInfo mealInfo) {
		this.mealInfo = mealInfo;
	}

	public Allergen[] getAllergens() {
		return allergens;
	}

	public void setAllergens(Allergen[] allergens) {
		this.allergens = allergens;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getPrice() {
		return price != null && !price.isEmpty() ? price : "-,- €";
	}

	public void setPrice(String price) {
		this.price = price;
	}
}
