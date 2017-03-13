package de.be.thaw.zpa.parser;

import org.jsoup.nodes.Document;

import java.text.ParseException;

import de.be.thaw.zpa.exception.ZPAParseException;

public interface ZPAParser<T> {

	T parse(Document doc) throws ZPAParseException;
	
}
