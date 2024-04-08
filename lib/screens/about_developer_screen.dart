import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutDeveloper extends StatelessWidget {
  const AboutDeveloper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Developer'),
      ),
      body: Center( 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container( 
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: AssetImage('lib/assets/profile.png'),
                  fit: BoxFit.cover, 
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.6),
                    spreadRadius: 4,
                    blurRadius: 8,
                    offset: const Offset(0, 4), 
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 18),
            const Text(
              "Hey  There, \nI'm  Reynold  Preetham!  👋🏼",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'plusJakartaSans'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            const Text(
              "𝘐'𝘮 𝘢 𝘊𝘺𝘣𝘦𝘳 𝘚𝘦𝘤𝘶𝘳𝘪𝘵𝘺 𝘚𝘵𝘶𝘥𝘦𝘯𝘵, 𝘸𝘪𝘵𝘩 𝘢 𝘱𝘢𝘴𝘴𝘪𝘰𝘯 𝘧𝘰𝘳 𝘚𝘰𝘧𝘵𝘸𝘢𝘳𝘦 \n𝘢𝘯𝘥 𝘍𝘭𝘶𝘵𝘵𝘦𝘳 𝘋𝘦𝘷𝘦𝘭𝘰𝘱𝘮𝘦𝘯𝘵.",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.github),
                  onPressed: () => _launchURL('https://github.com/Reynold29'),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.telegram),
                  onPressed: () => _launchURL('https://t.me/Reynold29'), 
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.circleUser),
                  onPressed: () => _launchURL('https://portfolio-reynold29.vercel.app/'), 
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.globe),
                  onPressed: () => _launchURL('https://reynold29.github.io/linkfree/'), 
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Debug Area
    }
  }
}
