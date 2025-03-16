import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:drm_admin/disaster/screen/rescue/const.dart';

class victimLiveTrackPage extends StatefulWidget {
  const victimLiveTrackPage({super.key});

  @override
  _victimLiveTrackPageState createState() => _victimLiveTrackPageState();
}

class _victimLiveTrackPageState extends State<victimLiveTrackPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _suggestions = [];
  LatLng? _currentLocation;
  int _markerCount = 0;
  String _victimCountLabel = "Live Tracking";
  final DatabaseReference _databaseReference = FirebaseDatabase.instance
      .refFromURL(
          'https://disastermain-66982-default-rtdb.asia-southeast1.firebasedatabase.app')
      .child('users_tracking');

  String apiKey = map;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchLocationsFromRealtimeDatabase();
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
        controller
            .animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 14.0));
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

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
  }

  void _fetchLocationsFromRealtimeDatabase() {
    _databaseReference.onValue.listen((event) async {
      try {
        final data = event.snapshot.value as Map?;
        if (data != null) {
          // Clear previous markers
          setState(() {
            _markers.clear();
          });

          data.forEach((key, value) {
            if (value is Map && value['isTracking'] == true) {
              final latitude = value['location']?['latitude'];
              final longitude = value['location']?['longitude'];
              final userName = value['name'] ?? "Unknown User";
              final profilePhotoUrl = value['profileImageUrl'] ?? "";
              final district = value['district'] ?? "";
              final email = value['email'] ?? "";
              final phone = value['phone'] ?? "";

              if (latitude != null && longitude != null) {
                LatLng position = LatLng(latitude, longitude);
                _addMarker(position, userName, profilePhotoUrl, district, email,
                    phone);
              } else {
                debugPrint("Skipping user $key due to missing coordinates.");
              }
            }
          });
        } else {
          debugPrint("No data available from Realtime Database.");
        }
      } catch (e) {
        debugPrint("Error fetching data from Realtime Database: $e");
      }
    });
  }

  void _addMarker(
    LatLng position,
    String userName,
    String profilePhotoUrl,
    String district,
    String email,
    String phone,
  ) {
    final Marker marker = Marker(
      markerId: MarkerId(userName),
      position: position,
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: userName,
        snippet: 'Tap for details',
        onTap: () {
          _showMarkerDetails(userName, profilePhotoUrl, district, email, phone);
        },
      ),
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

  void _showMarkerDetails(
    String userName,
    String profilePhotoUrl,
    String district,
    String email,
    String phone,
  ) {
    // Convert Timestamp to DateTime and format it

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the modal to expand fully
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  16.0, // Adjust for keyboard
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Picture
                Row(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: profilePhotoUrl.isNotEmpty
                            ? NetworkImage(profilePhotoUrl)
                            : null,
                        child: profilePhotoUrl.isEmpty
                            ? const Icon(Icons.person,
                                size: 60, color: Colors.white)
                            : null,
                        backgroundColor: profilePhotoUrl.isNotEmpty
                            ? Colors.transparent
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(221, 255, 255, 255),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // User Details Section

                const Divider(height: 30, thickness: 1),

                // District
                _detailRow(Icons.map, "District", district, context),
                const SizedBox(height: 10),
                // Email
                _detailRow(Icons.email, "Email", email, context),
                const SizedBox(height: 10),
                // Phone
                _detailRow(Icons.phone, "Phone", phone, context),
                const SizedBox(height: 60),
                // Close Button
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
      IconData icon, String label, String value, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.ubuntu(
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onBackground.withOpacity(0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.ubuntu(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _drawRoute(LatLng start, LatLng destination) async {
    const String apiKey = map; // Replace with your actual API key
    final Uri url =
        Uri.parse("https://routes.googleapis.com/directions/v2:computeRoutes");

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "X-Goog-Api-Key": apiKey,
      "X-Goog-FieldMask":
          "routes.polyline.encodedPolyline" // Fetch only required fields
    };

    final Map<String, dynamic> body = {
      "origin": {
        "location": {
          "latLng": {"latitude": start.latitude, "longitude": start.longitude}
        }
      },
      "destination": {
        "location": {
          "latLng": {
            "latitude": destination.latitude,
            "longitude": destination.longitude
          }
        }
      },
      "travelMode": "DRIVE",
    };

    final response =
        await http.post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final points =
            _decodePolyline(data['routes'][0]['polyline']['encodedPolyline']);
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
        print('No routes found');
      }
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
          const SnackBar(
              content: Text('No results found for the search query.')),
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
        color: const Color.fromARGB(255, 50, 50, 50),
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
                focusColor: Colors.black,
                hoverColor: Colors.black,
                fillColor: Colors.black,
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
        color: const Color.fromARGB(255, 70, 70, 70),
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
        color: const Color.fromARGB(255, 214, 20, 20),
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
