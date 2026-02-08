import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../app/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        // Exit app when back button is pressed
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Do you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        );
        if (shouldExit ?? false) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Sign in to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.email, color: Colors.green[700]),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.lock, color: Colors.green[700]),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                      activeColor: Colors.green[700],
                    ),
                    Text('Remember me'),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(Routes.FORGOT_PASSWORD);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      onPressed: _authController.isLoading.value
                          ? null
                          : () {
                              _authController.login(
                                _emailController.text,
                                _passwordController.text,
                              );
                            },
                      child: _authController.isLoading.value
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'SIGN IN',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text('Or', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                SizedBox(height: 20),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey[800],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _authController.isLoading.value
                          ? null
                          : () {
                              _authController.signInWithGoogle();
                            },
                      icon: Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        height: 24,
                        width: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.g_mobiledata,
                            color: Colors.red,
                            size: 28,
                          );
                        },
                      ),
                      label: _authController.isLoading.value
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey[800],
                              ),
                            )
                          : Text(
                              'SIGN IN WITH GOOGLE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.REGISTER);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.grey[600]),
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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
