import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFEAFCE8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: w * 0.95,
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.05,
                vertical: h * 0.03,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BACK BUTTON
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: h * 0.035),
                    onPressed: () => Navigator.pop(context),
                  ),

                  SizedBox(height: h * 0.015),

                  // TITLE
                  Center(
                    child: Text(
                      "Forgot Password ?",
                      style: TextStyle(
                        fontSize: h * 0.033,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  SizedBox(height: h * 0.02),

                  // IMAGE
                  Center(
                    child: SizedBox(
                      height: h * 0.25,
                      child: Image.asset(
                        "assets/onboarding_2.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: h * 0.02),

                  // DESCRIPTION
                  Center(
                    child: Text(
                      "Enter your new password below....",
                      style: TextStyle(
                        fontSize: h * 0.02,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  SizedBox(height: h * 0.03),

                  // PASSWORD LABEL
                  Text(
                    "Password",
                    style: TextStyle(
                      fontSize: h * 0.022,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: h * 0.01),

                  // PASSWORD FIELD
                  TextField(
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: h * 0.02,
                        horizontal: w * 0.04,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.black54,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: h * 0.03),

                  // VERIFY PASSWORD LABEL
                  Text(
                    "Verify Password",
                    style: TextStyle(
                      fontSize: h * 0.022,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: h * 0.01),

                  // CONFIRM PASSWORD FIELD
                  TextField(
                    obscureText: !_confirmPasswordVisible,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: h * 0.02,
                        horizontal: w * 0.04,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.black54,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: h * 0.04),

                  // RESET PASSWORD BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: h * 0.02),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: Colors.green, width: 2),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Add your logic
                      },
                      child: Text(
                        "Reset Password",
                        style: TextStyle(
                          fontSize: h * 0.022,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: h * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
