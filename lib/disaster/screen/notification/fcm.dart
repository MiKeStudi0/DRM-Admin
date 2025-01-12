import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:firebase_database/firebase_database.dart';

class AlertInputPage extends StatefulWidget {
  const AlertInputPage({super.key});

  @override
  _AlertInputPageState createState() => _AlertInputPageState();
}

class _AlertInputPageState extends State<AlertInputPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String accessToken = "";

  Future<String?> getAccessTokenFromDatabase() async {
    final databaseReference = FirebaseDatabase.instance.ref();

    try {
      DataSnapshot snapshot =
          await databaseReference.child('tokens/accessToken').get();
      if (snapshot.exists) {
        return snapshot.value.toString(); // Return the value if it exists
      } else {
        print("No access token found in database.");
        return null;
      }
    } catch (e) {
      print("Error fetching access token from database: $e");
      return null;
    }
  }

  Future<void> sendNotification(String title, String body, String token) async {
    final url =
        'https://fcm.googleapis.com/v1/projects/disastermain-66982/messages:send';
    final accessToken = await getAccessTokenFromDatabase();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final bodyData = json.encode({
      'message': {
        'topic': 'all',
        'notification': {
          'title': title,
          'body': body,
        },
      },
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: bodyData);
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Notification Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Notification Body',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text;
                final body = _bodyController.text;
                sendNotification(title, body, accessToken);
              },
              child: const Text('Send Notification to All Users'),
            ),
          ],
        ),
      ),
    );
  }
}
