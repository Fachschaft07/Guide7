/// Storage base interface.
abstract class Storage<T> {
  /// Read data from storage.
  T read();

  /// Write data from storage.
  void write(T data);

  /// Clear storage completely.
  void clear();
}
