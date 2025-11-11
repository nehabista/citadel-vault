import '../../../../features/vault/domain/entities/custom_field.dart';

/// Contract that each type-specific form widget must satisfy.
///
/// The parent [VaultItemEditPage] uses a [GlobalKey] to call these methods
/// on the active type widget when saving.
abstract class TypeFormContract {
  /// Return the item name derived from this form's primary field.
  String getName();

  /// Return the type-specific custom fields collected from controllers.
  List<CustomField> getCustomFields();
}
