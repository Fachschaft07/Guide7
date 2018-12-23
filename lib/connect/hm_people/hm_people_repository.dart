import 'package:guide7/model/hm_people/hm_person.dart';

/// Repository delivering people information of the department 07 of the munich university of applied sciences.
abstract class HMPeopleRepository {
  /// Load people from a remote resource.
  Future<List<HMPerson>> loadPeople();

  /// Get all cached people.
  Future<List<HMPerson>> getCachedPeople();

  /// Check if the repository contains cached people.
  Future<bool> hasCachedPeople();
}
