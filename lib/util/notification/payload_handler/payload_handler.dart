import 'package:flutter/widgets.dart';

/// Interface for all payload handler doing stuff based on a passed notification payload string.
abstract class PayloadHandler {
  /// Handle the passed payload.
  /// Return whether the handler is handling the payload.
  Future<bool> handle(String payload, BuildContext context);
}
