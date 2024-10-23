import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlertInputPage extends StatefulWidget {
  @override
  _AlertInputPageState createState() => _AlertInputPageState();
}

class _AlertInputPageState extends State<AlertInputPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  Future<void> sendNotification(String title, String body) async {
    final url =
        'https://fcm.googleapis.com/v1/projects/disastermain-66982/messages:send';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer ya29.c.c0ASRK0GZmtRj4A2F3hgWb4o-JH0PZynyhg9APv4i-d7rlJiZi5hphLbiaZVuQgdfmM7Vkpovgeby1-ZhjHAEF_okiR40Epue-qwD1O7ayTrSJXXGzqXpoaDuoYU-BNVdKJRdlv8jhAEgzL5_yUFse6gH64ORxcc9yjnnsRXCaa1hdIAduiTkwYB3TuAEnL0Tx4wUyMIvmKJ7G_brRo7tM2Q1h7Twep6Fy-JsQz_5xa0T52LPyouVx1kzMxffcg8vwqe8xsICOMJ9DXVzJwgcy3GBoBwpxJvZDJWGHqjiDysj_IfdIFB3PV9t8mwKgWls3JXLkqUwKk9w4hJ5gXBImTh0qE8fH0yyEgHU7t5vzOdoxKHT4FamGv28N384C1_-gR_sQkrBks984FU2F0fxddcqurhOx_igFQlWmk2a4Xd0loaJqZMMi3isdl5-5r0q-dmv1zSwz3uMjZBao4mMd-ZdlI1dkZSlgoRBBOiU2iWsJOo66onvbBJXZZtuoF3vuUmU5R-prbId9hFpX-vYwjvUqmqjwJ3_k49SY7Y3lomao8yQbpUIsOQIty0ksmzm3SrOukf2j9jOV5UljOgym5pdWd4wXM9oqhiI8aF3IfRQxXBi47gtjiRbJts2uQ7rb8os4UJpFd1dsr3dfWndd6jtirlm7kRgv84yF2z9MkuZ88xfMyguB6lnvmnhJZMe0jSk5Z6oykX1JZ7_yRS1uS1ucsjnM8xaxJnQOJ-z9uxy4-W8wfpi3rt2fw5OS-tjk32Xtkar7RXtq4hh9Y-Y1a8QVbR3c4Ym7vQh1njsYfi154Biup576XhWVheW8-z7p2w2Xc0Jk95ZWbk_8uBJgX8JwBiQovrhXt0f640lls2WXfed2qbJhq03WbM6tJjeM46nVwX0QzRdVpfqavyR9ojg0O67rtp3YzpbUf6IYf91tx7c9bIeaOW_tZsuM64X7mgXWMR6OSSyOU7kQ5Ufu0F9X3FxaIzeQRm_Rp899VZRlgf9Uo-eQUVJ',
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
        title: Text('Alert Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Notification Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: 'Notification Body',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text;
                final body = _bodyController.text;
                sendNotification(title, body);
              },
              child: Text('Send Notification to All Users'),
            ),
          ],
        ),
      ),
    );
  }
}
