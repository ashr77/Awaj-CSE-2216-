import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _postController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.User? _currentUser = auth.FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool _isLoading = false;
  bool _showMyFeed = false;
  bool _isAnonymous = false;
  String? _fullName;

  @override
  void initState() {
    super.initState();
    _fetchFullName();
  }

  Future<void> _fetchFullName() async {
    if (_currentUser != null) {
      final userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      setState(() {
        _fullName = userDoc.data()?['fullName'] ?? _currentUser!.displayName ?? 'Anonymous';
      });
    }
  }

  Future<void> _createPost() async {
    if (_postController.text.isEmpty && _imageFile == null) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_imageFile != null) {
        final supabase = Supabase.instance.client;
        final file = File(_imageFile!.path);
        final filePath = 'posts/${_currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}';

        await supabase.storage
            .from('imageandfiles')
            .upload(filePath, file);

        imageUrl = supabase.storage
            .from('imageandfiles')
            .getPublicUrl(filePath);
      }

      await _firestore.collection('posts').add({
        'userId': _isAnonymous ? null : _currentUser!.uid,
        'userName': _isAnonymous
            ? 'Anonymous'
            : (_fullName ?? 'Anonymous'),
        'userImage': _isAnonymous ? null : _currentUser!.photoURL,
        'text': _postController.text,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'upvotes': 0,
        'downvotes': 0,
        'comments': 0,
        'isAnonymous': _isAnonymous,
      });

      _postController.clear();
      setState(() {
        _imageFile = null;
        _isAnonymous = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.postCreatedSuccessfully ?? 'Post created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.errorCreatingPost('$e') ?? 'Error creating post: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imageFile = image);
  }

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text(AppLocalizations.of(context)?.createPost ?? 'Create Post', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _postController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)?.whatDoYouWantToShare ?? 'What do you want to share?',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.06),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_imageFile != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(_imageFile!.path), height: 120),
                      ),
                    TextButton.icon(
                      icon: Icon(Icons.image),
                      label: Text(AppLocalizations.of(context)?.addImage ?? 'Add Image'),
                      onPressed: _pickImage,
                    ),
                    CheckboxListTile(
                      title: Text(AppLocalizations.of(context)?.postAnonymously ?? 'Post Anonymously'),
                      value: _isAnonymous,
                      onChanged: (value) {
                        setDialogState(() {
                          _isAnonymous = value!;
                        });
                        setState(() {
                          _isAnonymous = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _createPost();
                  },
                  child: _isLoading
                      ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text(AppLocalizations.of(context)?.post ?? 'Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditPostDialog(BuildContext context, String postId, Map<String, dynamic> data) {
    final TextEditingController editController = TextEditingController(text: data['text'] ?? '');
    bool isAnonymous = data['isAnonymous'] ?? false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text(AppLocalizations.of(context)?.editPost ?? 'Edit Post'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: editController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)?.editYourPost ?? 'Edit your post',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)?.postAnonymously ?? 'Post Anonymously'),
                    value: isAnonymous,
                    onChanged: (value) {
                      setDialogState(() {
                        isAnonymous = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _firestore.collection('posts').doc(postId).update({
                      'text': editController.text,
                      'isAnonymous': isAnonymous,
                    });
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)?.save ?? 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)?.postDeleted ?? 'Post deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.communityPosts ?? 'Community Posts', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        backgroundColor: theme.colorScheme.background,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(_showMyFeed ? Icons.public : Icons.person_pin, color: theme.colorScheme.primary),
            tooltip: _showMyFeed ? 'Show All Posts' : 'Show My Feed',
            onPressed: () {
              setState(() {
                _showMyFeed = !_showMyFeed;
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostDialog(context),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)?.newPost ?? 'New Post',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        key: ValueKey(_showMyFeed),
        stream: _showMyFeed && user != null
            ? _firestore
            .collection('posts')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots()
            : _firestore
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.post_add, size: 64, color: theme.colorScheme.primary),
                  SizedBox(height: 16),
                  Text(_showMyFeed
                      ? 'You have not posted anything yet.'
                      : 'No posts yet'),
                  if (!_showMyFeed) Text('Be the first to share something!'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final data = post.data() as Map<String, dynamic>;
              return PostItem(
                postId: post.id,
                data: data,
                isOwner: (data['userId'] ?? '') == (user?.uid ?? ''),
                onEdit: () => _showEditPostDialog(context, post.id, data),
                onDelete: () => _deletePost(post.id),
              );
            },
          );
        },
      ),
    );
  }
}

class PostItem extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> data;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostItem({
    required this.postId,
    required this.data,
    this.isOwner = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.User? _currentUser = auth.FirebaseAuth.instance.currentUser;
  final TextEditingController _commentController = TextEditingController();
  bool _showComments = false;

  /// --- VOTING LOGIC FIXED BELOW ---
  Future<void> _vote(int value) async {
    if (_currentUser == null) return;

    final voteRef = _firestore
        .collection('posts')
        .doc(widget.postId)
        .collection('votes')
        .doc(_currentUser!.uid);

    final voteDoc = await voteRef.get();
    final currentVote = voteDoc.exists ? voteDoc.get('value') : 0;

    if (currentVote == value) {
      // User is removing their vote
      await voteRef.delete();
      if (value == 1) {
        await _firestore.collection('posts').doc(widget.postId).update({
          'upvotes': FieldValue.increment(-1),
        });
      } else if (value == -1) {
        await _firestore.collection('posts').doc(widget.postId).update({
          'downvotes': FieldValue.increment(-1),
        });
      }
    } else {
      // User is changing or casting a new vote
      WriteBatch batch = _firestore.batch();
      batch.set(voteRef, {'value': value});
      if (value == 1) {
        batch.update(_firestore.collection('posts').doc(widget.postId), {
          'upvotes': FieldValue.increment(1),
        });
        if (currentVote == -1) {
          batch.update(_firestore.collection('posts').doc(widget.postId), {
            'downvotes': FieldValue.increment(-1),
          });
        }
      } else if (value == -1) {
        batch.update(_firestore.collection('posts').doc(widget.postId), {
          'downvotes': FieldValue.increment(1),
        });
        if (currentVote == 1) {
          batch.update(_firestore.collection('posts').doc(widget.postId), {
            'upvotes': FieldValue.increment(-1),
          });
        }
      }
      await batch.commit();
    }
  }
  /// --- END VOTING LOGIC FIX ---

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty || _currentUser == null) return;

    try {
      await _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'userId': _currentUser!.uid,
        'userName': _currentUser!.displayName ?? 'Anonymous',
        'userImage': _currentUser!.photoURL,
        'text': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('posts').doc(widget.postId).update({
        'comments': FieldValue.increment(1),
      });

      _commentController.clear();
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isOwner)
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onEdit?.call();
                  },
                ),
              if (widget.isOwner)
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onDelete?.call();
                  },
                ),
              ListTile(
                leading: Icon(Icons.flag),
                title: Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)?.reportedThankYou ?? 'Reported. Thank you!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAnonymous = widget.data['isAnonymous'] == true;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User row
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: !isAnonymous && widget.data['userImage'] != null
                      ? NetworkImage(widget.data['userImage'])
                      : null,
                  child: isAnonymous || widget.data['userImage'] == null
                      ? Icon(Icons.person)
                      : null,
                  radius: 22,
                ),
                SizedBox(width: 12),
                Text(
                  isAnonymous
                      ? 'Anonymous'
                      : (widget.data['userName'] ?? 'Anonymous'),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Spacer(),
                Text(
                  _formatTimestamp(widget.data['timestamp']),
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                  onPressed: () => _showMoreOptions(context),
                ),
              ],
            ),
            if (widget.data['text'] != null && widget.data['text'].isNotEmpty) ...[
              SizedBox(height: 12),
              Text(widget.data['text'], style: TextStyle(fontSize: 15)),
            ],
            if (widget.data['imageUrl'] != null) ...[
              SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.data['imageUrl'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            SizedBox(height: 12),
            // Action row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up, color: Colors.blue),
                      onPressed: () => _vote(1),
                    ),
                    Text('${widget.data['upvotes'] ?? 0}'),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(Icons.thumb_down, color: Colors.red),
                      onPressed: () => _vote(-1),
                    ),
                    Text('${widget.data['downvotes'] ?? 0}'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.comment, color: theme.iconTheme.color),
                      onPressed: () => setState(() => _showComments = !_showComments),
                    ),
                    Text('${widget.data['comments'] ?? 0}'),
                  ],
                ),
              ],
            ),
            if (_showComments) ...[
              SizedBox(height: 12),
              _buildCommentInput(),
              SizedBox(height: 10),
              _buildCommentsList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.addAComment ?? 'Add a comment...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: _addComment,
        ),
      ],
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final comments = snapshot.data!.docs;

        if (comments.isEmpty) {
          return Text(AppLocalizations.of(context)?.noCommentsYet ?? 'No comments yet');
        }

        return Column(
          children: comments.map((doc) {
            final comment = doc.data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: comment['userImage'] != null
                    ? NetworkImage(comment['userImage'])
                    : null,
                child: comment['userImage'] == null
                    ? Icon(Icons.person)
                    : null,
              ),
              title: Text(comment['userName'] ?? 'Anonymous'),
              subtitle: Text(comment['text']),
              trailing: Text(
                _formatTimestamp(comment['timestamp']),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '';
  }
}
