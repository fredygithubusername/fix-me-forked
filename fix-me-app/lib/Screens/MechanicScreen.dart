import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../Components/UsersFirstMapScreen.dart';
import '../Services/GetUserCurrentLocationForFirstMap.dart';

class MechanicScreen extends StatefulWidget {
  const MechanicScreen({super.key});

  @override
  State<MechanicScreen> createState() => _MechanicScreenState();
}

class _MechanicScreenState extends State<MechanicScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     floatingActionButton: FloatingActionButton.extended(
      backgroundColor: Color(0xFF39ACE7),
      onPressed: () {
        Provider.of<GetCurrentLocationClassForFirstMapPage>(context,
                listen: false)
            .dispose();
        // context
        //     .read<GetCurrentLocationClassForFirstMapPage>()
        //     .startListeningForLocationUpdatesForFirstMapPage();
        // double? longitude = Provider.of<GetCurrentLocationClassForFirstMapPage>(context, listen: false).currentLogUserLongitude;
        // double? latitude = Provider.of<GetCurrentLocationClassForFirstMapPage>(context,listen: false).currentLogUserLatitude;
        Navigator.pushNamed(context, '/mechanicOnlineMapScreen');
      },
      label: const Text('Go Online'),
    ),
      appBar: AppBar(
        title: Text('Mechanic Home'),
        backgroundColor: const Color(0xFF39ACE7),
      ),
      body: Center(
        child: UsersFirstMapScreen(),
      ),
    );
  }
}



class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Define an initial camera position (San Francisco example)
  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // Coordinates of San Francisco
    zoom: 12.0, // Initial zoom level
  );

  late GoogleMapController mapController;

  // Method to handle map creation and get the controller
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Color(0xFF39ACE7),
          onPressed: () async {
            context
                .read<GetCurrentLocationClassForFirstMapPage>()
                .startListeningForLocationUpdatesForFirstMapPage();
            double? longitude = Provider.of<GetCurrentLocationClassForFirstMapPage>(context, listen: false).currentLogUserLongitude;
            double? latitude = Provider.of<GetCurrentLocationClassForFirstMapPage>(context,listen: false).currentLogUserLatitude;
            print("Longitude: $longitude, latitude: $latitude");
            // Provider.of<GetCurrentLocationClassForFirstMapPage>(context,
            //         listen: false)
            //     .stopListeningForLocationUpdatesForFirstMapPage();
            //Navigator.pushNamed(context, '/mechanicOnlineMapScreen');
          },
          label: const Text('Go Online'),
        ),
        appBar: AppBar(
          title: Text('Mechanic Home'),
          backgroundColor: const Color(0xFF39ACE7),
        ),
      body: Center(
        child: GoogleMap(
          initialCameraPosition: initialCameraPosition, // Set initial position
          onMapCreated: _onMapCreated, // Callback when map is created
          mapType: MapType.normal, // Map type (normal, satellite, etc.)
          markers: {
            Marker(
              markerId: MarkerId('san_francisco'),
              position: LatLng(37.7749, -122.4194),
              infoWindow: InfoWindow(
                title: 'San Francisco',
                snippet: 'A cool city!',
              ),
            ),
          }, // Set markers on the map
          myLocationEnabled: true, // Enable "My Location" button
          zoomControlsEnabled: true, // Enable zoom controls
        ),
      ),
    );
  }
}
