import 'package:guide7/connect/hm_people/hm_people_repository.dart';
import 'package:guide7/model/hm_people/hm_person.dart';

/// Mock repository for HM people.
class MockHMPeopleRepository implements HMPeopleRepository {
  @override
  Future<List<HMPerson>> getCachedPeople() async => [];

  @override
  Future<bool> hasCachedPeople() async => false;

  @override
  Future<List<HMPerson>> loadPeople() async => [];
}
