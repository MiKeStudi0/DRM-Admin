import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class VictimLocation extends StatefulWidget {
  const VictimLocation({super.key});

  @override
  _VictimLocationState createState() => _VictimLocationState();
}

class _VictimLocationState extends State<VictimLocation> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _suggestions = [];
  LatLng? _currentLocation;
  int _markerCount = 0;
  String _victimCountLabel = "Total Victims";

  String apiKey = 'AIzaSyBJMhMpJEZEN2fubae-mdIZ-vCEXOAkHMk';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchLocationsFromFirebase();
  }

  void _setMapStyle() {

    getJsonFile('assets/map_style.json').then((String value) {
      final mapStyle = value;
      _controller.future.then((controller) {
        controller.setMapStyle(mapStyle);
      });
    });
  }
  
   

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _addCurrentLocationMarker();
      });

      if (_currentLocation != null) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 14.0));
      }
    }
  }

  void _addCurrentLocationMarker() {
    if (_currentLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }
  }

  void _fetchLocationsFromFirebase() async {
    FirebaseFirestore.instance.collection('Alert_locations').get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        LatLng position = LatLng(data['latitude'], data['longitude']);
        String userName = data['name'];
        _addMarker(position, userName);
      }
    });
  }

  void _addMarker(LatLng position, String userName) {
    final Marker marker = Marker(
      markerId: MarkerId(userName),
      position: position,
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: userName),
      onTap: () {
        if (_currentLocation != null) {
          _drawRoute(_currentLocation!, position);
        }
      },
    );
    setState(() {
      _markers.add(marker);
      _markerCount++;
    });
  }

  Future<void> _drawRoute(LatLng start, LatLng destination) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = _decodePolyline(data['routes'][0]['overview_polyline']['points']);
      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.blue,
            width: 4,
          ),
        );
      });
    } else {
      print('Failed to fetch directions: ${response.statusCode}');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylinePoints = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polylinePoints.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylinePoints;
  }

  Future<void> _getSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _suggestions = jsonData['predictions'];
      });
    } else {
      print("Failed to fetch suggestions: ${response.statusCode}");
    }
  }

  Future<void> _selectSuggestion(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final location = jsonData['result']['geometry']['location'];
      LatLng position = LatLng(location['lat'], location['lng']);

      _moveCamera(position);
      _countMarkersInRadius(position, 2000);
      setState(() {
        _suggestions = [];
        _searchController.clear();
      });
    } else {
      print("Failed to fetch location: ${response.statusCode}");
    }
  }

  Future<void> _moveCamera(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 14.0),
    ));
  }

  void _countMarkersInRadius(LatLng center, double radius) {
    int count = 0;
    for (var marker in _markers) {
      if (_isWithinRadius(center, marker.position, radius)) {
        count++;
      }
    }
    setState(() {
      _markerCount = count;
      _victimCountLabel = "Victims in Searched Area";
    });
  }

  bool _isWithinRadius(LatLng center, LatLng point, double radius) {
    double distance = _calculateDistance(center, point);
    return distance <= radius;
  }
void _searchLocation(String query) async {
  if (query.isEmpty) {
    return;
  }

  final String url =
      'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    if (jsonData['results'].isNotEmpty) {
      final location = jsonData['results'][0]['geometry']['location'];
      LatLng position = LatLng(location['lat'], location['lng']);

      _moveCamera(position);
      _countMarkersInRadius(position, 2000);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No results found for the search query.')),
      );
    }
  } else {
    print("Failed to fetch location: ${response.statusCode}");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error fetching search results.')),
    );
  }
}

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // in meters
    double dLat = _toRadians(end.latitude - start.latitude);
    double dLng = _toRadians(end.longitude - start.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(start.latitude)) *
            cos(_toRadians(end.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Victims Location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(11.258753, 75.780411),
              zoom: 10.0,
            ),
           onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _setMapStyle();
},

            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Column(
              children: [
                _buildSearchBox(),
                if (_suggestions.isNotEmpty) _buildSuggestionsList(),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            left: 15,
            child: _buildMarkerCountWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Location',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                _getSuggestions(value);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _searchLocation(_searchController.text);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return ListTile(
            title: Text(suggestion['description']),
            onTap: () {
              _selectSuggestion(suggestion['place_id']);
            },
          );
        },
      ),
    );
  }

  Widget _buildMarkerCountWidget() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$_victimCountLabel: $_markerCount',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
