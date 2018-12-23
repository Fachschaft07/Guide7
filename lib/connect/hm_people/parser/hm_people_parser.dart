import 'dart:typed_data';

import 'package:guide7/model/hm_people/hm_person.dart';
import 'package:guide7/util/parser/parser.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:http/http.dart' as http;

/// Parser parsing HM people from HTML.
class HMPeopleParser implements Parser<String, Future<List<HMPerson>>> {
  /// Constant constructor.
  const HMPeopleParser();

  @override
  Future<List<HMPerson>> parse(String source) async {
    Document document = htmlParser.parse(_prepareHTML(source));

    List<Element> htmlPeople = document.getElementsByClassName("contact-person-list");

    if (htmlPeople.isNotEmpty) {
      return await _parsePeople(htmlPeople);
    } else {
      return [];
    }
  }

  /// Preparet the source html string.
  String _prepareHTML(String html) {
    // Make sure that all mailto: tags in links are removed because the html parser cannot parse these.
    return html.replaceAll("mailto:", "");
  }

  /// Parse the passed [htmlPeople] to HMPerson objects.
  Future<List<HMPerson>> _parsePeople(List<Element> htmlPeople) async {
    List<HMPerson> result = List<HMPerson>();

    for (Element htmlPerson in htmlPeople) {
      result.add(await _parsePerson(htmlPerson));
    }

    return result;
  }

  /// Parse the passed [htmlPerson] to an HMPerson instance.
  Future<HMPerson> _parsePerson(Element htmlPerson) async {
    Uint8List image = await _getPersonAvatar(htmlPerson);
    String name = _getPersonName(htmlPerson);
    String room = _getPersonRoom(htmlPerson);
    String telephoneNumber = _getPersonTelephoneNumber(htmlPerson);

    return HMPerson(
      name: name,
      room: room,
      telephoneNumber: telephoneNumber,
      image: image,
    );
  }

  /// Get name for the passed [htmlPerson].
  String _getPersonName(Element htmlPerson) {
    List<Element> nameElements = htmlPerson.getElementsByClassName("contact-person-name");
    assert(nameElements.isNotEmpty);

    Element nameElement = nameElements.first;
    assert(nameElement.hasChildNodes());

    String html = nameElement.innerHtml;

    List<String> parts = html.split("<br>");
    assert(parts.isNotEmpty);

    return parts.first.trim();
  }

  /// Get room for the passed [htmlPerson].
  String _getPersonRoom(Element htmlPerson) {
    List<Element> nameElements = htmlPerson.getElementsByClassName("contact-person-name");
    if (nameElements.isEmpty) {
      return null;
    }

    Element nameElement = nameElements.first;
    String html = nameElement.innerHtml;

    List<String> parts = html.split("<br>");
    if (parts.length < 2) {
      return null;
    }

    String roomString = parts[1];

    if (roomString.contains("Raum:")) {
      roomString = roomString.replaceFirst("Raum:", "").trim();
    }

    return roomString;
  }

  /// Get telephone number for the passed [htmlPerson].
  String _getPersonTelephoneNumber(Element htmlPerson) {
    List<Element> contactElements = htmlPerson.getElementsByClassName("contact-person-contact");
    if (contactElements.isEmpty) {
      return null;
    }

    Element contactElement = contactElements.first;
    if (!contactElement.hasChildNodes()) {
      return null;
    }

    String html = contactElement.innerHtml;
    List<String> parts = html.split("<br>");
    if (parts.isEmpty) {
      return null;
    }

    String telephoneNumberString = parts.first;

    if (telephoneNumberString.contains("Tel.:")) {
      telephoneNumberString = telephoneNumberString.replaceFirst("Tel.:", "").trim();
    }

    return telephoneNumberString;
  }

  /// Get avatar for the passed [htmlPerson].
  Future<Uint8List> _getPersonAvatar(Element htmlPerson) async {
    List<Element> imageElements = htmlPerson.getElementsByTagName("img");
    if (imageElements.isEmpty) {
      return null;
    }

    Element avatarImage = imageElements.first;
    String imagePath = avatarImage.attributes["src"];
    if (imagePath.isEmpty) {
      return null;
    }

    String alt = avatarImage.attributes["alt"];
    if (alt.toLowerCase().contains("kein profilbild")) {
      return null;
    }

    return await _fetchImage(imagePath);
  }

  /// Fetch image from passed url.
  Future<Uint8List> _fetchImage(String url) async {
    http.Response response = await http.get(url);

    return response.bodyBytes;
  }
}
