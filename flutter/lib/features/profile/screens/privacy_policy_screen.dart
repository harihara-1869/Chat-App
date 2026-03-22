import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildIntroduction(context),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.remove_red_eye_outlined,
              title: "1. Information We Collect",
              intro: "We may collect the following categories of information:",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubsectionTitle(context, "1.1 Account Information"),
                  _buildBullets([
                    "Name",
                    "Email address",
                    "Profile picture (if provided)",
                    "Authentication provider information (e.g., Google ID)",
                  ]),
                  _buildSubsectionTitle(context, "1.2 Communication Data"),
                  _buildBullets([
                    "Messages sent through the Platform",
                    "Images uploaded by users",
                  ]),
                  _buildWarning(
                    context,
                    "Messages are stored in plain text format and are not end-to-end encrypted.",
                  ),
                  _buildSubsectionTitle(context, "1.3 Technical Information"),
                  _buildBullets([
                    "IP address",
                    "Browser type",
                    "Device information",
                    "Basic usage logs",
                  ]),
                  _buildNote(
                    context,
                    "This information may be automatically collected for security and operational purposes.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.my_location_outlined,
              title: "2. How We Use Your Information",
              intro: "We use collected information to:",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBullets([
                    "Create and manage user accounts",
                    "Enable messaging functionality",
                    "Store and display uploaded images",
                    "Maintain platform security",
                    "Monitor technical performance",
                    "Comply with legal obligations",
                  ]),
                  _buildNote(
                    context,
                    "We do not sell, rent, or commercially trade your personal data.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.cloud_outlined,
              title: "3. Image Hosting and Third-Party Services",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildParagraph(
                      "Uploaded images may be stored using third-party cloud storage providers such as Cloudinary."),
                  _buildIntro2(context, "Images:"),
                  _buildBullets([
                    "May be accessible via publicly accessible URLs",
                    "Are subject to the third-party provider's infrastructure and policies",
                  ]),
                  _buildWarning(
                    context,
                    "We are not responsible for the independent privacy practices of third-party services. Users are advised not to upload sensitive or confidential content.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.lock_outline,
              title: "4. Data Storage and Security",
              intro: "We implement reasonable technical and organizational safeguards to protect user information.",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntro2(context, "However:"),
                  _buildBullets([
                    "Messages are stored in plain text",
                    "Internet transmission carries inherent risks",
                    "No system can guarantee absolute security",
                  ]),
                  _buildWarning(
                    context,
                    "Users should avoid sharing highly sensitive personal information through the Platform.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.people_outline,
              title: "5. Data Sharing",
              intro: "We may share information only in the following situations:",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBullets([
                    "With hosting or infrastructure providers strictly for service operation",
                    "When required by law, court order, or governmental authority",
                    "To protect the rights, safety, or integrity of the Platform",
                  ]),
                  _buildNote(
                    context,
                    "We do not intentionally disclose personal data to unrelated third parties for marketing or advertising.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.storage_outlined,
              title: "6. Data Retention",
              intro: "We retain personal data:",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBullets([
                    "For as long as your account remains active",
                    "For operational, security, or legal purposes",
                  ]),
                  _buildWarning(
                    context,
                    "As this is a demo application, data may be deleted, reset, or removed at any time without prior notice. Users may request deletion of their account by contacting us.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.balance_outlined,
              title: "7. Your Rights (Under Indian Law)",
              intro:
                  "In accordance with applicable Indian data protection principles, including the Digital Personal Data Protection Act, 2023, you may have the right to:",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBullets([
                    "Request access to your personal data",
                    "Request correction of inaccurate information",
                    "Request deletion of your personal data",
                    "Withdraw consent for data processing",
                  ]),
                  _buildNote(
                    context,
                    "Requests may be sent to: harihara1869@gmail.com - We will respond within a reasonable time.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.child_care_outlined,
              title: "8. Children's Privacy",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildParagraph("This Platform is not intended for individuals under 18 years of age."),
                  _buildParagraph("We do not knowingly collect personal data from minors."),
                  _buildParagraph("If we become aware that a minor has provided personal information, we may delete such data."),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.public_outlined,
              title: "9. International Data Transfers",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildParagraph(
                      "If third-party infrastructure providers store data outside India, your data may be transferred to and processed in other jurisdictions."),
                  _buildParagraph(
                      "By using the Platform, you consent to such transfers where necessary for service operation."),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.warning_amber_rounded,
              title: "10. Disclaimer (Demo Nature)",
              titleColor: Colors.orange,
              intro: "This Platform is a demo and portfolio project.",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntro2(context, "It is not intended for production-grade confidential communications."),
                  const SizedBox(height: 4),
                  _buildIntro3(context, "Users acknowledge that:"),
                  _buildBullets([
                    "Security features may be limited",
                    "The Platform may be modified or discontinued at any time",
                    "Data may be deleted as part of development or maintenance",
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.autorenew_outlined,
              title: "11. Changes to This Policy",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildParagraph("We may update this Privacy Policy at any time."),
                  _buildParagraph("Continued use of the Platform after changes constitutes acceptance of the revised Policy."),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildContactInfo(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.shield_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Effective Date: February 13, 2026',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(153),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntroduction(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Introduction',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildParagraph('This Privacy Policy describes how Talkio ("Platform", "we", "our", or "us") collects, uses, and protects your information.'),
            _buildParagraph('The Platform is operated by P R Hari Hara Sai Pratham, located in India.'),
            _buildParagraph('This Platform is a demo and portfolio project developed for demonstration and educational purposes.'),
            const SizedBox(height: 8),
            Text(
              'By using the Platform, you agree to this Privacy Policy.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(204),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? titleColor,
    String? intro,
    required Widget content,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: titleColor ?? Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (intro != null) ...[
              _buildParagraph(intro),
              const SizedBox(height: 8),
            ],
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildSubsectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(height: 1.5, color: Colors.black87), // Assuming light theme mostly, or use context colors
      ),
    );
  }

  Widget _buildIntro2(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(height: 1.5, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildIntro3(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(height: 1.5, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBullets(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    color: Colors.blue, // Primary color approximation
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWarning(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withAlpha(76)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.orange, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNote(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.grey),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.mail_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Contact Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildParagraph('For privacy-related concerns, contact:'),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('P R Hari Hara Sai Pratham', style: TextStyle(height: 1.5)),
                  Text('📧 harihara1869@gmail.com', style: TextStyle(height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
