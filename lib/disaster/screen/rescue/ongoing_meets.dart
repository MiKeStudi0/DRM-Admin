import 'package:drm_admin/app/ui/settings/widgets/setting_card.dart';
import 'package:drm_admin/disaster/screen/bar%20charts/Charts.dart';
import 'package:drm_admin/disaster/screen/google_map/google_map.dart';
import 'package:drm_admin/disaster/screen/google_map/victim_location.dart';
import 'package:drm_admin/disaster/screen/rescue/vedioconf.dart';
import 'package:drm_admin/disaster/screen/sos_screen/alert_shake.dart';
import 'package:drm_admin/disaster/screen/static/static_awarness.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OngoingScreen extends StatefulWidget {
  const OngoingScreen({super.key});

  @override
  State<OngoingScreen> createState() => _OngoingScreenState();
}

class _OngoingScreenState extends State<OngoingScreen> {
  int index = 0;
  bool _isExpanded = false;

  // List of helpline numbers
  final List<Map<String, String>> _helplineNumbers = [
    {'department': 'Police', 'number': '100'},
    {'department': 'Fire Department', 'number': '101'},
    {'department': 'Ambulance', 'number': '102'},
    {'department': 'Disaster Management Services', 'number': '108'},
    {'department': 'National Emergency Number', 'number': '112'},
    {'department': 'Women Helpline', 'number': '1091'},
    {'department': 'Child Helpline', 'number': '1098'},
    {'department': 'Senior Citizen Helpline', 'number': '14567'},
    {'department': 'Tourist Helpline', 'number': '1363'},
    {'department': 'Railway Helpline', 'number': '139'},
    {'department': 'Mental Health Helpline', 'number': '9152987821'},
    {'department': 'LPG Leak Helpline', 'number': '1906'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Rescue Teams Nearby'),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => _showAddRescueTeamBottomSheet(context),
                  ),
                ],
              ),
              Divider(
                color: Colors.grey[400],
                thickness: 1,
                endIndent: 10,
              ),
              _buildRescueTeamList(),
              Divider(
                color: Colors.grey[400],
                thickness: 1,
                endIndent: 10,
              ),
              _buildSectionTitle('Victim Location'),
              const SizedBox(
                height: 5,
              ),
              _buildvitcim(),
              const SizedBox(
                height: 5,
              ),
              Divider(
                color: Colors.grey[400],
                thickness: 1,
                endIndent: 10,
              ),
              _buildSectionTitle('Important Information'),
               _buildBarChart(),
              _buildStaticInformation(),
             
              const SizedBox(height: 24),
              
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ShakeLocationPage(),
            ),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.crisis_alert_sharp),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Future<void> _showAddRescueTeamBottomSheet(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController areaController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add Rescue Team',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Team Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Location',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: areaController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Area',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final String name = nameController.text.trim();
                      final String location = locationController.text.trim();
                      final String area = areaController.text.trim();
                
                      if (name.isNotEmpty && location.isNotEmpty && area.isNotEmpty) {
                        await FirebaseFirestore.instance.collection('rescue_teams').add({
                          'name': name,
                          'location': location,
                          'area': area,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Rescue Team added successfully!'),
                          ),
                        );
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all fields.'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Team',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Fetch data dynamically from Firebase Firestore
Widget _buildRescueTeamList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('rescue_teams').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text('No rescue teams available.'));
      }

      // Extract documents from snapshot
      final rescueTeams = snapshot.data!.docs;

      return ListView.builder(
        shrinkWrap: true,
        itemCount: rescueTeams.length,
        itemBuilder: (context, index) {
          final team = rescueTeams[index].data() as Map<String, dynamic>;

          // Ensure attributes are available
          final teamName = team['name'] ?? 'Unknown Team';
          final location = team['location'] ?? 'Unknown Location';
          final area = team['area'] ?? 'Unknown Area';

          return _buildRescueTeamCard(teamName, location, area);
        },
      );
    },
  );
}

Widget _buildRescueTeamCard(String teamName, String location, String area) {
  return GestureDetector(
    onTap: () {
      _showCodeInputDialog(context, index);
      setState(() {
        index += 1;
      });
    },
    child: Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teamName,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(location,
                        style: const TextStyle(fontSize: 14.0, color: Colors.white)),
                    const SizedBox(width: 8),
                    const Icon(Icons.track_changes_outlined, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(area,
                        style: const TextStyle(fontSize: 14.0, color: Colors.white)),
                  ],
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.redAccent),
          ],
        ),
      ),
    ),
  );
}


 
  Widget _buildStaticInformation() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.book_dead_solid),
      text: 'Awareness',
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const StaticdataScreen()));
      },
    );
  }

  Widget _buildBarChart() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.bars_solid),
      text: 'Donate Resources',
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) =>  Charts()));
      },
    );
  }




  Widget _buildvitcim() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VictimLocation(),
            ));
      },
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SOS Victims",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey),
                      SizedBox(width: 4),
                      Text("India",
                          style:
                              TextStyle(fontSize: 14.0, color: Colors.white)),
                      SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.redAccent),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCodeInputDialog(BuildContext context, int index) async {
    String enteredCode = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Code to verify'),
          content: TextField(
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Enter code'),
            onChanged: (value) {
              enteredCode = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _codeConfirm(enteredCode, context, index);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _codeConfirm(String enteredCode, BuildContext context, int index) {
    if (enteredCode == '1234') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const VideoConferencePage(conferenceID: '12345'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect code')),
      );
    }
  }
}
