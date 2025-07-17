import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'author_conversations_screen.dart';
import 'chat_conversation_screen.dart';
import '../l10n/app_localizations.dart';

class AuthorReviewScreen extends StatefulWidget {
  @override
  _AuthorReviewScreenState createState() => _AuthorReviewScreenState();
}

class _AuthorReviewScreenState extends State<AuthorReviewScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final _completeController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );
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
    _completeController.dispose();
    super.dispose();
  }

  Future<void> _completeReport(String reportId, String userId, String feedback) async {
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'completionFeedback': {
          'feedback': feedback,
          'by': _currentUser?.email,
          'timestamp': FieldValue.serverTimestamp(),
        }
      });

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('reportCompletions')
          .add({
        'reportId': reportId,
        'feedback': feedback,
        'by': _currentUser?.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.reportMarkedCompleted ?? 'Report marked as completed'),
          backgroundColor: Colors.indigo,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.errorWithMessage(e.toString()) ?? 'Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)?.authorReview ?? 'Author Review')),
        body: Center(
          child: Text(AppLocalizations.of(context)?.pleaseSignInToAccess ?? 'Please sign in to access this feature',
              style: TextStyle(fontSize: 16)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.reportReview ?? 'Report Review', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh reports',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('reports')
                .where('status', isEqualTo: 'approved')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)?.errorLoadingReports ?? 'Error loading reports',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 72, color: Colors.green),
                      SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)?.noReportsToReview ?? 'No reports to review',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(AppLocalizations.of(context)?.allApprovedReportsHandled ?? 'All approved reports have been handled'),
                    ],
                  ),
                );
              }

              final reports = snapshot.data!.docs;

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  final data = report.data() as Map<String, dynamic>;
                  final reportId = report.id;
                  return AnimatedReportCard(
                    key: ValueKey(reportId),
                    child: _buildReportCard(context, data, reportId, theme),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, Map<String, dynamic> data, String reportId, ThemeData theme) {
    final status = data['status'] ?? 'approved';
    final userId = data['userId'] ?? '';
    final userEmail = data['userEmail'] ?? '';
    final userName = data['userName'] ?? '';
    final userImage = data['userImage'] ?? '';
    final updates = (data['updates'] as List?) ?? [];
    final isCompleted = status == 'completed';

    return Card(
      elevation: 7,
      margin: EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data['reportName'] ?? 'Untitled Report',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(
                    isCompleted ? 'COMPLETED' : 'APPROVED',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: isCompleted ? Colors.indigo : Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                ),
              ],
            ),
            SizedBox(height: 8),
            _buildDetailRow('Location', '${data['city'] ?? 'N/A'}, ${data['office'] ?? 'N/A'}', theme),
            _buildDetailRow('Submitted by', userEmail, theme),
            _buildDetailRow('Date', _formatTimestamp(data['createdAt']), theme),
            SizedBox(height: 10),
            Text('Description:', style: TextStyle(fontWeight: FontWeight.w600, color: theme.hintColor)),
            SizedBox(height: 4),
            Text(
              data['brief'] ?? 'No description provided',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
            SizedBox(height: 12),
            if (data['imageUrl'] != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  data['imageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 14),
            ],
            if (updates.isNotEmpty) ...[
              Text('Updates:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.teal[800])),
              ...updates.map((up) => Padding(
                padding: EdgeInsets.only(top: 4, left: 8),
                child: Text(
                  '${up['update']} (${_formatTimestamp(up['timestamp'])})',
                  style: TextStyle(color: Colors.teal[700]),
                ),
              )),
              SizedBox(height: 10),
            ],
            if (!isCompleted) ...[
              Row(
                children: [
                  Expanded(
                    child: _AnimatedActionButton(
                      icon: Icons.chat,
                      label: AppLocalizations.of(context)?.chatWithUser ?? 'Chat with User',
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatConversationScreen(
                              receiverId: userId,
                              receiverName: userName,
                              receiverImage: userImage,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _AnimatedActionButton(
                      icon: Icons.check_circle,
                      label: AppLocalizations.of(context)?.complete ?? 'Complete',
                      color: Colors.indigo,
                      onPressed: () => _showCompleteDialog(reportId, userId),
                    ),
                  ),
                ],
              ),
            ],
            if (isCompleted && data['completionFeedback'] != null)
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  (AppLocalizations.of(context)?.completionFeedback ?? 'Completion Feedback: ') + (data['completionFeedback']['feedback'] ?? ''),
                  style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:',
                style: TextStyle(fontWeight: FontWeight.w600, color: theme.hintColor)),
          ),
          SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(color: theme.textTheme.bodyLarge?.color))),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate());
    }
    return '';
  }

  void _showCompleteDialog(String reportId, String userId) {
    _completeController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.completeReport ?? 'Complete Report', style: TextStyle(color: Colors.indigo)),
          content: TextField(
            controller: _completeController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: AppLocalizations.of(context)?.completionFeedbackLabel ?? 'Completion Feedback',
              hintText: AppLocalizations.of(context)?.describeCompletionFeedback ?? 'Describe the completion/final feedback...',
            ),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              onPressed: () {
                Navigator.pop(context);
                if (_completeController.text.trim().isNotEmpty) {
                  _completeReport(reportId, userId, _completeController.text.trim());
                }
              },
              child: Text(AppLocalizations.of(context)?.complete ?? 'Complete'),
            ),
          ],
        );
      },
    );
  }
}

class AnimatedReportCard extends StatefulWidget {
  final Widget child;
  const AnimatedReportCard({required this.child, Key? key}) : super(key: key);

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
    _controller = AnimationController(
      duration: Duration(milliseconds: 550),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _AnimatedActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  State<_AnimatedActionButton> createState() => __AnimatedActionButtonState();
}

class __AnimatedActionButtonState extends State<_AnimatedActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 90),
      lowerBound: 0.0,
      upperBound: 0.1,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _animateAndAct() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: Icon(widget.icon, color: Colors.white),
          label: Text(
            widget.label,
            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            padding: EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          onPressed: _animateAndAct,
        ),
      ),
    );
  }
}
