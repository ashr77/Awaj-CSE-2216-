import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportStatusScreen extends StatefulWidget {
  @override
  _ReportStatusScreenState createState() => _ReportStatusScreenState();
}

class _ReportStatusScreenState extends State<ReportStatusScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  late Stream<QuerySnapshot> _reportsStream;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadReports();
    _controller = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  void _loadReports() {
    _reportsStream = _firestore
        .collection('reports')
        .where('userId', isEqualTo: _user?.uid)
        .where('status', whereIn: ['pending', 'approved', 'completed'])
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _refreshReports() async {
    setState(() {
      _loadReports();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Report Status')),
        body: Center(child: Text('Please sign in to view your reports')),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('Report Status', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: _refreshReports,
            tooltip: 'Refresh reports',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: RefreshIndicator(
            onRefresh: _refreshReports,
            child: StreamBuilder<QuerySnapshot>(
              stream: _reportsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorView(snapshot.error.toString(), theme);
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyView(theme);
                }

                final reports = snapshot.data!.docs;
                return ListView.builder(
                  padding: EdgeInsets.only(top: 12, bottom: 24),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final data = reports[index].data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'unknown';

                    return AnimatedReportCard(
                      key: ValueKey(reports[index].id),
                      status: status,
                      data: data,
                      onTap: () => _showReportDetails(context, data, theme),
                      dateText: data['createdAt'] != null && data['createdAt'] is Timestamp
                          ? _formatDate(data['createdAt'] as Timestamp)
                          : '',
                      theme: theme,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String error, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text('Error loading reports', style: TextStyle(color: theme.colorScheme.error)),
          SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 72, color: theme.colorScheme.primary),
          SizedBox(height: 20),
          Text('No reports found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 10),
          Text('Your submitted reports will appear here', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('MMM dd, yyyy').format(date);
  }

  List<Widget> _buildFeedbackList(List feedbacks) {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text('Feedback:', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      ...feedbacks.map<Widget>((fb) => Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 2.0),
        child: Text(
          fb['feedback'] ?? '',
          style: TextStyle(color: Colors.blueGrey),
        ),
      )),
    ];
  }

  List<Widget> _buildUpdateList(List updates) {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text('Updates:', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      ...updates.map<Widget>((up) => Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 2.0),
        child: Text(
          up['update'] ?? '',
          style: TextStyle(color: Colors.teal[700]),
        ),
      )),
    ];
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> data, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Report Details', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Report: ${data['reportName'] ?? 'N/A'}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('City: ${data['city'] ?? 'N/A'}'),
              Text('Office: ${data['office'] ?? 'N/A'}'),
              SizedBox(height: 12),
              Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(data['brief'] ?? 'No description'),
              SizedBox(height: 12),
              if (data['imageUrl'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(data['imageUrl'], height: 180),
                ),
              SizedBox(height: 16),
              Text('Status: ${data['status']?.toUpperCase() ?? 'UNKNOWN'}',
                  style: TextStyle(
                      color: _getStatusColor(data['status']),
                      fontWeight: FontWeight.bold)),
              if (data['authorFeedback'] != null && (data['authorFeedback'] as List).isNotEmpty)
                ...[
                  SizedBox(height: 12),
                  Text('Feedback:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ..._buildFeedbackList(data['authorFeedback']).skip(1),
                ],
              if (data['updates'] != null && (data['updates'] as List).isNotEmpty)
                ...[
                  SizedBox(height: 12),
                  Text('Updates:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ..._buildUpdateList(data['updates']).skip(1),
                ],
              if (data['finalUpdate'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    "Final Update: ${data['finalUpdate']['update']}",
                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          )
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.indigo;
      case 'approved':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class AnimatedReportCard extends StatefulWidget {
  final String status;
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final String dateText;
  final ThemeData theme;

  const AnimatedReportCard({
    required Key key,
    required this.status,
    required this.data,
    required this.onTap,
    required this.dateText,
    required this.theme,
  }) : super(key: key);

  @override
  State<AnimatedReportCard> createState() => _AnimatedReportCardState();
}

class _AnimatedReportCardState extends State<AnimatedReportCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _statusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'completed':
        color = Colors.indigo;
        label = 'Completed';
        break;
      case 'approved':
        color = Colors.green;
        label = 'Approved';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
    }
    return Chip(
      label: Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final status = widget.status;
    final theme = widget.theme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          elevation: 7,
          margin: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          color: theme.cardColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildStatusIcon(status),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          data['reportName'] ?? 'Untitled Report',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      _statusChip(status),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(widget.dateText, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    ],
                  ),
                  if (data['authorFeedback'] != null && (data['authorFeedback'] as List).isNotEmpty)
                    ...[
                      SizedBox(height: 8),
                      Text('Feedback:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...((data['authorFeedback'] as List).map<Widget>((fb) => Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                        child: Text(
                          fb['feedback'] ?? '',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ))),
                    ],
                  if (data['updates'] != null && (data['updates'] as List).isNotEmpty)
                    ...[
                      SizedBox(height: 8),
                      Text('Updates:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...((data['updates'] as List).map<Widget>((up) => Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                        child: Text(
                          up['update'] ?? '',
                          style: TextStyle(color: Colors.teal[700]),
                        ),
                      ))),
                    ],
                  if (data['finalUpdate'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Final Update: ${data['finalUpdate']['update']}",
                        style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
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

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icon(Icons.verified, color: Colors.indigo, size: 36);
      case 'approved':
        return Icon(Icons.check_circle, color: Colors.green, size: 36);
      case 'declined':
        return Icon(Icons.cancel, color: Colors.red, size: 36);
      case 'pending':
        return Icon(Icons.access_time, color: Colors.orange, size: 36);
      default:
        return Icon(Icons.help, color: Colors.grey, size: 36);
    }
  }
}
