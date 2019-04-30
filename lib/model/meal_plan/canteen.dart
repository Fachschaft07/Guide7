/// Representation for a canteen.
class Canteen {
  /// Id of the canteen.
  final int id;

  /// Name of the canteen.
  final String name;

  /// Create canteen.
  const Canteen({
    this.id,
    this.name,
  });

  @override
  bool operator ==(Object other) => identical(this, other) || other is Canteen && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
