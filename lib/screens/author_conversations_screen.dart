import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_conversation_screen.dart';
import '../l10n/app_localizations.dart';

class AuthorConversationsScreen extends StatefulWidget {
  @override
  State<AuthorConversationsScreen> createState() => _AuthorConversationsScreenState();
}

class _AuthorConversationsScreenState extends State<AuthorConversationsScreen> with SingleTickerProviderStateMixin {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)?.yourConversations ?? 'Your Conversations')),
        body: Center(child: Text(AppLocalizations.of(context)?.pleaseSignInToViewConversations ?? 'Please sign in to view conversations')),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.yourConversations ?? 'Your Conversations', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 1,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('conversations')
                .where('participant2', isEqualTo: currentUser.uid)
                .snapshots(),
            builder: (context, snapshot1) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('conversations')
                    .where('participant1', isEqualTo: currentUser.uid)
                    .snapshots(),
                builder: (context, snapshot2) {
                  if (snapshot1.connectionState == ConnectionState.waiting ||
                      snapshot2.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot1.hasError || snapshot2.hasError) {
                    return Center(child: Text('Error loading conversations'));
                  }
                  final docs1 = snapshot1.data?.docs ?? [];
                  final docs2 = snapshot2.data?.docs ?? [];
                  final allConversations = [...docs1, ...docs2];

                  if (allConversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat, size: 64, color: theme.colorScheme.primary),
                          SizedBox(height: 16),
                          Text(AppLocalizations.of(context)?.noConversationsYet ?? 'No conversations yet', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(AppLocalizations.of(context)?.acceptChatRequestsToStart ?? 'Accept chat requests to start conversations', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    itemCount: allConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = allConversations[index];
                      final data = conversation.data() as Map<String, dynamic>;
                      final otherUserId = data['participant1'] == currentUser.uid
                          ? data['participant2']
                          : data['participant1'];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return _AnimatedConversationCard(
                              child: ListTile(
                                leading: CircleAvatar(child: CircularProgressIndicator()),
                                title: Text(AppLocalizations.of(context)?.loading ?? 'Loading...'),
                              ),
                            );
                          }
                          if (!userSnapshot.hasData) {
                            return _AnimatedConversationCard(
                              child: ListTile(
                                leading: CircleAvatar(child: Icon(Icons.error)),
                                title: Text(AppLocalizations.of(context)?.userNotFound ?? 'User not found'),
                              ),
                            );
                          }
                          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

                          return _AnimatedConversationCard(
                            child: ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              tileColor: theme.cardColor,
                              leading: CircleAvatar(
                                backgroundImage: userData?['imageUrl'] != null
                                    ? NetworkImage(userData!['imageUrl'])
                                    : null,
                                child: userData?['imageUrl'] == null ? Icon(Icons.person) : null,
                                radius: 26,
                              ),
                              title: Text(userData?['fullName'] ?? 'Unknown User',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                'Last message: ${data['lastMessage'] ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatConversationScreen(
                                      receiverId: otherUserId,
                                      receiverName: userData?['fullName'] ?? 'User',
                                      receiverImage: userData?['imageUrl'] ?? '',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AnimatedConversationCard extends StatefulWidget {
  final Widget child;
  const _AnimatedConversationCard({required this.child});
  @override
  State<_AnimatedConversationCard> createState() => __AnimatedConversationCardState();
}

class __AnimatedConversationCardState extends State<_AnimatedConversationCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.04),
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
