import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class VictimLocation extends StatefulWidget {
  @override
  _VictimLocationState createState() => _VictimLocationState();
}

class _VictimLocationState extends State<VictimLocation> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  TextEditingController _searchController = TextEditingController();
  LatLng _searchedLocation = LatLng(0, 0);
  List<dynamic> _suggestions = [];
  int _markerCount = 0; // Variable to hold the count of markers

  // Your Google Maps API key here (replace with actual key)
  static const String apiKey = 'AIzaSyBJMhMpJEZEN2fubae-mdIZ-vCEXOAkHMk';

  @override
  void initState() {
    super.initState();
    _fetchLocationsFromFirebase();
  }

  // Fetches location data from Firestore collection "locations"
  void _fetchLocationsFromFirebase() async {
    FirebaseFirestore.instance
        .collection('Alert_locations')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var data = doc.data() as Map<String, dynamic>;
        LatLng position = LatLng(data['latitude'], data['longitude']);
        _addMarker(position, doc.id);
      });
    });
  }

  // Adds a marker to the map
  void _addMarker(LatLng position, String markerId) {
    final Marker marker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(
        title: 'Location: $markerId',
      ),
    );
    setState(() {
      _markers.add(marker);
    });
  }

  // Fetch location suggestions based on user input
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

  // Fetch selected location's details and move camera
  Future<void> _selectSuggestion(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final location = jsonData['result']['geometry']['location'];
      LatLng position = LatLng(location['lat'], location['lng']);

      _moveCamera(position);
      _countMarkersInRadius(position, 1000);
      setState(() {
        _suggestions = [];
        _searchController.clear();
      });
    } else {
      print("Failed to fetch location: ${response.statusCode}");
    }
  }

  // Search for location based on user input
  Future<void> _searchLocation(String searchText) async {
    if (searchText.isEmpty) return;

    final String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$searchText&inputtype=textquery&fields=geometry&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['candidates'].isNotEmpty) {
        final lat = jsonData['candidates'][0]['geometry']['location']['lat'];
        final lng = jsonData['candidates'][0]['geometry']['location']['lng'];
        LatLng position = LatLng(lat, lng);

        _moveCamera(position);
        _countMarkersInRadius(
            position, 1000); // Count markers within 5000 meters
      } else {
        print('No location found');
      }
    } else {
      print("Failed to fetch location: ${response.statusCode}");
    }
  }

  // Move camera to a specific position
  Future<void> _moveCamera(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 14.0),
    ));
  }

  // Function to count markers within a specified radius
  void _countMarkersInRadius(LatLng center, double radius) {
    int count = 0;
    for (var marker in _markers) {
      if (_isWithinRadius(center, marker.position, radius)) {
        count++;
      }
    }
    setState(() {
      _markerCount = count; // Update the count of markers
    });
  }

  // Check if a marker is within a given radius
  bool _isWithinRadius(LatLng center, LatLng point, double radius) {
    double distance = _calculateDistance(center, point);
    return distance <= radius;
  }

  // Calculate distance between two LatLng points
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
    return earthRadius * c; // Distance in meters
  }

  // Helper method to convert degrees to radians
  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Victims Location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(11.258753, 75.780411), // Initial position
              zoom: 10.0, // Initial zoom level
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: _markers,
          ),
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
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
                          decoration: InputDecoration(
                            hintText: 'Search Location',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            _getSuggestions(value);
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          _searchLocation(_searchController
                              .text); // Use searchLocation when button pressed
                        },
                      ),
                    ],
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
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
                  ),
              ],
            ),
          ),
          // New widget to display count of markers
          Positioned(
            bottom: 50,
            left: 15,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text("Victim Count"),
                  SizedBox(width: 8),
                  Icon(Icons.people, size: 24), // People icon
                  SizedBox(width: 8),
                  Text(
                    '$_markerCount',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
