import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_request_dialog.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Chat with Authorities')),
        body: Center(child: Text('Please sign in to view chats')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('My Authority Chats')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('conversations')
            .where('userId', isEqualTo: _currentUser!.uid)
            .where('status', isEqualTo: 'accepted')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No accepted authority chats yet. Start one below!'),
            );
          }

          final conversations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conv = conversations[index];
              final convData = conv.data() as Map<String, dynamic>;
              final authorId = convData['authorId'];

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(authorId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text('Loading...'),
                    );
                  }
                  final authorData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: authorData['imageUrl'] != null
                          ? NetworkImage(authorData['imageUrl'])
                          : null,
                      child: authorData['imageUrl'] == null ? Icon(Icons.person) : null,
                    ),
                    title: Text(authorData['fullName'] ?? 'Authority'),
                    subtitle: Text(authorData['userType'] == 'authority'
                        ? 'Government Authority'
                        : 'Verified Author'),
                    trailing: Icon(Icons.chat),
                    onTap: () {
                      // Open the chat screen with this authority
                      // You can navigate to your chat conversation screen here
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add_comment),
        label: Text('Start New Chat'),
        onPressed: () => _showAllAuthorsDialog(context),
      ),
    );
  }

  void _showAllAuthorsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: 400,
          width: 350,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Start New Chat with Authority', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('users')
                      .where('userType', whereIn: ['author', 'authority'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No authorities available'));
                    }
                    final authors = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: authors.length,
                      itemBuilder: (context, index) {
                        final author = authors[index];
                        final authorData = author.data() as Map<String, dynamic>;
                        final authorId = author.id;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: authorData['imageUrl'] != null
                                ? NetworkImage(authorData['imageUrl'])
                                : null,
                            child: authorData['imageUrl'] == null ? Icon(Icons.person) : null,
                          ),
                          title: Text(authorData['fullName'] ?? 'Authority'),
                          subtitle: Text(authorData['userType'] == 'authority'
                              ? 'Government Authority'
                              : 'Verified Author'),
                          trailing: Icon(Icons.send),
                          onTap: () {
                            Navigator.pop(context);
                            _showRequestDialog(context, authorId, authorData);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestDialog(BuildContext context, String authorId, Map<String, dynamic> authorData) {
    showDialog(
      context: context,
      builder: (context) => ChatRequestDialog(
        receiverId: authorId,
        receiverName: authorData['fullName'] ?? 'Authority',
      ),
    );
  }
}
