package de.be.thaw.model.noticeboard;

import java.util.Date;

/**
 * An entry in the notice board.
 * <p>
 * Created by Benjamin Eder on 12.03.2017.
 */
public class BoardEntry {

	/**
	 * The Author of the board entry.
	 */
	private String author;

	/**
	 * Title of the entry.
	 */
	private String title;

	/**
	 * The content of the board entry. Contains HTML.
	 */
	private String content;

	/**
	 * From which Date this entry is valid.
	 */
	private Date from;

	/**
	 * To which Date this entry is valid.
	 */
	private Date to;

	/**
	 * Portrait id of the author.
	 */
	private int portraitId;

	/**
	 * Create new Board entry.
	 *
	 * @param author
	 * @param title
	 * @param content
	 * @param from
	 * @param to
	 */
	public BoardEntry(String author, String title, String content, Date from, Date to) {
		this.author = author;
		this.title = title;
		this.content = content;
		this.from = from;
		this.to = to;
	}

	public BoardEntry() {
		// Default constructor for Jackson JSON
	}

	/**
	 * Get the Author.
	 *
	 * @return
	 */
	public String getAuthor() {
		return author;
	}

	/**
	 * Get the entries title.
	 *
	 * @return
	 */
	public String getTitle() {
		return title;
	}

	/**
	 * Get the Entries HTML Content.
	 *
	 * @return
	 */
	public String getContent() {
		return content;
	}

	/**
	 * Get the date from which this entry is valid.
	 *
	 * @return
	 */
	public Date getFrom() {
		return from;
	}

	/**
	 * Get the date to which this entry is valid.
	 *
	 * @return
	 */
	public Date getTo() {
		return to;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public void setFrom(Date from) {
		this.from = from;
	}

	public void setTo(Date to) {
		this.to = to;
	}

	public int getPortraitId() {
		return portraitId;
	}

	public void setPortraitId(int portraitId) {
		this.portraitId = portraitId;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if (o == null || getClass() != o.getClass()) return false;

		BoardEntry that = (BoardEntry) o;

		if (author != null ? !author.equals(that.author) : that.author != null) return false;
		if (title != null ? !title.equals(that.title) : that.title != null) return false;
		if (content != null ? !content.equals(that.content) : that.content != null) return false;
		if (from != null ? !from.equals(that.from) : that.from != null) return false;
		return to != null ? to.equals(that.to) : that.to == null;
	}

	@Override
	public int hashCode() {
		int result = author != null ? author.hashCode() : 0;
		result = 31 * result + (title != null ? title.hashCode() : 0);
		result = 31 * result + (content != null ? content.hashCode() : 0);
		result = 31 * result + (from != null ? from.hashCode() : 0);
		result = 31 * result + (to != null ? to.hashCode() : 0);
		return result;
	}

	@Override
	public String toString() {
		return "Author: " + author +
				" Title: " + title +
				" Valid (From-To): " + from.toString() +
				" - " + to.toString();
	}

}
