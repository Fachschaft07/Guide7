package de.be.thaw.connect.parser;

import org.jsoup.nodes.Document;

import de.be.thaw.connect.parser.exception.ParseException;

public interface Parser<T, R> {

	R parse(T toParse) throws ParseException;
	
}
