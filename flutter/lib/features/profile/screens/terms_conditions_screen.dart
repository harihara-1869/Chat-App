import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
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
              icon: Icons.info_outline,
              title: "1. Nature of the Platform",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildParagraph("This Platform is a demo and portfolio project developed for educational, evaluation, and demonstration purposes."),
                  _buildIntro2(context, "The Platform:"),
                  _buildBullets([
                    "Is not a commercial messaging service",
                    "Is not intended for sensitive, confidential, financial, medical, or legal communication",
                    "May be modified, suspended, or discontinued at any time without notice",
                  ]),
                  _buildNote(
                    context,
                    "Users acknowledge that the Platform is provided primarily for demonstration purposes.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.people_outline,
              title: "2. Eligibility",
              intro: "By using the Platform, you confirm that:",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBullets([
                    "You are at least 18 years of age; or",
                    "You are using the Platform under lawful supervision",
                    "You are legally competent to enter into a binding agreement under Indian law",
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.shield_outlined,
              title: "3. User Accounts",
              intro: "To use certain features, you may be required to create an account.",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntro2(context, "You agree to:"),
                  _buildBullets([
                    "Provide accurate and complete information",
                    "Maintain the confidentiality of your login credentials",
                    "Notify us immediately of any unauthorized access",
                  ]),
                  _buildParagraph("You are responsible for all activities conducted through your account."),
                  _buildWarning(
                    context,
                    "We reserve the right to suspend or terminate accounts that violate these Terms.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.remove_red_eye_outlined,
              title: "4. Data Storage and Security",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubsectionTitle(context, "4.1 Message Storage"),
                  _buildParagraph("Messages exchanged through the Platform are currently stored in plain text format within our database."),
                  _buildParagraph("The Platform does not provide end-to-end encryption."),
                  _buildWarning(
                    context,
                    "Users are strongly advised not to share sensitive or confidential information through the Platform.",
                  ),
                  const SizedBox(height: 4),
                  _buildSubsectionTitle(context, "4.2 Image Uploads"),
                  _buildParagraph("Images uploaded by users may be hosted using Cloudinary or similar third-party storage services."),
                  _buildIntro2(context, "Uploaded images:"),
                  _buildBullets([
                    "May be accessible via public URLs",
                    "May not be protected by private access controls",
                    "Are subject to Cloudinary's terms and policies",
                  ]),
                  _buildWarning(
                    context,
                    "Users should not upload private, confidential, or sensitive content.",
                  ),
                  const SizedBox(height: 4),
                  _buildSubsectionTitle(context, "4.3 Data Use"),
                  _buildIntro2(context, "We:"),
                  _buildBullets([
                    "Do not sell user data",
                    "Do not rent or commercially distribute personal information",
                    "Do not intentionally share personal data with third parties except as described below",
                  ]),
                  _buildIntro3(context, "Data may be shared:"),
                  _buildBullets2([
                    "With hosting or infrastructure providers strictly for service operation",
                    "When required by applicable law, regulation, or court order",
                    "To protect the rights, safety, or security of the Platform or others",
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.block_outlined,
              title: "5. Acceptable Use",
              intro: "You agree not to:",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBullets([
                    "Use the Platform for unlawful purposes",
                    "Share illegal, harmful, abusive, or infringing content",
                    "Upload malicious software or attempt to compromise the Platform",
                    "Harass, threaten, or impersonate others",
                  ]),
                  _buildWarning(
                    context,
                    "We reserve the right to remove content and suspend accounts violating this section.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.copyright_outlined,
              title: "6. Intellectual Property",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildParagraph(
                      "All software, design, branding, and content (excluding user-generated content) remain the intellectual property of P R Hari Hara Sai Pratham."),
                  _buildParagraph(
                      "Users retain ownership of their own uploaded content but grant us a limited license to store and display such content for the purpose of operating the Platform."),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.remove_red_eye_outlined,
              title: "7. Privacy",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildParagraph("Use of the Platform is also governed by our Privacy Policy."),
                  _buildIntro2(context, "Users acknowledge that:"),
                  _buildBullets([
                    "Absolute security cannot be guaranteed",
                    "Internet transmissions may carry inherent risks",
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.warning_amber_rounded,
              title: "8. Disclaimer of Warranties",
              titleColor: Colors.orange,
              intro: 'The Platform is provided on an "as is" and "as available" basis.',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntro2(context, "We make no warranties regarding:"),
                  _buildBullets([
                    "Continuous availability",
                    "Security against all possible vulnerabilities",
                    "Accuracy or reliability of communications",
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.balance_outlined,
              title: "9. Limitation of Liability",
              intro: "To the maximum extent permitted under Indian law:",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBullets([
                    "We shall not be liable for indirect, incidental, special, or consequential damages",
                    "We are not responsible for loss of data, unauthorized access, or service interruptions",
                    "Total liability shall not exceed the amount paid by the user (if any), which in this case is zero for demo usage",
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.security_outlined,
              title: "10. Indemnification",
              intro:
                  "You agree to indemnify and hold harmless P R Hari Hara Sai Pratham from any claims, damages, liabilities, or expenses arising out of:",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBullets([
                    "Your misuse of the Platform",
                    "Violation of these Terms",
                    "Violation of applicable laws",
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.logout_outlined,
              title: "11. Termination",
              intro: "We reserve the right to:",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBullets([
                    "Suspend or terminate accounts",
                    "Remove content",
                    "Discontinue the Platform",
                  ]),
                  _buildNote(
                    context,
                    "At our sole discretion, without prior notice.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.public_outlined,
              title: "12. Governing Law and Jurisdiction",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildParagraph("These Terms shall be governed by and interpreted in accordance with the laws of India."),
                  _buildParagraph(
                      "Any disputes arising shall be subject to the exclusive jurisdiction of the courts located in India."),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.autorenew_outlined,
              title: "13. Changes to Terms",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildParagraph(
                      "We may update these Terms at any time. Continued use of the Platform constitutes acceptance of revised Terms."),
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
            Icons.gavel_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
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
                  'Welcome',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildParagraph('Welcome to Talkio ("Platform", "Service", "we", "our", or "us").'),
            _buildParagraph('These Terms and Conditions ("Terms") govern your access to and use of the Platform operated by P R Hari Hara Sai Pratham, based in India.'),
            const SizedBox(height: 8),
            Text(
              'By accessing or using this Platform, you agree to be bound by these Terms. If you do not agree, please discontinue use immediately.',
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
        style: const TextStyle(height: 1.5, color: Colors.black87),
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
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0, left: 4.0),
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
                    color: Colors.blue,
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

  Widget _buildBullets2(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
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
                    color: Colors.grey,
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
                  '14. Contact Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildParagraph('For any questions regarding these Terms, please contact:'),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('📧 harihara1869@gmail.com', style: TextStyle(height: 1.5)),
                  Text('Location: India', style: TextStyle(height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
