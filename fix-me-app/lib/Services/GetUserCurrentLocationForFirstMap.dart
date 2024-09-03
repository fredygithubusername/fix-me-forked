import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

// class GetCurrentLocationClassForFirstMapPage extends ChangeNotifier {
//   double? currentLogUserLongitude;
//   double? currentLogUserLatitude;
//
//   Position? _previousPosition;
//
//   StreamSubscription<Position>? _positionStreamSubscription;
//
//   void startListeningForLocationUpdatesForFirstMapPage() {
//     _positionStreamSubscription = Geolocator.getPositionStream().listen(
//       (Position position) {
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
//           notifyListeners();
//         }
//
//
//       },
//     );
//     print("this is in function Longitude:#################################################################################################### $currentLogUserLongitude, latitude: $currentLogUserLatitude ");
//
//   }
//
//   void stopListeningForLocationUpdatesForFirstMapPage() {
//     _positionStreamSubscription?.cancel();
//   }
// }


class GetCurrentLocationClassForFirstMapPage extends ChangeNotifier {
  double? currentLogUserLongitude;
  double? currentLogUserLatitude;

  Position? _previousPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  Future<void> startListeningForLocationUpdatesForFirstMapPage() async {
    // Check if location services are enabled
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

    // Start listening to location updates
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Only update if the user moves 10 meters or more
      ),
    ).listen(
          (Position position) {
        if (_previousPosition != null) {
          double distanceInMeters = Geolocator.distanceBetween(
            _previousPosition!.latitude,
            _previousPosition!.longitude,
            position.latitude,
            position.longitude,
          );

          if (distanceInMeters > 10) {
            currentLogUserLongitude = position.longitude;
            currentLogUserLatitude = position.latitude;
            _previousPosition = position;
            notifyListeners();
          }
        } else {
          // First location update
          _previousPosition = position;
          currentLogUserLongitude = position.longitude;
          currentLogUserLatitude = position.latitude;
          notifyListeners();
        }
              print("this is in function Longitude:#################################################################################################### $currentLogUserLongitude, latitude: $currentLogUserLatitude ");
  }

      ,
      onError: (error) {
        // Handle errors
        print('Location error: $error');
      },
    );
  }

  void stopListeningForLocationUpdatesForFirstMapPage() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  @override
  void dispose() {
    // Dispose of the stream subscription
    stopListeningForLocationUpdatesForFirstMapPage();
    super.dispose();
  }
}
