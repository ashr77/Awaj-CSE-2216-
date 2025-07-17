import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/app_localizations.dart';

import 'author_home_screen.dart';
import 'main_app_screen.dart';
import 'admin_home_page.dart';
import 'signup_screen.dart';
import 'package:provider/provider.dart';
import '../theme_locale_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        final userData = userDoc.data();
        final userType = userData != null && userData.containsKey('userType')
            ? userData['userType']
            : 'user';

        if (userType == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminHomePage()));
        } else if (userType == 'author' || userType == 'authority') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthorHomeScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainAppScreen()));
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _error = e.message ?? 'Sign in failed';
        });
      } catch (e) {
        setState(() {
          _error = 'An error occurred. Please try again.';
        });
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email to reset password.')),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent. Please check your inbox.')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Failed to send reset email.')),
      );
    }
  }

  void _goToSignUpScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }

  void _goBackToHome() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: _goBackToHome,
          tooltip: 'Back to Home',
        ),
        title: Text(AppLocalizations.of(context)?.signIn ?? 'Sign In', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              Provider.of<ThemeLocaleProvider>(context, listen: false).toggleLocale();
            },
            tooltip: AppLocalizations.of(context)?.toggleLanguage ?? 'Toggle Language',
          ),
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeLocaleProvider>(context, listen: false).toggleTheme();
            },
            tooltip: AppLocalizations.of(context)?.toggleTheme ?? 'Toggle Theme',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Icon(Icons.shield, size: 64, color: theme.colorScheme.primary),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)?.welcomeBack ?? 'Welcome Back!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)?.signInToContinueMission ?? 'Sign in to continue your mission.',
                  style: TextStyle(fontSize: 16, color: theme.textTheme.bodyLarge?.color),
                ),
                SizedBox(height: 24),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  color: theme.cardColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)?.email ?? 'Email',
                              prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value != null && value.contains('@') ? null : AppLocalizations.of(context)?.enterValidEmail ?? 'Enter a valid email',
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)?.password ?? 'Password',
                              prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
                            ),
                            obscureText: true,
                            validator: (value) => value != null && value.length >= 6 ? null : AppLocalizations.of(context)?.enterValidPassword ?? 'Enter a valid password',
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isLoading ? null : _resetPassword,
                              child: Text(AppLocalizations.of(context)?.forgotPassword ?? 'Forgot Password?'),
                            ),
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: _isLoading
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : Icon(Icons.login, color: Colors.white),
                              label: Text(
                                _isLoading ? (AppLocalizations.of(context)?.signingIn ?? 'Signing In...') : (AppLocalizations.of(context)?.signIn ?? 'Sign In'),
                                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                              ),
                              onPressed: _isLoading ? null : _signIn,
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.person_add, color: theme.colorScheme.primary),
                              label: Text(
                                AppLocalizations.of(context)?.signUp ?? 'Sign Up',
                                style: TextStyle(fontSize: 18, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: theme.colorScheme.primary, width: 2),
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _isLoading ? null : _goToSignUpScreen,
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
