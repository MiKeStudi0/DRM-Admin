import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  final String? keyword;

  const MapScreen({super.key, this.keyword});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Handle permission denial appropriately
      print('Location permissions are denied');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
    _fetchPoliceStations();
    _moveCameraToCurrentLocation();
  }

  void _moveCameraToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    }
  }

  void _fetchPoliceStations() async {
    if (_currentLocation == null) return;

    print('Fetching ${widget.keyword} near $_currentLocation');
    const apiKey = 'AIzaSyBJMhMpJEZEN2fubae-mdIZ-vCEXOAkHMk'; // Replace with your actual Google Places API key
    final url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/nearbysearch/json',
      {
        'location': '${_currentLocation!.latitude},${_currentLocation!.longitude}',
        'radius': '10000', // 10 km radius
        'type': widget.keyword,
        'key': apiKey,
      },
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final places = decodedData['results'] as List;
      _addMarkers(places);
    } else {
      print("Failed to fetch police stations: ${response.statusCode}");
    }
  }

  void _addMarkers(List places) {
    setState(() {
      _markers.clear();
      for (var place in places) {
        final location = place['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        final name = place['name'];

        _markers.add(
          Marker(
            markerId: MarkerId(name),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // Blue marker
            onTap: () {
              _getDirectionsToPoliceStation(LatLng(lat, lng));
            },
          ),
        );
      }
    });
  }

  void _getDirectionsToPoliceStation(LatLng policeStation) async {
    if (_currentLocation == null) return;

    const apiKey = 'AIzaSyBJMhMpJEZEN2fubae-mdIZ-vCEXOAkHMk'; // Replace with your actual API key
    final url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      {
        'origin': '${_currentLocation!.latitude},${_currentLocation!.longitude}',
        'destination': '${policeStation.latitude},${policeStation.longitude}',
        'key': apiKey,
        'mode': 'driving',
        'traffic_model': 'best_guess',
        'departure_time': 'now',
      },
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final routes = decodedData['routes'] as List;
      if (routes.isNotEmpty) {
        final points = routes[0]['overview_polyline']['points'];
        List<LatLng> polylineCoordinates = _decodePolyline(points);
        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route_to_station'),
              points: polylineCoordinates,
              color: Colors.red,
              width: 5,
            ),
          );
        });
        _mapController.animateCamera(
          CameraUpdate.newLatLng(policeStation),
        );
      } else {
        print('No routes found to police station');
      }
    } else {
      print("Failed to get directions to police station: ${response.statusCode}");
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.keyword} Directions')),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 10.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _moveCameraToCurrentLocation();
              },
              polylines: _polylines,
              markers: _markers.union({
                Marker(
                  markerId: const MarkerId('current_location'),
                  position: _currentLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Blue marker for current location
                ),
              }),
            ),
    );
  }
}
