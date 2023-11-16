import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng sourceLocation =
      LatLng(32.57728312636362, 74.06784442976115);
  static const LatLng destination =
      LatLng(32.582001902018085, 74.05883472388257);

  LocationData? currentLocation;

  void getCurrentLocation() async {
    Location location = Location();
    location.onLocationChanged.listen(
      (newLoc) {
        setState(() {
          currentLocation = newLoc;
        });

        if (_controller.isCompleted) {
          _controller.future.then((GoogleMapController controller) {
            controller.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(newLoc.latitude!, newLoc.longitude!),
              ),
            );
          });
        }
      },
    );

    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> moveCameraToDestination() async {
    GoogleMapController googleMapController = await _controller.future;
    await googleMapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: sourceLocation,
          northeast: destination,
        ),
        50.0,
      ),
    );
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target:
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          zoom: 13.5,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("currentLocation"),
            position:
                LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          ),
          const Marker(
            markerId: MarkerId("source"),
            position: sourceLocation,
          ),
          const Marker(
            markerId: MarkerId("destination"),
            position: destination,
          ),
        },
        onMapCreated: (mapController) {
          _controller.complete(mapController);
        },
      ),
    );
  }
}
