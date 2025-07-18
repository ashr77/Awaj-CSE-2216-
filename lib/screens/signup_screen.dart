import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../theme_locale_provider.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _nidController = TextEditingController();
  final _phoneController = TextEditingController();
  XFile? _imageFile;
  bool _isLoading = false;
  String? _nidError;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _nidController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imageFile = image);
  }

  String? _validateNid(String? value) {
    if (value == null || value.trim().isEmpty || value.trim().length < 5) {
      return 'Enter a valid NID / Birth Registration (min 5 chars)';
    }
    if (_nidError != null) return _nidError;
    return null;
  }

  String? _validatePhone(String? value) {
    final pattern = RegExp(r'^01\d{9}$');
    if (value == null || value.isEmpty) return 'Enter phone number';
    if (!pattern.hasMatch(value)) return 'Phone must be 11 digits, start with 01, digits only';
    return null;
  }

  Future _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _nidError = null;
      });
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final nid = _nidController.text.trim();
      try {
        // Check NID uniqueness
        final nidDoc = await _firestore.collection('nids').doc(nid).get();
        if (nidDoc.exists) {
          setState(() => _nidError = 'NID / Birth Registration already registered');
          setState(() => _isLoading = false);
          return;
        }
        // Create Firebase user
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Upload image to Supabase if exists
        String? imageUrl;
        if (_imageFile != null) {
          try {
            final supabase = Supabase.instance.client;
            final file = File(_imageFile!.path);
            final filePath = '${userCredential.user!.uid}/${DateTime.now().millisecondsSinceEpoch}';
            await supabase.storage.from('imageandfiles').upload(filePath, file);
            imageUrl = supabase.storage.from('imageandfiles').getPublicUrl(filePath);
          } catch (e) {
            debugPrint('Image upload error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image upload failed: ${e.toString()}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
        // Batch write for atomic operations
        WriteBatch batch = _firestore.batch();
        final userRef = _firestore.collection('users').doc(userCredential.user!.uid);
        batch.set(userRef, {
          'fullName': _fullNameController.text.trim(),
          'email': email,
          'nid': nid,
          'phone': _phoneController.text.trim(),
          'userType': 'user',
          'imageUrl': imageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
        final nidRef = _firestore.collection('nids').doc(nid);
        batch.set(nidRef, {
          'userId': userCredential.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await batch.commit();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/signin');
      } catch (e) {
        String message = 'Sign-up failed';
        if (e is FirebaseAuthException) {
          message = e.message ?? 'Authentication error';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goBack() {
    Navigator.pop(context);
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
          onPressed: _goBack,
          tooltip: 'Back',
        ),
        title: Text(
          AppLocalizations.of(context)?.createAccount ?? 'Create Account',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // App icon
                  Icon(Icons.shield, size: 64, color: theme.colorScheme.primary),
                  SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.joinMission ?? 'Join the Mission!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)?.createAccountDescription ?? 'Create your account to report & track corruption.',
                    style: TextStyle(fontSize: 16, color: theme.colorScheme.onBackground.withOpacity(0.7)),
                  ),
                  SizedBox(height: 24),
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Profile image picker
                            Center(
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.colorScheme.surfaceVariant,
                                      border: Border.all(color: theme.colorScheme.primary, width: 2),
                                    ),
                                    child: _imageFile == null
                                        ? Icon(Icons.person, size: 56, color: theme.colorScheme.onSurfaceVariant)
                                        : ClipOval(
                                      child: Image.file(
                                        File(_imageFile!.path),
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.camera_alt, color: theme.colorScheme.onPrimary),
                                      onPressed: _isLoading ? null : _pickImage,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(AppLocalizations.of(context)?.addProfilePhoto ?? 'Add Profile Photo', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
                            SizedBox(height: 20),

                            // Form fields
                            TextFormField(
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)?.fullName ?? 'Full Name',
                                prefixIcon: Icon(Icons.person, color: theme.colorScheme.onSurfaceVariant),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceVariant,
                              ),
                              validator: (value) => value!.isEmpty ? (AppLocalizations.of(context)?.required ?? 'Required') : null,
                            ),
                            SizedBox(height: 14),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)?.email ?? 'Email',
                                prefixIcon: Icon(Icons.email, color: theme.colorScheme.onSurfaceVariant),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceVariant,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => value!.contains('@') ? null : (AppLocalizations.of(context)?.invalidEmail ?? 'Invalid email'),
                            ),
                            SizedBox(height: 14),
                            TextFormField(
                              controller: _nidController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)?.nidBirthRegistration ?? 'NID / Birth Registration',
                                prefixIcon: Icon(Icons.badge, color: theme.colorScheme.onSurfaceVariant),
                                errorText: _nidError,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceVariant,
                              ),
                              validator: _validateNid,
                            ),
                            SizedBox(height: 14),
                            TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)?.phone ?? 'Phone',
                                prefixIcon: Icon(Icons.phone, color: theme.colorScheme.onSurfaceVariant),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceVariant,
                              ),
                              keyboardType: TextInputType.phone,
                              validator: _validatePhone,
                            ),
                            SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)?.password ?? 'Password',
                                prefixIcon: Icon(Icons.lock, color: theme.colorScheme.onSurfaceVariant),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceVariant,
                              ),
                              obscureText: true,
                              validator: (value) => value!.length < 6 ? (AppLocalizations.of(context)?.min6Characters ?? 'Min 6 characters') : null,
                            ),
                            SizedBox(height: 14),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)?.confirmPassword ?? 'Confirm Password',
                                prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.onSurfaceVariant),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceVariant,
                              ),
                              obscureText: true,
                              validator: (value) => value != _passwordController.text ? (AppLocalizations.of(context)?.passwordsDontMatch ?? "Passwords don't match") : null,
                            ),
                            SizedBox(height: 26),

                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: _isLoading
                                    ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.onPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Icon(Icons.person_add, color: theme.colorScheme.onPrimary),
                                label: Text(
                                  _isLoading ? (AppLocalizations.of(context)?.signingUp ?? 'Signing Up...') : (AppLocalizations.of(context)?.signUp ?? 'Sign Up'),
                                  style: TextStyle(fontSize: 18, color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                ),
                                onPressed: _isLoading ? null : _signUp,
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
      ),
    );
  }
}
