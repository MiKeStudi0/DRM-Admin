import 'dart:async';
import 'dart:convert';
import 'package:drm_admin/disaster/screen/rescue/const.dart';
import 'package:flutter/material.dart';
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
  int _markerCount = 0;
  String _victimCountLabel = "Total Victims";
  LatLng? _currentLocation;
  late GoogleMapController _mapController;


  // Your Google Maps API key here (replace with actual key)
  static const String apiKey = 'AIzaSyBJMhMpJEZEN2fubae-mdIZ-vCEXOAkHMk';

  @override
  void initState() {
    super.initState();
    _fetchLocationsFromFirebase();
    _getCurrentLocation();

  }

  // Fetch user's current location
  void _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _addCurrentLocationMarker();
    });
  }

  // Add current location marker
  void _addCurrentLocationMarker() {
    if (_currentLocation != null) {
      final Marker currentMarker = Marker(
        markerId: const MarkerId('currentLocation'),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      );
      setState(() {
        _markers.add(currentMarker);
      });
    }
  }
  
void _getDirectionsToVitcim(LatLng position) async {
  print('Fetching directions to victim at $position');
  
  if (_currentLocation == null) return;
  print('Fetching directions to victim at $_currentLocation');
  
  const apiKey = map; // Replace with your actual API key
  print('${_currentLocation!.latitude},${_currentLocation!.longitude}');

  final url = Uri.https(
    'maps.googleapis.com',
    '/maps/api/directions/json',
    {
      'origin': '${_currentLocation!.latitude},${_currentLocation!.longitude}',
      'destination': '${position.latitude},${position.longitude}',
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
            polylineId: const PolylineId('Route_to_Victim'),
            points: polylineCoordinates,
            color: Colors.red,
            width: 5,
          ),
        );
      });
      if (_mapController != null) {
        _mapController.animateCamera(
          CameraUpdate.newLatLng(position),
        );
      } else {
        print("Map Controller is not initialized yet.");
      }
    } else {
      print('No routes found to victim');
    }
  } else {
    print("Failed to get directions: ${response.statusCode}");
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


void _fetchLocationsFromFirebase() async {
  FirebaseFirestore.instance
      .collection('Alert_locations')
      .get()
      .then((querySnapshot) {
    for (var doc in querySnapshot.docs) {
      var data = doc.data();
      _markerCount += 1;

      LatLng position = LatLng(data['latitude'], data['longitude']);
      String userName = data['name']; // Assuming 'name' is the field in your collection
      _addMarker(position, userName);
    }

    setState(() {
      _victimCountLabel = "Total Victims";
    });
  });
}


  // Add a marker to the map
  void _addMarker(LatLng position, String userName) {
    final Marker marker = Marker(
      markerId: MarkerId(userName),
      position: position,
      icon: BitmapDescriptor.defaultMarker, // Default marker color
      infoWindow: InfoWindow(title: userName),
      onTap: () {
        // _drawRoute(position);
                      _getDirectionsToVitcim(position);

      },
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
      _countMarkersInRadius(position, 2000);
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
            position, 2000); // Count markers within 1000 meters
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
      _markerCount = count;
      _victimCountLabel = "Victims in Searched Area";
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Victims Location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
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
                          _searchLocation(_searchController
                              .text); // Use searchLocation when button pressed
                        },
                      ),
                    ],
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.people, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '$_victimCountLabel:',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_markerCount',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
