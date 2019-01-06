import 'package:guide7/ui/navigation/app_floating_action_button/item/app_floating_action_button_item.dart';

/// Provider for action button items.
abstract class FloatingActionButtonItemProvider {
  /// Get items for the floating action button.
  List<AppFloatingActionButtonItem> getItems();
}
