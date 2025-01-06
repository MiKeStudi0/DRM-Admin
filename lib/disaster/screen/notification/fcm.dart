import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlertInputPage extends StatefulWidget {
  const AlertInputPage({super.key});

  @override
  _AlertInputPageState createState() => _AlertInputPageState();
}

class _AlertInputPageState extends State<AlertInputPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final String accessToken =
      "ya29.c.c0ASRK0GbFeAy19oai1HGQtHX1KcIOr-D46eSDegG5hPqlCnD2AVGbE0tuo8Kw5SUmVczESWM_hkgLpYxiU8Z3zS29zgNhGWk_pold-CWCvl9WrRYciv6QHwiy1U_OMG3m_IpXl2HOsovztXKWDrycKQ-Xyn0qPmujc4Uord54glxcbCbtsOZjuq2xHrEqKDspoCAvkNrIfC43TJfb0myEfHALzsu0C3gHyVoMY22lHryr5MyyedGUiTTfCDvX2KH1N57mOuo2KRudBuPy551WSlIHsIvmXu_jQbRvr8XoKsWNw66PXo9dNu_b8MJt-xuyXdkeQ7_SQeHXFdVDPiQVJZj_6vjeY9j2G91v8YgZrud8lXiKzA8tOahBRgG387Pfak0Xwuysg6vrB4Ybp2-JYfrmgieB3oY3-JplQ4yVyy8y-86kVpwx_fuiwo6XSZ-ydwa0aaz_femR5b6yg36kZ2f0Xj9M8FtwzbfUx5g7aVa5y7qzQ705caXjRM4fjWeF7-ukz16McVshhR3Uy2Y-27c6r56-p9izt7ifmikwsB0SlwIro24M6ide305dqaSfFI8gkQxQk0ZWrWzo0cfllvwXwVm-7qd3O6tYJxJac2csOXIVBgJn2UXdOj21brmIhiOXY2trSqd_io_M_xF2cu2x20rgS3I9ntbnX7h2-bjt7_sobOdWSISa9QhxqXxvB6hysmm57nJWvpXe_ORnilgrhsXeqJbadjjgQBiRZW9aOjo6y_Fasq179Yb7VflaR3t0MwelJSch55JwjfJOsq1Q5cQQby5fkuo5os_-ocSsfguBnnZhOMRraW5pMbtv2-gt6ZR4RgzpdOxp0076aRsSSjJ7Mq7ZVRsh2jwSZeB_a6-Mrm5ZqnfwQyV-qMVq0BRiFjaeghgug3wXM1XvZJ08Wyhdj-rWor6vRJZs5M2eaon06nojQrJ3ZOj2Jy0xo-XyqiJi93yXxj5iFRM8Wk04gfUhme3Spl93BRdv5XZvtl8Usb-YXO";

  Future<void> sendNotification(String title, String body) async {
    final url =
        'https://fcm.googleapis.com/v1/projects/disastermain-66982/messages:send';

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
                sendNotification(title, body);
              },
              child: const Text('Send Notification to All Users'),
            ),
          ],
        ),
      ),
    );
  }
}
