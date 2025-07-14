import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubmitReportScreen extends StatefulWidget {
  @override
  _SubmitReportScreenState createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _reportNameController = TextEditingController();
  final _briefController = TextEditingController();
  String? _selectedCity;
  String? _selectedOffice;
  XFile? _imageFile;
  XFile? _videoFile;
  bool _isLoading = false;

  final List<String> _cities = ['DHAKA', 'RAJSHAHI', 'SYLHET'];
  final Map<String, List<String>> _offices = {
    'DHAKA': ['Ministry Of Land', 'Ministry Of Education', 'Ministry Of Health and Family Welfare'],
    'RAJSHAHI': ['Ministry Of Land', 'Ministry Of Education', 'Ministry Of Health and Family Welfare'],
    'SYLHET': ['Ministry Of Land', 'Ministry Of Education', 'Ministry Of Health and Family Welfare'],
  };

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 900), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _reportNameController.dispose();
    _briefController.dispose();
    super.dispose();
  }

  Future<String?> _uploadToSupabase(XFile file, String folder) async {
    final supabase = Supabase.instance.client;
    final user = FirebaseAuth.instance.currentUser;
    final ext = file.path.split('.').last;
    final filePath = 'reports/${user!.uid}/${folder}_${DateTime.now().millisecondsSinceEpoch}.$ext';
    try {
      await supabase.storage.from('imageandfiles').upload(filePath, File(file.path));
      return supabase.storage.from('imageandfiles').getPublicUrl(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
      return null;
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('User not logged in');
        String? imageUrl;
        String? videoUrl;
        if (_imageFile != null) imageUrl = await _uploadToSupabase(_imageFile!, 'photo');
        if (_videoFile != null) videoUrl = await _uploadToSupabase(_videoFile!, 'video');
        final reportData = {
          'userId': user.uid,
          'userEmail': user.email,
          'reportName': _reportNameController.text,
          'city': _selectedCity,
          'office': _selectedOffice,
          'brief': _briefController.text,
          'imageUrl': imageUrl,
          'videoUrl': videoUrl,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        };
        await FirebaseFirestore.instance.collection('reports').add(reportData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submitted successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imageFile = image);
  }

  Future<void> _pickVideo() async {
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video != null) setState(() => _videoFile = video);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('Submit Report', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 1,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Icon(Icons.shield, size: 52, color: theme.colorScheme.primary),
                        SizedBox(height: 10),
                        Text(
                          'Report Corruption',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                        SizedBox(height: 18),
                        TextFormField(
                          controller: _reportNameController,
                          decoration: InputDecoration(
                            labelText: 'Report Name',
                            prefixIcon: Icon(Icons.title, color: theme.colorScheme.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: theme.colorScheme.surface.withOpacity(0.04),
                          ),
                          validator: (value) => value!.isEmpty ? 'Required' : null,
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCity,
                          decoration: InputDecoration(
                            labelText: 'City',
                            prefixIcon: Icon(Icons.location_city, color: theme.colorScheme.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: theme.colorScheme.surface.withOpacity(0.04),
                          ),
                          items: _cities.map((city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCity = value;
                              _selectedOffice = null;
                            });
                          },
                          validator: (value) => value == null ? 'Select a city' : null,
                        ),
                        SizedBox(height: 16),
                        if (_selectedCity != null)
                          DropdownButtonFormField<String>(
                            value: _selectedOffice,
                            decoration: InputDecoration(
                              labelText: 'Office',
                              prefixIcon: Icon(Icons.account_balance, color: theme.colorScheme.primary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: theme.colorScheme.surface.withOpacity(0.04),
                            ),
                            items: _offices[_selectedCity]!.map((office) {
                              return DropdownMenuItem(
                                value: office,
                                child: Text(office),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedOffice = value),
                            validator: (value) => value == null ? 'Select an office' : null,
                          ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _briefController,
                          decoration: InputDecoration(
                            labelText: 'Brief Description',
                            prefixIcon: Icon(Icons.description, color: theme.colorScheme.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: theme.colorScheme.surface.withOpacity(0.04),
                          ),
                          maxLines: 4,
                          validator: (value) => value!.isEmpty ? 'Required' : null,
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _imageFile == null
                                  ? OutlinedButton.icon(
                                icon: Icon(Icons.photo, color: theme.colorScheme.primary),
                                label: Text('Add Photo'),
                                onPressed: _pickImage,
                              )
                                  : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(File(_imageFile!.path), height: 80, width: 80, fit: BoxFit.cover),
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: _pickImage,
                                        child: Text('Change Photo'),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close, color: Colors.red),
                                        onPressed: () => setState(() => _imageFile = null),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _videoFile == null
                                  ? OutlinedButton.icon(
                                icon: Icon(Icons.videocam, color: theme.colorScheme.primary),
                                label: Text('Add Video'),
                                onPressed: _pickVideo,
                              )
                                  : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.videocam, size: 36, color: Colors.blueGrey),
                                  Text('Video Attached', style: TextStyle(color: Colors.blueGrey)),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: _pickVideo,
                                        child: Text('Change Video'),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close, color: Colors.red),
                                        onPressed: () => setState(() => _videoFile = null),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: _isLoading
                                ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : Icon(Icons.send, color: Colors.white),
                            label: Text(
                              _isLoading ? 'Submitting...' : 'Submit Report',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 2,
                            ),
                            onPressed: _isLoading ? null : _submitReport,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
