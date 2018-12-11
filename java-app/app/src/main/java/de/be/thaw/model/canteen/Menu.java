package de.be.thaw.model.canteen;

import java.util.Date;

/**
 * Menu Object containing the date and its meals.
 *
 * Created by Benjamin Eder on 18.03.2017.
 */
public class Menu {

	private Date date;

	/**
	 * Meals for this date.
	 */
	private Meal[] meals;

	public Menu() {

	}

	public Menu(Date date, Meal[] meals) {
		this.date = date;
		this.meals = meals;
	}

	public Date getDate() {
		return date;
	}

	public void setDate(Date date) {
		this.date = date;
	}

	public Meal[] getMeals() {
		return meals;
	}

	public void setMeals(Meal[] meals) {
		this.meals = meals;
	}

}
