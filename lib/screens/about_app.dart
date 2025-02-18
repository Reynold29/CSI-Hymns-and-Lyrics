import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hymns_latest/screens/about_developer_screen.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About This App',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontFamily: 'plusJakartaSans',
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: GestureDetector(
          onTap: () async { 
            const url = 'https://play.google.com/store/apps/details?id=com.reyzie.hymns';
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url));
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'lib/assets/icons/logo.png',
                  height: 100,
                  width: 100,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'CSI Hymns Book',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'plusJakartaSans',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "A Kannada CSI Hymns and Keerthane Lyrics Book, with modern minimal UI and functionalities.",
                style: TextStyle(fontSize: 15, fontFamily: 'plusJakartaSans'),
              ),
              const Divider(height: 50),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutDeveloper()),
                );
              },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developed By',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'plusJakartaSans',
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Reynold  (@Reynold29)',
                      style: TextStyle(fontSize: 15, fontFamily: 'plusJakartaSans'),
                    ),
                    SizedBox(height: 25),
                    _ContributeSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContributeSection extends StatelessWidget {
  const _ContributeSection();

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 10),
        const SizedBox(height: 20),
        const Text(
          'Contribute',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'plusJakartaSans'),
        ),
        const SizedBox(height: 6),
        const Text(
          "This app is Open Source!  Contribute to the project's code and let's enhance it !   ;) ",
          style: TextStyle(fontSize: 15, fontFamily: 'plusJakartaSans'),
        ),
        const SizedBox(height: 14), 
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
          children: [
            ElevatedButton.icon( 
              icon: const FaIcon(FontAwesomeIcons.github),
              label: const Text('GitHub'), 
              onPressed: () => _launchURL('https://github.com/Reynold29/CSI-Hymns-and-Lyrics/'), 
            ),
            const SizedBox(width: 5), 
            ElevatedButton.icon(
              icon: const FaIcon(FontAwesomeIcons.googlePlay),
              label: const Text('PlayStore'), 
              onPressed: () => _launchURL('https://play.google.com/store/apps/details?id=com.reyzie.hymns'), 
            ),
          ]
        ),
        const SizedBox(height: 25),
        const _Support(),
      ],
    );
  }
}

class _Support extends StatelessWidget {
  const _Support();

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 10),
        const SizedBox(height: 20),
        const Text(
          'Support',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'plusJakartaSans'),
        ),
        const SizedBox(height: 6),
        const Text(
          "Get Support Here and also find out how we Prioritize User Privacy and Data!",
          style: TextStyle(fontSize: 15, fontFamily: 'plusJakartaSans'),
        ),
        const SizedBox(height: 12), 
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const FaIcon(FontAwesomeIcons.telegram),
              label: const Text('Telegram'), 
              onPressed: () => _launchURL('https://t.me/Reynold29'), 
            ),
            const SizedBox(width: 5),
            ElevatedButton.icon(
              icon: const FaIcon(FontAwesomeIcons.question),
              label: const Text('Privacy Policy'), 
              onPressed: () => _launchURL('https://sites.google.com/view/csi-hymns-privacy-policy/home'), 
            ),
          ]
        ),
      ],
    );
  }
}
