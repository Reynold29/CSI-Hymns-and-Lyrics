import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateManager {
  Future<void> checkForUpdates(BuildContext context) async {
    InAppUpdate.checkForUpdate()
        .then((info) {
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed){
          InAppUpdate.startFlexibleUpdate();
        } else {
          InAppUpdate.performImmediateUpdate()
              // ignore: invalid_return_type_for_catch_error
              .catchError((e) => print('Error performing immediate update: $e'));
        }
      }
    }).catchError((e) {
      print('Error checking for update: $e');
    });
  }
}
