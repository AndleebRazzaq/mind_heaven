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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white54, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.reply_rounded, color: Colors.white54, size: 20),
            label: const Text(
              'share',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Safety',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Emergency resources',
              style: TextStyle(
                color: Color(0xFFB4C6FC),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "If you are experiencing a mental health crisis, you are not alone. There are immediate and long-term actions you can take to keep yourself safe.",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Immediate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8),
                title: const Text(
                  'Connect with a crisis line',
                  style: TextStyle(
                    color: Color(0xFFB4C6FC),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                iconColor: const Color(0xFFB4C6FC),
                collapsedIconColor: const Color(0xFFB4C6FC),
                children: [
                  _buildActionCard(
                    title: "National Suicide Prevention Lifeline",
                    subtitle: "Call or text 988",
                    onTap: () => _makePhoneCall('988'),
                  ),
                  _buildActionCard(
                    title: "Crisis Text Line",
                    subtitle: "Text HOME to 741741",
                    onTap: () => _sendSms('741741', 'HOME'),
                  ),
                  _buildActionCard(
                    title: "The Trevor Project",
                    subtitle: "Call 1-866-488-7386",
                    onTap: () => _makePhoneCall('18664887386'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8),
                title: const Text(
                  'Go to the emergency room (ER)',
                  style: TextStyle(
                    color: Color(0xFFB4C6FC),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                iconColor: const Color(0xFFB4C6FC),
                collapsedIconColor: const Color(0xFFB4C6FC),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      "If you feel you cannot keep yourself safe, go to the nearest hospital emergency room. Let them know you are experiencing a mental health emergency.",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8),
                title: const Text(
                  'Call 911 or your local emergency number',
                  style: TextStyle(
                    color: Color(0xFFB4C6FC),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                iconColor: const Color(0xFFB4C6FC),
                collapsedIconColor: const Color(0xFFB4C6FC),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      "If you are in immediate medical danger or have already harmed yourself, call 911 or your local emergency number right away.",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 40),
            const Text(
              'Long-term',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              title: const Text(
                'Find a therapist or psychiatrist',
                style: TextStyle(
                  color: Color(0xFFB4C6FC),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFB4C6FC), size: 16),
              onTap: () {},
            ),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 100), // spacing for bottom nav if present
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
        trailing: const Icon(Icons.call_made_rounded, color: Colors.white54, size: 20),
      ),
    );
  }
}
