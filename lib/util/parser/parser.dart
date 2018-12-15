/// Parser parsing arbitrary things from source.
abstract class Parser<S, R> {
  /// Parse something from passed [source].
  R parse(S source);
}
