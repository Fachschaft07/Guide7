/// Storage base interface.
abstract class Storage<T> {
  /// Read data from storage.
  Future<T> read();

  /// Write data from storage.
  Future<void> write(T data);

  /// Clear storage completely.
  Future<void> clear();

  /// Check whether the storage is empty.
  Future<bool> isEmpty();
}
