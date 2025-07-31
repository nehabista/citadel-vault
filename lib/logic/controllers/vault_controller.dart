// File: lib/logic/controllers/vault_controller.dart
import 'package:get/get.dart';
import '../../data/models/vault_item_model.dart';
import '../../data/services/vault/vault_service.dart';

class VaultController extends GetxController {
  final VaultService _vaultService = Get.find<VaultService>();

  var isLoading = true.obs;
  final allItems = <VaultItem>[].obs;
  final filteredItems = <VaultItem>[].obs;
  final Rx<VaultItemType?> _selectedFilter = Rx<VaultItemType?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      isLoading.value = true;
      final items = await _vaultService.fetchAndDecryptVaultItems();
      allItems.assignAll(items);
      _applyFilter();
    } catch (e) {
      Get.snackbar('Error Fetching Vault', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    if (_selectedFilter.value == null) {
      filteredItems.assignAll(allItems);
    } else {
      filteredItems.assignAll(
        allItems.where((item) => item.type == _selectedFilter.value).toList(),
      );
    }
  }

  void changeFilter(int tabIndex) {
    if (tabIndex == 0) {
      _selectedFilter.value = null;
    } else {
      _selectedFilter.value = VaultItemType.values[tabIndex - 1];
    }
    _applyFilter();
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _vaultService.deleteVaultItem(itemId);
      allItems.removeWhere((item) => item.id == itemId);
      _applyFilter();
      Get.snackbar('Success', 'Item deleted.');
    } catch (e) {
      Get.snackbar('Error', 'Could not delete item.');
    }
  }
}
