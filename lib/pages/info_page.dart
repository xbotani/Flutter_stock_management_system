// info_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  // URLs for social media profiles
  final String linkedInUrl = 'https://www.linkedin.com/in/mohammed-botani-938031328/';
  final String githubUrl = 'https://github.com/xbotani';
  final String twitterUrl = 'https://twitter.com/xb0tani';
  final String instagramUrl = 'https://instagram.com/xbotani';


  // Function to launch URLs
  Future<void> _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define a professional color palette
    final Color primaryColor = Colors.blueGrey.shade800;
    final Color accentColor = Colors.teal.shade400;
    final Color backgroundColor = Colors.white;
    final Color textColor = Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: SizedBox.shrink(), // Removed 'Portfolio' title
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section: Name and Title
              _buildHeaderSection(primaryColor, accentColor, textColor),
              SizedBox(height: 40),

              // Contact Information Section
              _buildContactInfoSection(accentColor, textColor),
              SizedBox(height: 40),

              // About Me Section
              _buildAboutMeSection(textColor),
              SizedBox(height: 40),

              // Social Media Links Section
              _buildSocialMediaSection(accentColor),
              // Removed Resume Section
            ],
          ),
        ),
      ),
    );
  }

  /// Header Section: Displays Name and Title
  Widget _buildHeaderSection(Color primaryColor, Color accentColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mohammed Botani',
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Cybersecurity & programming Enthusiast',
          style: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
      ],
    );
  }

  /// Contact Information Section: Displays Contact Details with Icons
  Widget _buildContactInfoSection(Color accentColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        SizedBox(height: 20),
        Divider(color: accentColor, thickness: 1),
        SizedBox(height: 20),
        _buildInfoRow(
          icon: Icons.phone,
          title: 'Phone Number',
          content: '+96407503056978',
          textColor: textColor,
        ),
        SizedBox(height: 15),
        _buildInfoRow(
          icon: Icons.email,
          title: 'Email',
          content: 'botanimuhamed@gmail.com',
          textColor: textColor,
        ),
        SizedBox(height: 15),
        _buildInfoRow(
          icon: Icons.web,
          title: 'Social Media',
          content: '@xbotani (YouTube, Telegram, Instagram, TikTok, GitHub)',
          textColor: textColor,
        ),
      ],
    );
  }

  /// About Me Section: Brief Introduction
  Widget _buildAboutMeSection(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Me',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey.shade800,
          ),
        ),
        SizedBox(height: 20),
        Divider(color: Colors.blueGrey.shade800, thickness: 1),
        SizedBox(height: 20),
        Text(
          'I am Mohammed Botani, also known as xbotani on social media platforms. '
          'I am a passionate developer who loves to create innovative and futuristic desktop applications. '
          'For any further information, you can contact me through any of the methods provided above.',
          style: GoogleFonts.openSans(
            fontSize: 18,
            color: textColor,
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  /// Social Media Links Section: Interactive Icons
  Widget _buildSocialMediaSection(Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect with Me',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        SizedBox(height: 20),
        Divider(color: accentColor, thickness: 1),
        SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            // LinkedIn
            _socialIcon(
              icon: FontAwesomeIcons.linkedin,
              color: Colors.blue.shade700,
              url: linkedInUrl,
              tooltip: 'LinkedIn',
            ),
            // GitHub
            _socialIcon(
              icon: FontAwesomeIcons.github,
              color: Colors.black,
              url: githubUrl,
              tooltip: 'GitHub',
            ),
            // Twitter/X
            _socialIcon(
              icon: FontAwesomeIcons.twitter,
              color: Colors.lightBlue,
              url: twitterUrl,
              tooltip: 'Twitter',
            ),
            // Instagram
            _socialIcon(
              icon: FontAwesomeIcons.instagram,
              color: Colors.pink,
              url: instagramUrl,
              tooltip: 'Instagram',
            ),
            // YouTube
            _socialIcon(
              icon: FontAwesomeIcons.youtube,
              color: Colors.red,
              url: 'https://www.youtube.com/channel/UCndAheOlvqBBEFKlsRJsSzw',
              tooltip: 'YouTube',
            ),
            // Telegram
            _socialIcon(
              icon: FontAwesomeIcons.telegram,
              color: Colors.blue.shade300,
              url: 'https://t.me/xbotani',
              tooltip: 'Telegram',
            ),
            // TikTok
            _socialIcon(
              icon: FontAwesomeIcons.tiktok,
              color: Colors.black,
              url: 'https://www.tiktok.com/@xbotani',
              tooltip: 'TikTok',
            ),
          ],
        ),
      ],
    );
  }

  /// Helper Widget: Creates a styled social media icon button
  Widget _socialIcon({
    required IconData icon,
    required Color color,
    required String url,
    required String tooltip,
  }) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: CircleAvatar(
        radius: 30,
        backgroundColor: color.withOpacity(0.1),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }

  /// Helper Widget: Builds a row with icon, title, and content
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    required Color textColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blueGrey.shade800, size: 28),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              SizedBox(height: 5),
              Text(
                content,
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  color: Colors.blueGrey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
