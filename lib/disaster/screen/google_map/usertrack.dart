import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserTrackingDataPage extends StatefulWidget {
  const UserTrackingDataPage({super.key});

  @override
  _UserTrackingDataPageState createState() => _UserTrackingDataPageState();
}

class _UserTrackingDataPageState extends State<UserTrackingDataPage> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance
      .refFromURL(
          'https://disastermain-66982-default-rtdb.asia-southeast1.firebasedatabase.app')
      .child('users_tracking');
  Map<String, Map<String, dynamic>> _trackedUsers = {};

  @override
  void initState() {
    super.initState();
    _listenToUserLocations();
  }

  // Listen to changes in the database
  void _listenToUserLocations() {
    _databaseReference.onValue.listen((event) {
      try {
        final data = event.snapshot.value as Map?;
        print("Data fetched from Firebase: $data"); // Debugging data fetching

        if (data != null && data.isNotEmpty) {
          Map<String, Map<String, dynamic>> users = {};
          data.forEach((key, value) {
            print(
                "User ID: $key, User Data: $value"); // Debugging each user's data

            if (value is Map && value['isTracking'] == true) {
              print("Tracking data for $key: ${value['location']}");
              users[key] = {
                'latitude': value['location']?['latitude'],
                'longitude': value['location']?['longitude'],
                'isTracking': value['isTracking'],
              };
            }
          });

          if (users.isNotEmpty) {
            setState(() {
              _trackedUsers = users;
            });
            print(
                "Updated tracked users: $_trackedUsers"); // Debugging updated users
          } else {
            print("No users are currently being tracked.");
            setState(() {
              _trackedUsers.clear();
            });
          }
        } else {
          print("No data found in the database.");
          setState(() {
            _trackedUsers.clear();
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Tracking Data")),
      body: _trackedUsers.isEmpty
          ? const Center(
              child: Text("No users are being tracked."),
            )
          : ListView.builder(
              itemCount: _trackedUsers.length,
              itemBuilder: (context, index) {
                String userId = _trackedUsers.keys.elementAt(index);
                Map<String, dynamic> userData = _trackedUsers[userId]!;
                return ListTile(
                  title: Text("User: $userId"),
                  subtitle: Text(
                      "Location: Lat: ${userData['latitude']}, Lng: ${userData['longitude']}"),
                  trailing: Icon(
                    userData['isTracking'] ? Icons.check : Icons.close,
                    color: userData['isTracking'] ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
    );
  }
}
