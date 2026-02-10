import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green[700]!, Colors.green[900]!],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.support_agent, size: 64, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'We\'re Here to Help',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Get assistance anytime, 24/7',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Contact Options Section
          _buildSectionTitle('CONTACT US'),
          SizedBox(height: 12),
          _buildSupportTile(
            icon: Icons.phone,
            title: 'Call Us',
            subtitle: '+880 1998-354369',
            color: Colors.blue,
            onTap: () => _makePhoneCall('+8801998354369'),
          ),
          _buildSupportTile(
            icon: Icons.email,
            title: 'Email Support',
            subtitle: 'tamim.cse.vu@gmail.com',
            color: Colors.orange,
            onTap: () => _sendEmail('tamim.cse.vu@gmail.com'),
          ),
          _buildSupportTile(
            icon: Icons.messenger,
            title: 'WhatsApp',
            subtitle: 'Message us on WhatsApp',
            color: Colors.teal,
            onTap: () => _openWhatsApp('+8801998354369'),
          ),

          SizedBox(height: 24),

          // Quick Actions Section
          _buildSectionTitle('QUICK ACTIONS'),
          SizedBox(height: 12),
          _buildSupportTile(
            icon: Icons.question_answer,
            title: 'FAQs',
            subtitle: 'Find answers to common questions',
            color: Colors.purple,
            onTap: () => Get.to(() => FAQScreen()),
          ),
          _buildSupportTile(
            icon: Icons.report_problem,
            title: 'Report a Problem',
            subtitle: 'Let us know about any issues',
            color: Colors.red,
            onTap: () => _showReportDialog(),
          ),
          _buildSupportTile(
            icon: Icons.track_changes,
            title: 'Track Your Order',
            subtitle: 'Check your order status',
            color: Colors.indigo,
            onTap: () => Get.toNamed('/my-orders'),
          ),
          _buildSupportTile(
            icon: Icons.local_shipping,
            title: 'Shipping & Delivery',
            subtitle: 'Learn about our delivery policy',
            color: Colors.cyan,
            onTap: () => _showShippingInfo(),
          ),

          SizedBox(height: 24),

          // Legal Section
          _buildSectionTitle('LEGAL'),
          SizedBox(height: 12),
          _buildSupportTile(
            icon: Icons.description,
            title: 'Terms & Conditions',
            subtitle: 'Read our terms of service',
            color: Colors.grey,
            onTap: () => _showTerms(),
          ),
          _buildSupportTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'How we protect your data',
            color: Colors.blueGrey,
            onTap: () => _showPrivacyPolicy(),
          ),
          _buildSupportTile(
            icon: Icons.assignment_return,
            title: 'Return & Refund Policy',
            subtitle: 'Learn about returns',
            color: Colors.brown,
            onTap: () => _showReturnPolicy(),
          ),

          SizedBox(height: 32),

          // Bottom Info
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.access_time, color: Colors.green[700], size: 32),
                SizedBox(height: 12),
                Text(
                  'Support Hours',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Monday - Saturday: 9:00 AM - 10:00 PM\nSunday: 10:00 AM - 8:00 PM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.grey[900],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
      await launchUrl(launchUri);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not launch phone dialer',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _sendEmail(String email) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'mailto',
        path: email,
        query: 'subject=Support Request&body=',
      );
      await launchUrl(launchUri);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not launch email client',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    try {
      // Remove + sign and any spaces for WhatsApp URL
      final cleanNumber = phoneNumber
          .replaceAll('+', '')
          .replaceAll(' ', '')
          .replaceAll('-', '');
      final Uri launchUri = Uri.parse('https://wa.me/$cleanNumber');
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open WhatsApp. Please make sure WhatsApp is installed.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showReportDialog() {
    final TextEditingController issueController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.report_problem, color: Colors.red[700], size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Report a Problem',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: issueController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Describe the issue you\'re facing...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (issueController.text.isNotEmpty) {
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Your report has been submitted. We\'ll get back to you soon.',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShippingInfo() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      color: Colors.cyan[700],
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Shipping & Delivery',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildInfoSection(
                  'Delivery Time',
                  'Standard delivery: 3-5 business days\nExpress delivery: 1-2 business days',
                ),
                _buildInfoSection(
                  'Shipping Cost',
                  'Inside Dhaka: ৳60\nOutside Dhaka: ৳100\nFree shipping on orders above ৳1000',
                ),
                _buildInfoSection(
                  'Tracking',
                  'Track your order in real-time from the My Orders section',
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[700],
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Got It', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTerms() {
    _showLegalDialog(
      'Terms & Conditions',
      Icons.description,
      Colors.grey[700]!,
      '''By using Turf Mate, you agree to our terms and conditions:

1. Account Registration
- You must provide accurate information
- Keep your password secure
- You are responsible for all activities under your account

2. Product Information
- We strive for accuracy in product descriptions
- Colors may vary slightly from images
- Prices are subject to change without notice

3. Payment & Billing
- All prices are in BDT (৳)
- Payment must be completed before shipment
- We accept various payment methods

4. User Conduct
- Respect other users and staff
- Do not misuse the platform
- Report suspicious activities

5. Limitation of Liability
- We are not liable for indirect damages
- Our liability is limited to the purchase price

For complete terms, visit our website.''',
    );
  }

  void _showPrivacyPolicy() {
    _showLegalDialog(
      'Privacy Policy',
      Icons.privacy_tip,
      Colors.blueGrey[700]!,
      '''We value your privacy and are committed to protecting your personal data:

1. Information We Collect
- Name, email, phone number
- Shipping and billing addresses
- Order history and preferences
- Device and usage information

2. How We Use Your Information
- Process and fulfill orders
- Send order updates and notifications
- Improve our services
- Prevent fraud and enhance security

3. Data Sharing
- We do not sell your personal information
- Share only with service providers
- Comply with legal requirements

4. Data Security
- Industry-standard encryption
- Secure payment processing
- Regular security audits

5. Your Rights
- Access your personal data
- Request data correction or deletion
- Opt-out of marketing communications

Contact us for privacy concerns: tamim.cse.vu@gmail.com''',
    );
  }

  void _showReturnPolicy() {
    _showLegalDialog(
      'Return & Refund Policy',
      Icons.assignment_return,
      Colors.brown[700]!,
      '''Our return and refund policy ensures customer satisfaction:

1. Return Eligibility
- Items can be returned within 7 days
- Products must be unused and in original packaging
- Proof of purchase required

2. Non-Returnable Items
- Customized or personalized products
- Items on sale or clearance
- Damaged due to misuse

3. Return Process
- Contact customer support
- Get return authorization
- Ship the item back
- Refund processed within 5-7 business days

4. Refund Method
- Original payment method
- Store credit (if preferred)
- Shipping fees non-refundable

5. Exchange Policy
- Size/color exchanges available
- Subject to stock availability
- Free exchange within 7 days

For return requests: tamim.cse.vu@gmail.com
Call: +880 1998-354369''',
    );
  }

  void _showLegalDialog(
    String title,
    IconData icon,
    Color color,
    String content,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Get.back(),
                      color: color,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

// FAQ Screen
class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  final List<FAQItem> faqs = const [
    FAQItem(
      question: 'How do I place an order?',
      answer:
          'Browse products, add items to cart, proceed to checkout, enter shipping details, choose payment method, and confirm your order.',
    ),
    FAQItem(
      question: 'What payment methods do you accept?',
      answer:
          'We accept Credit/Debit Cards, Mobile Banking (bKash, Nagad, Rocket), and Cash on Delivery.',
    ),
    FAQItem(
      question: 'How can I track my order?',
      answer:
          'Go to "My Orders" section in your profile. Click on the order you want to track to see its current status and tracking details.',
    ),
    FAQItem(
      question: 'Can I change or cancel my order?',
      answer:
          'You can cancel your order within 1 hour of placing it. After that, please contact customer support for assistance.',
    ),
    FAQItem(
      question: 'What is your return policy?',
      answer:
          'We accept returns within 7 days of delivery. Items must be unused and in original packaging with proof of purchase.',
    ),
    FAQItem(
      question: 'How long does delivery take?',
      answer:
          'Standard delivery: 3-5 business days. Express delivery: 1-2 business days. Delivery times may vary based on location.',
    ),
    FAQItem(
      question: 'Are the products authentic?',
      answer:
          'Yes, all our products are 100% authentic. We source directly from authorized distributors and manufacturers.',
    ),
    FAQItem(
      question: 'Do you offer gift wrapping?',
      answer:
          'Yes, gift wrapping is available for an additional charge. You can select this option during checkout.',
    ),
    FAQItem(
      question: 'What if I receive a damaged product?',
      answer:
          'Contact us immediately with photos of the damage. We will arrange a replacement or full refund.',
    ),
    FAQItem(
      question: 'Can I change my delivery address?',
      answer:
          'Yes, you can change the address before the order is shipped. Go to "My Orders" and select "Change Address".',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Frequently Asked Questions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return FAQTile(faq: faqs[index]);
        },
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  const FAQItem({required this.question, required this.answer});
}

class FAQTile extends StatefulWidget {
  final FAQItem faq;

  const FAQTile({super.key, required this.faq});

  @override
  State<FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<FAQTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.help_outline, color: Colors.purple[700]),
          ),
          title: Text(
            widget.faq.question,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.grey[900],
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.grey[600],
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              isExpanded = expanded;
            });
          },
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.faq.answer,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
