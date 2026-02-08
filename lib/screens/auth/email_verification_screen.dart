import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../controllers/auth_controller.dart';
import '../../app/routes/app_routes.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthController _authController = Get.find<AuthController>();
  Timer? _timer;
  bool _isResendEnabled = false;
  int _countDown = 60;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
    _startResendCountdown();
  }

  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      final isVerified = await _authController.checkEmailVerification();
      if (isVerified) {
        timer.cancel();
        Get.snackbar(
          'Success',
          'Email verified successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed(Routes.HOME);
      }
    });
  }

  void _startResendCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countDown > 0) {
        setState(() {
          _countDown--;
        });
      } else {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () {
            _timer?.cancel();
            _authController.logout();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: 60,
                  color: Colors.green[700],
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'We have sent a verification link to',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Obx(
                () => Text(
                  _authController.userEmail.value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Please check your email and click on the verification link to activate your account.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This page will automatically redirect once your email is verified',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              if (!_isResendEnabled)
                Text(
                  'Resend email in $_countDown seconds',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              if (_isResendEnabled)
                TextButton(
                  onPressed: () async {
                    await _authController.resendVerificationEmail();
                    setState(() {
                      _isResendEnabled = false;
                      _countDown = 60;
                    });
                    _startResendCountdown();
                    Get.snackbar(
                      'Email Sent',
                      'Verification email has been resent',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: Text(
                    'Resend Verification Email',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  _timer?.cancel();
                  _authController.logout();
                },
                child: Text(
                  'Sign in with different account',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
