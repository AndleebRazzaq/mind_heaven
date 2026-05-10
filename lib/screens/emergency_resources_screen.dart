import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyResourcesScreen extends StatelessWidget {
  const EmergencyResourcesScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Could not launch
    }
  }

  Future<void> _sendSms(String phoneNumber, String body) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: <String, String>{
        'body': body,
      },
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Could not launch
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101216),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Emergency Support',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_rounded,
              color: Color(0xFFEF5350),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              "You are not alone.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "If you are feeling overwhelmed, having thoughts of self-harm, or experiencing a crisis, please reach out immediately. Help is available 24/7.",
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildResourceCard(
              title: "National Suicide Prevention Lifeline",
              description: "Free, confidential support for people in distress, prevention and crisis resources.",
              contactInfo: "Call or text 988",
              icon: Icons.phone_in_talk_rounded,
              onTap: () => _makePhoneCall('988'),
            ),
            const SizedBox(height: 16),
            _buildResourceCard(
              title: "Crisis Text Line",
              description: "Connect with a volunteer Crisis Counselor 24/7, free, confidential text message service.",
              contactInfo: "Text HOME to 741741",
              icon: Icons.message_rounded,
              onTap: () => _sendSms('741741', 'HOME'),
            ),
            const SizedBox(height: 16),
            _buildResourceCard(
              title: "The Trevor Project",
              description: "Crisis intervention and suicide prevention for LGBTQ youth.",
              contactInfo: "Call 1-866-488-7386",
              icon: Icons.support_agent_rounded,
              onTap: () => _makePhoneCall('18664887386'),
            ),
            const SizedBox(height: 16),
            _buildResourceCard(
              title: "Veterans Crisis Line",
              description: "Confidential crisis support for Veterans and their loved ones.",
              contactInfo: "Call 988 and press 1",
              icon: Icons.local_hospital_rounded,
              onTap: () => _makePhoneCall('988'),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "If this is an immediate medical emergency, please call 911 or go to the nearest emergency room.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard({
    required String title,
    required String description,
    required String contactInfo,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEF5350).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEF5350).withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF5350).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFFEF5350), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        contactInfo,
                        style: const TextStyle(
                          color: Color(0xFFEF5350),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
