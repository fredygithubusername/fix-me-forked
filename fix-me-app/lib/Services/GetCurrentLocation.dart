import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fix_me_app/Services/GetTokenNotification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class GetCurrentLocationClass extends ChangeNotifier {
  double? currentLogUserLongitude;
  double? currentLogUserLatitude;

  Position? _previousPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  final _databaseReference = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Future<void> startListeningForLocationUpdates() async {
    print("startListeningForLocationUpdates() this was called brow!!!!!!!!!!!!!!!!!!!!!!");
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, handle accordingly
      return;
    }

    // Check for location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle accordingly
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, handle accordingly
      return;
    }
    _positionStreamSubscription = Geolocator.getPositionStream().listen(
      (Position position) {
        print("!!!!!!!!!!!!!!!!!!!!!! if previous position !!!!!!!!!!!!!!!!!!!!!!");
        if (_previousPosition != null) {
          // Calculate the distance between the current and previous positions
          double distanceInMeters = Geolocator.distanceBetween(
            _previousPosition!.latitude,
            _previousPosition!.longitude,
            position.latitude,
            position.longitude,
          );

          // Only update if the distance is significant (e.g., user moved more than 10 meters)
          if (distanceInMeters > 10) {
            currentLogUserLongitude = position.longitude;
            currentLogUserLatitude = position.latitude;

            // Update the database with the new location
            _updateDatabaseWithLocation(position.latitude, position.longitude);

            // Update the previous position
            _previousPosition = position;

            notifyListeners();
          }
        } else {
          // First time receiving location, set the previous position
          _previousPosition = position;

          currentLogUserLongitude = position.longitude;
          currentLogUserLatitude = position.latitude;

          // Check if the user's location exists in the database
          _checkAndAddUserLocation(position.latitude, position.longitude);

          // Update the database with the initial location
          _updateDatabaseWithLocation(position.latitude, position.longitude);

          notifyListeners();
        }
      },
    );
  }

  // Future<void> startListeningForLocationUpdates() async {
  //   print("startListeningForLocationUpdates() this was called brow!!!!!!!!!!!!!!!!!!!!!!");
  //
  //   _positionStreamSubscription = Geolocator.getPositionStream().listen(
  //         (Position position) async {
  //       print("Received a new position########################################################: $position");
  //
  //       try {
  //         if (_previousPosition != null) {
  //           // Calculate the distance between the current and previous positions
  //           double distanceInMeters = Geolocator.distanceBetween(
  //             _previousPosition!.latitude,
  //             _previousPosition!.longitude,
  //             position.latitude,
  //             position.longitude,
  //           );
  //
  //           // Only update if the distance is significant (e.g., user moved more than 10 meters)
  //           if (distanceInMeters > 10) {
  //             currentLogUserLongitude = position.longitude;
  //             currentLogUserLatitude = position.latitude;
  //
  //             // Update the database with the new location
  //             await _updateDatabaseWithLocation(position.latitude, position.longitude);
  //
  //             // Update the previous position
  //             _previousPosition = position;
  //
  //             notifyListeners();
  //           }
  //         } else {
  //           // First time receiving location, set the previous position
  //           _previousPosition = position;
  //
  //           currentLogUserLongitude = position.longitude;
  //           currentLogUserLatitude = position.latitude;
  //
  //           // Check if the user's location exists in the database
  //           await _checkAndAddUserLocation(position.latitude, position.longitude);
  //
  //           // Update the database with the initial location
  //           await _updateDatabaseWithLocation(position.latitude, position.longitude);
  //
  //           notifyListeners();
  //         }
  //       } catch (e) {
  //         print('Error in location update stream: $e');
  //       }
  //     },
  //     onError: (error) {
  //       print('Error listening to location updates: $error');
  //     },
  //   );
  // }


  Future _checkAndAddUserLocation(double latitude, double longitude) async {
    try {
      // Check if the user's location document exists in the 'user_location' collection
      DocumentSnapshot snapshot = await _databaseReference
          .collection('available_mechanic_location')
          .doc('${auth.currentUser?.uid}')
          .get();

      if (!snapshot.exists) {
        // If user_location document does not exist, add the user's location to the database
        _updateDatabaseWithLocation(latitude, longitude);
      }
    } catch (e) {
      print('Error checking user location: $e');
    }
  }

  Future  _updateDatabaseWithLocation(double latitude, double longitude) async {
    NotificationClass notificationClass = NotificationClass();

    _databaseReference
        .collection('available_mechanic_location')
        .doc('${auth.currentUser?.uid}')
        .set({
      'latitude': latitude,
      'longitude': longitude,
      'cfm token': await notificationClass.getFcmTokenForNotification(),
      'email': auth.currentUser?.email,
    });
  }

  void stopListeningForLocationUpdates() {
    _positionStreamSubscription?.cancel();
  }
}

//
// class GetCurrentLocationClass extends ChangeNotifier {
//   double? currentLogUserLongitude;
//   double? currentLogUserLatitude;
//
//   Position? _previousPosition;
//
//   StreamSubscription<Position>? _positionStreamSubscription;
//
//   final _databaseReference = FirebaseFirestore.instance;
//   final auth = FirebaseAuth.instance;
//
//   void startListeningForLocationUpdates() {
//     print("startListeningForLocationUpdates() this was called brow!!!!!!!!!!");
//
//     _positionStreamSubscription = Geolocator.getPositionStream().listen(
//           (Position position) async {
//             print("####################try and catch ###############################################");
//         try {
//           if (_previousPosition != null) {
//             print("Geolocator.getPositionStream().listen   ######### this was called brow!!!!!!!!!!");
//             // Calculate the distance between the current and previous positions
//             double distanceInMeters = Geolocator.distanceBetween(
//               _previousPosition!.latitude,
//               _previousPosition!.longitude,
//               position.latitude,
//               position.longitude,
//             );
//
//             // Only update if the distance is significant (e.g., user moved more than 10 meters)
//             if (distanceInMeters > 10) {
//               currentLogUserLongitude = position.longitude;
//               currentLogUserLatitude = position.latitude;
//
//               // Update the database with the new location
//               await _updateDatabaseWithLocation(position.latitude, position.longitude);
//
//               // Update the previous position
//               _previousPosition = position;
//
//               notifyListeners();
//             }
//           } else {
//             // First time receiving location, set the previous position
//             _previousPosition = position;
//
//             currentLogUserLongitude = position.longitude;
//             currentLogUserLatitude = position.latitude;
//
//             // Check if the user's location exists in the database and add if not
//             await _checkAndAddUserLocation(position.latitude, position.longitude);
//
//             // Update the database with the initial location
//             await _updateDatabaseWithLocation(position.latitude, position.longitude);
//
//             notifyListeners();
//           }
//           print("########################################################### $currentLogUserLatitude, $currentLogUserLongitude");
//
//         } catch (e) {
//           print('Error in location update stream:%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% $e');
//         }
//       },
//       onError: (error) {
//         print('Error listening to location updates:%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% $error');
//       },
//     );
//   }
//
//   Future<void> _checkAndAddUserLocation(double latitude, double longitude) async {
//     try {
//       // Check if the user's location document exists in the 'user_location' collection
//       DocumentSnapshot snapshot = await _databaseReference
//           .collection('available_mechanic_location')
//           .doc('${auth.currentUser?.uid}')
//           .get();
//
//       if (!snapshot.exists) {
//         // If user_location document does not exist, add the user's location to the database
//         await _updateDatabaseWithLocation(latitude, longitude);
//
//         print("######################## return update database ###################################");
//
//       }
//     } catch (e) {
//       print('Error checking user location: $e');
//     }
//   }
//
//   Future<void> _updateDatabaseWithLocation(double latitude, double longitude) async {
//     try {
//       NotificationClass notificationClass = NotificationClass();
//
//       await _databaseReference
//           .collection('available_mechanic_location')
//           .doc('${auth.currentUser?.uid}')
//           .set({
//         'latitude': latitude,
//         'longitude': longitude,
//         'cfm token': await notificationClass.getFcmTokenForNotification(),
//         'email': auth.currentUser?.email,
//       });
//     } catch (e) {
//       print('Error updating database with location: $e');
//     }
//   }
//
//   void stopListeningForLocationUpdates() {
//     _positionStreamSubscription?.cancel();
//     _positionStreamSubscription = null; // Reset subscription reference to avoid future errors
//   }
//
//   @override
//   void dispose() {
//     stopListeningForLocationUpdates(); // Ensure subscription is cancelled when the class is disposed
//     super.dispose();
//   }
// }
