import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class victimlocation extends StatefulWidget {
  @override
  _victimlocationState createState() => _victimlocationState();
}

class _victimlocationState extends State<victimlocation> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  TextEditingController _searchController = TextEditingController();
  LatLng _searchedLocation = LatLng(0, 0);

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

  Future<void> _searchLocation(String searchText) async {
    if (searchText.isEmpty) return;

    final String apiKey = 'AIzaSyBJMhMpJEZEN2fubae-mdIZ-vCEXOAkHMk';
    final String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$searchText&inputtype=textquery&fields=geometry&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['candidates'].isNotEmpty) {
        final lat = jsonData['candidates'][0]['geometry']['location']['lat'];
        final lng = jsonData['candidates'][0]['geometry']['location']['lng'];
        LatLng position = LatLng(lat, lng);

        print(position);
        _moveCamera(position);
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
      CameraPosition(target: position, zoom: 10.0),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Location on Map'),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _searchLocation(_searchController.text);
                    },
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
