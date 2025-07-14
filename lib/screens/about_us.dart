import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  final members = [
    {
      'name': 'Ashrafy',
      'roll': '43',
      'email': 'ashrafy193945@gmail.com',
      'photo': 'assets/images/ash.jpg',
    },
    {
      'name': 'Aditto',
      'roll': '09',
      'email': 'aditto-2022815884@cs.du.ac.bd',
      'photo': 'assets/images/adi.jpg',
    },
    {
      'name': 'Labonya',
      'roll': '37',
      'email': 'labonyapal@gmail.com',
      'photo': 'assets/images/lab.jpg',
    },
    {
      'name': 'Anik',
      'roll': '53',
      'email': 'abulhasananik2@gmail.com',
      'photo': 'assets/images/anik.jpg',
    },
  ];

  void _launchEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunchUrl(Uri.parse(url))) {
      launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch email client';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About Us")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Awaj",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: members.map((member) {
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(member['photo']!),
                        radius: 30,
                      ),
                      title: Text(member['name']!),
                      subtitle: Text("Roll: ${member['roll']}"),
                      trailing: InkWell(
                        child: Text(
                          member['email']!,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                        onTap: () => _launchEmail(member['email']!),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
