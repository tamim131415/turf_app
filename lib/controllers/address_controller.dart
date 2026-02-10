import 'package:get/get.dart';
import '../models/address.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_strings.dart';

class AddressController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<Address> addresses = <Address>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUser?.uid;

      if (userId != null) {
        addresses.value = await _firestoreService.getUserAddresses(userId);
      }
    } catch (e) {
      Get.snackbar(AppStrings.error, AppStrings.failedToLoadAddresses);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAddress(Address address) async {
    try {
      isLoading.value = true;

      // If this is set as default, unset all other defaults
      if (address.isDefault) {
        await _setAllAddressesAsNonDefault();
      }

      final addressId = await _firestoreService.saveAddress(address);

      if (addressId != null) {
        await loadAddresses();
        Get.back();
        Get.snackbar(AppStrings.success, AppStrings.addressAddedSuccessfully);
      }
    } catch (e) {
      Get.snackbar(AppStrings.error, AppStrings.failedToAddAddress);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAddress(Address address) async {
    try {
      isLoading.value = true;

      // If this is set as default, unset all other defaults
      if (address.isDefault) {
        await _setAllAddressesAsNonDefault();
      }

      final success = await _firestoreService.updateAddress(
        address.id,
        address.toMap(),
      );

      if (success) {
        await loadAddresses();
        Get.back();
        Get.snackbar(AppStrings.success, AppStrings.addressUpdatedSuccessfully);
      }
    } catch (e) {
      Get.snackbar(AppStrings.error, AppStrings.failedToUpdateAddress);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      isLoading.value = true;

      final success = await _firestoreService.deleteAddress(addressId);

      if (success) {
        await loadAddresses();
        Get.snackbar(AppStrings.success, AppStrings.addressDeletedSuccessfully);
      }
    } catch (e) {
      Get.snackbar(AppStrings.error, AppStrings.failedToDeleteAddress);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    try {
      isLoading.value = true;

      // Unset all defaults first
      await _setAllAddressesAsNonDefault();

      // Set the selected address as default
      await _firestoreService.updateAddress(addressId, {'isDefault': true});

      await loadAddresses();
      Get.snackbar(AppStrings.success, AppStrings.defaultAddressUpdated);
    } catch (e) {
      Get.snackbar(AppStrings.error, AppStrings.failedToSetDefaultAddress);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _setAllAddressesAsNonDefault() async {
    for (var address in addresses) {
      if (address.isDefault) {
        await _firestoreService.updateAddress(address.id, {'isDefault': false});
      }
    }
  }

  Address? get defaultAddress {
    try {
      return addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }
}
