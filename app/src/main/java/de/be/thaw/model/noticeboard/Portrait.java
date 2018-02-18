package de.be.thaw.model.noticeboard;

/**
 * A portrait contains image data for a name.
 *
 * Created by barny on 18.02.2018.
 */
public class Portrait {

	private int id;

	private byte[] data;

	public Portrait(int id, byte[] data) {
		this.id = id;
		this.data = data;
	}

	public Portrait() {
		// Default constructor
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public byte[] getData() {
		return data;
	}

	public void setData(byte[] data) {
		this.data = data;
	}

}
