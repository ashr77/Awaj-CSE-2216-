//photo and video chat conversation screen
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class ChatConversationScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverImage;

  const ChatConversationScreen({
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    super.key,
  });

  @override
  _ChatConversationScreenState createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _conversationId;
  List<Map<String, dynamic>> _messages = [];
  Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _conversationId = _generateConversationId(_auth.currentUser!.uid, widget.receiverId);
    _loadMessages();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _generateConversationId(String id1, String id2) {
    final ids = [id1, id2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  void _loadMessages() {
    _firestore
        .collection('conversations')
        .doc(_conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _messages = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
        _markMessagesAsRead();
      }
    });
  }

  void _markMessagesAsRead() async {
    final currentUserId = _auth.currentUser!.uid;
    final unread = await _firestore
        .collection('conversations')
        .doc(_conversationId)
        .collection('messages')
        .where('senderId', isEqualTo: widget.receiverId)
        .where('read', isEqualTo: false)
        .get();

    for (var doc in unread.docs) {
      doc.reference.update({'read': true});
    }
  }

  Future<void> _sendMessage({String? text, String? mediaUrl, String? type}) async {
    if ((text == null || text.trim().isEmpty) && mediaUrl == null) return;

    final message = {
      'senderId': _auth.currentUser!.uid,
      'text': text ?? '',
      'mediaUrl': mediaUrl,
      'type': type ?? 'text',
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'reactions': {},
    };

    try {
      await _firestore
          .collection('conversations')
          .doc(_conversationId)
          .collection('messages')
          .add(message);

      await _firestore
          .collection('conversations')
          .doc(_conversationId)
          .set({
        'lastMessage': text ?? (type == 'image' ? '[Photo]' : type == 'video' ? '[Video]' : ''),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'participants': [_auth.currentUser!.uid, widget.receiverId],
      }, SetOptions(merge: true));

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> _pickMedia({required bool isImage}) async {
    final picker = ImagePicker();
    XFile? picked;
    if (isImage) {
      picked = await picker.pickImage(source: ImageSource.gallery);
    } else {
      picked = await picker.pickVideo(source: ImageSource.gallery);
    }
    if (picked == null) return;

    final file = File(picked.path);
    final ext = isImage ? 'jpg' : 'mp4';
    final supabase = Supabase.instance.client;
    final filePath = '${_auth.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.$ext';

    try {
      await supabase.storage.from('imageandfiles').upload(filePath, file);
      final publicUrl = supabase.storage.from('imageandfiles').getPublicUrl(filePath);

      await _sendMessage(mediaUrl: publicUrl, type: isImage ? 'image' : 'video');
    } catch (e) {
      print('Supabase upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Media upload failed: $e')),
      );
    }
  }

  void _addReaction(String messageId, String emoji) async {
    final userId = _auth.currentUser!.uid;
    final ref = _firestore
        .collection('conversations')
        .doc(_conversationId)
        .collection('messages')
        .doc(messageId);

    await ref.set({
      'reactions': {userId: emoji}
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            widget.receiverImage.isNotEmpty
                ? CircleAvatar(
              backgroundImage: NetworkImage(widget.receiverImage),
            )
                : const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Text(widget.receiverName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['senderId'] == currentUserId;
                return _buildMessageBubble(message, isMe);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    final reactions = message['reactions'] ?? {};
    final messageId = message['id'] ?? '';

    return GestureDetector(
      onLongPress: () {
        _showReactionPicker(messageId);
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue[100] : Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
              bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message['type'] == 'image' && message['mediaUrl'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Image.network(message['mediaUrl'], width: 200),
                ),
              if (message['type'] == 'video' && message['mediaUrl'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildVideoPlayer(message['mediaUrl'], messageId),
                ),
              if (message['text'] != null && message['text'].toString().isNotEmpty)
                Text(message['text']),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTimestamp(message['timestamp']),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  if (isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        message['read'] == true ? Icons.done_all : Icons.done,
                        size: 16,
                        color: message['read'] == true ? Colors.blue : Colors.grey,
                      ),
                    ),
                ],
              ),
              if (reactions is Map && reactions.isNotEmpty)
                Row(
                  children: reactions.values.map<Widget>((emoji) => Text(emoji, style: const TextStyle(fontSize: 18))).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(String url, String messageId) {
    if (!_videoControllers.containsKey(messageId)) {
      final controller = VideoPlayerController.network(url);
      controller.initialize().then((_) {
        setState(() {});
      });
      _videoControllers[messageId] = controller;
    }
    final controller = _videoControllers[messageId]!;
    return controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(controller),
          VideoProgressIndicator(controller, allowScrubbing: true),
          IconButton(
            icon: Icon(
              controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                controller.value.isPlaying ? controller.pause() : controller.play();
              });
            },
          ),
        ],
      ),
    )
        : const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()));
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      color: Colors.grey[100],
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: () => _pickMedia(isImage: true),
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _pickMedia(isImage: false),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(text: _messageController.text),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () => _sendMessage(text: _messageController.text),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final ampm = date.hour >= 12 ? 'PM' : 'AM';
      return '${hour == 0 ? 12 : hour}:${date.minute.toString().padLeft(2, '0')} $ampm';
    }
    return '';
  }

  void _showReactionPicker(String messageId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final emoji in ['👍', '❤️', '😂', '😮', '😢', '👏'])
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _addReaction(messageId, emoji);
                },
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
