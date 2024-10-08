import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../Models/ModelsData.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: Provider.of<TaskData>(context, listen: false)
              .getUsersLocationData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              double nearestMechanicLocationLatitude =
                  Provider.of<TaskData>(context, listen: false)
                      .nearestMechanicLocationLatitude;
              double nearestMechanicLocationLongitude =
                  Provider.of<TaskData>(context, listen: false)
                      .nearestMechanicLocationLongitude;
              double currentLogUserLongitude =
                  Provider.of<TaskData>(context, listen: false)
                      .currentLogUserLongitude;
              double currentLogUserLatitude =
                  Provider.of<TaskData>(context, listen: false)
                      .currentLogUserLatitude;
              Map<PolylineId, Polyline> polylines =
                  Provider.of<TaskData>(context, listen: false)
                      .polylinesInTaskData;

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(nearestMechanicLocationLatitude,
                      nearestMechanicLocationLongitude),
                  zoom: 16.5,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('Log User Location'),
                    position:
                        LatLng(currentLogUserLatitude, currentLogUserLongitude),
                  ),
                  Marker(
                    markerId: MarkerId('mechanic Location'),
                    position: LatLng(nearestMechanicLocationLatitude,
                        nearestMechanicLocationLongitude),
                  )
                },
                polylines: Set<Polyline>.of(polylines.values),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
