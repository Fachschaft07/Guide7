import 'dart:async';

import 'package:guide7/storage/hm_person/hm_person_storage.dart';
import 'package:http/http.dart' as http;

import 'package:guide7/connect/hm_people/parser/hm_people_parser.dart';
import 'package:guide7/util/parser/parser.dart';
import 'package:guide7/connect/hm_people/hm_people_repository.dart';
import 'package:guide7/model/hm_people/hm_person.dart';

/// Repository providing information about people working at the munich university of applied sciences.
class HMPeopleRepositoryImpl implements HMPeopleRepository {
  /// Alphabet letters.
  static const String _alphabet = "abcdefghijklmnopqrstuvwxyz";

  /// Base url of the people lists on hm.edu
  static const String _peopleBaseURL = "https://cs.hm.edu/die_fakultaet/ansprechpartner/personenaz_1";

  /// File ending of the people list.
  static const String _resourceEnding = "de.html";

  /// Parser converting HTML to hm people.
  static const Parser<String, Future<List<HMPerson>>> _hmPeopleParser = HMPeopleParser();

  @override
  Future<List<HMPerson>> loadPeople() async {
    List<HMPerson> allPeople = List<HMPerson>();

    // Load all people for each letter in the alphabet.
    for (int i = 0; i < _alphabet.length; i++) {
      String letter = _alphabet[i];

      try {
        allPeople.addAll(await _loadPeopleForLetter(letter));
      } on HMPeopleListNotFoundException {
        // Skip on load exception as the page could not be reached or is not available.
      }
    }

    await _storePeople(allPeople);

    return allPeople;
  }

  /// Load all people for the passed [letter].
  Future<List<HMPerson>> _loadPeopleForLetter(String letter) async {
    assert(letter.length == 1);

    http.Response response = await http.get("$_peopleBaseURL/$letter.$_resourceEnding");

    if (response.statusCode == 200) {
      return await _hmPeopleParser.parse(response.body);
    } else if (response.statusCode == 404) {
      // Page could not be found.
      throw HMPeopleListNotFoundException("HM People list for letter '$letter' could not be found.");
    } else {
      throw Exception("HM People for letter '$letter' could not be parsed.");
    }
  }

  @override
  Future<List<HMPerson>> getCachedPeople() async {
    var storage = HMPersonStorage();
    return await storage.read();
  }

  @override
  Future<bool> hasCachedPeople() async {
    var storage = HMPersonStorage();
    return !(await storage.isEmpty());
  }

  /// Store people in cache.
  Future<void> _storePeople(List<HMPerson> people) async {
    var storage = HMPersonStorage();
    await storage.write(people);
  }
}

/// Exception thrown in case a hm people list could not be found.
class HMPeopleListNotFoundException implements Exception {
  /// Additional message.
  final String message;

  /// Create exception
  HMPeopleListNotFoundException(this.message);
}
