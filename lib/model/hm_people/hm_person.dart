import 'dart:typed_data';

import 'package:meta/meta.dart';

/// Person from the munich university of applied sciences.
class HMPerson {
  /// Name of the person.
  final String name;

  /// Room the person is assigned to.
  final String room;

  /// Telephone number the person is available under.
  final String telephoneNumber;

  /// Image of the person.
  final Uint8List image;

  /// Create person.
  HMPerson({
    @required this.name,
    this.room,
    this.telephoneNumber,
    this.image,
  });

  /// Check if person has an image available.
  bool get hasImage => image != null;

  /// Check if the person has a room assigned.
  bool get hasRoom => room != null;

  /// Check if the person has a telephone number assigned.
  bool get hasTelephoneNumber => telephoneNumber != null;
}
