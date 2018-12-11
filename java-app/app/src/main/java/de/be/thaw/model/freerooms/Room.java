package de.be.thaw.model.freerooms;

/**
 * Created by Benjamin Eder on 26.02.2017.
 */
public final class Room {

	private final int seats;
	private final String name;

	public Room(String name, int seats) {
		this.name = name;
		this.seats = seats;
	}

	public int getSeats() {
		return seats;
	}

	public String getName() {
		return name;
	}

	@Override
	public String toString() {
		return getName() + " / Seats: " + getSeats();
	}
}
