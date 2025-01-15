import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';

class AlertInputPage extends StatefulWidget {
  const AlertInputPage({super.key});

  @override
  _AlertInputPageState createState() => _AlertInputPageState();
}

class _AlertInputPageState extends State<AlertInputPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<String?> getAccessTokenFromDatabase() async {
    final databaseReference = FirebaseDatabase.instance.ref();

    try {
      DataSnapshot snapshot =
          await databaseReference.child('tokens/accessToken').get();
      if (snapshot.exists) {
        return snapshot.value.toString();
      } else {
        print("No access token found in database.");
        return null;
      }
    } catch (e) {
      print("Error fetching access token from database: $e");
      return null;
    }
  }

  Future<void> uploadImageToFirebase() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      try {
        setState(() {
          _isUploading = true;
          _uploadProgress = 0.0;
        });

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');

        final uploadTask = storageRef.putFile(file);

        // Monitor upload progress
        uploadTask.snapshotEvents.listen((event) {
          setState(() {
            _uploadProgress =
                event.bytesTransferred / event.totalBytes.toDouble();
          });
        });

        // Get the download URL after upload is complete
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _imageUrlController.text = downloadUrl;
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      } catch (e) {
        setState(() {
          _isUploading = false;
        });

        print("Error uploading image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    }
  }

  Future<void> sendNotification(
      String title, String body, String imageUrl, String token) async {
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
          'image': imageUrl, // Include image URL in payload
        },
      },
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: bodyData);
    if (response.statusCode == 200) {
      print('Notification sent successfully');

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
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
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
              ),
              readOnly: true, // Prevent manual editing of URL
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: uploadImageToFirebase,
              child: const Text('Upload Image'),
            ),
            if (_isUploading)
              Column(
                children: [
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _uploadProgress),
                  const SizedBox(height: 8),
                  Text('${(_uploadProgress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text.trim();
                final body = _bodyController.text.trim();
                final imageUrl = _imageUrlController.text.trim();
                if (title.isEmpty || body.isEmpty || imageUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Title, body, and image are required')),
                  );
                  return;
                }
                sendNotification(title, body, imageUrl, '');
              },
              child: const Text('Send Alert to users'),
            ),
          ],
        ),
      ),
    );
  }
}
