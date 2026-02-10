import 'package:get/get.dart';
import '../models/address.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

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
      Get.snackbar('Error', 'Failed to load addresses');
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
        Get.snackbar('Success', 'Address added successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add address');
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
        Get.snackbar('Success', 'Address updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update address');
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
        Get.snackbar('Success', 'Address deleted successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete address');
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
      Get.snackbar('Success', 'Default address updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to set default address');
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
