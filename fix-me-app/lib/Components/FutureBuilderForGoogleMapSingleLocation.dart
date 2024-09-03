import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../Services/GetCurrentLocation.dart';
import 'GoogleMapComponent.dart';

class GoogleMapForMechanicOnlineScreenLocation extends StatelessWidget {
  const GoogleMapForMechanicOnlineScreenLocation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Provider.of<GetCurrentLocationClass>(context, listen: false)
    //     .startListeningForLocationUpdates();
    context
        .read<GetCurrentLocationClass>()
        .startListeningForLocationUpdates();
    print("############################################################################################# ${Provider.of<GetCurrentLocationClass>(context, listen: true).currentLogUserLongitude}");

    return Consumer<GetCurrentLocationClass>(
      builder: (context, locationData, _) {
        if (Provider.of<GetCurrentLocationClass>(context, listen: true).currentLogUserLongitude != null &&
            Provider.of<GetCurrentLocationClass>(context, listen: true).currentLogUserLatitude != null) {
          return GoogleMapWidget(
            cameraPositionLatLng: LatLng(
              Provider.of<GetCurrentLocationClass>(context, listen: true).currentLogUserLatitude ?? 0.0,
              Provider.of<GetCurrentLocationClass>(context, listen: true).currentLogUserLongitude ?? 0.0,
            ),
            polylines: {},
            markers: <Marker>{
              Marker(
                markerId: MarkerId('Log User Location'),
                position: LatLng(
                  Provider.of<GetCurrentLocationClass>(context, listen: true).currentLogUserLatitude ?? 0.0,
                  Provider.of<GetCurrentLocationClass>(context, listen: true).currentLogUserLongitude ?? 0.0,
                ),
              ),
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
