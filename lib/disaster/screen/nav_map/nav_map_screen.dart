import 'package:drm_admin/app/ui/settings/widgets/setting_card.dart';
import 'package:drm_admin/disaster/screen/google_map/google_map.dart';
import 'package:drm_admin/disaster/screen/google_map/usertrack.dart';
import 'package:drm_admin/disaster/screen/google_map/victim_track.dart';
import 'package:drm_admin/disaster/screen/notification/fcm.dart';
import 'package:drm_admin/disaster/screen/volunteer/volunteer_list.dart';
import 'package:drm_admin/disaster/screen/volunteer/volunteer_reg.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class NavMapScreen extends StatefulWidget {
  const NavMapScreen({super.key});

  @override
  State<NavMapScreen> createState() => _NavMapScreenState();
}

class _NavMapScreenState extends State<NavMapScreen> {
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
              _buildSectionTitle('Navigation Routes'),
              Divider(
                color: Colors.grey[400],
                thickness: 1,
                endIndent: 10,
              ),
              _buildRescueTeamList(),
              _buildSectionTitle('Victim Live Track'),
              Divider(
                color: Colors.grey[400],
                thickness: 1,
                endIndent: 10,
              ),
              _buildLiveList(),
              _buildLiveTrack(),
              const SizedBox(height: 10),
              _buildSectionTitle('Send Alert'),
              Divider(
                color: Colors.grey[400],
                thickness: 1,
                endIndent: 10,
              ),
              _buildAlertSend(),
              _buildSectionTitle('Volunteer Services'),
              Divider(
                color: Colors.grey[400],
                thickness: 1,
                endIndent: 10,
              ),
              _buildVolunteerReg(),
              _buildVolunteerList(),
            ],
          ),
        ),
      ),
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

  Widget _buildRescueTeamList() {
    return SizedBox(
      height: 175,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          _buildRescueTeamCard('Safe Location', 'Kozhikode', 'Koyilandy'),
          _buildRescueTeamCard('Rescue Camp ', 'Kozhikode', 'Ulliyeri'),
        ],
      ),
    );
  }

  Widget _buildRescueTeamCard(String teamName, String location, String area) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(),
          ),
        );
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
              _buildTeamInfo(teamName, location, area),
              const Icon(Icons.arrow_forward_ios, color: Colors.redAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamInfo(String teamName, String location, String area) {
    return Column(
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
            const Icon(Icons.location_on,
                color: Colors.blue), // Changed color to blue
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
    );
  }

  Widget _buildLiveList() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.list_ul_solid),
      text: 'Victim Live List',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserTrackingDataPage(),
          ),
        );
      },
    );
  }

  Widget _buildLiveTrack() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.map_marked_solid),
      text: 'Victim Live Track',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VictimTrackingLivePage(),
          ),
        );
      },
    );
  }

  Widget _buildAlertSend() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.satellite_solid),
      text: 'Send Alert To Users',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlertInputPage(),
          ),
        );
      },
    );
  }

  Widget _buildVolunteerReg() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.person_booth_solid),
      text: 'Volunteer Registration',
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const VolunteerReg()));
      },
    );
  }

  Widget _buildVolunteerList() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.people_carry_solid),
      text: 'Volunteer List',
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => VolunteerList()));
      },
    );
  }
}
