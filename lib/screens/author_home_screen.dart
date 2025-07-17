import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'author_chat_page.dart';
import 'author_conversations_screen.dart';
import 'author_review_screen.dart';
import '../theme_locale_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class AuthorHomeScreen extends StatefulWidget {
  const AuthorHomeScreen({super.key});

  @override
  State<AuthorHomeScreen> createState() => _AuthorHomeScreenState();
}

class _AuthorHomeScreenState extends State<AuthorHomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirmSignOut() async {
    final theme = Theme.of(context);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text(
          AppLocalizations.of(context)?.confirmLogout ?? 'Confirm Logout',
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        ),
        content: Text(
          AppLocalizations.of(context)?.areYouSureLogout ?? 'Are you sure you want to logout?',
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        ),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel', style: TextStyle(color: theme.colorScheme.primary)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context)?.yesLogout ?? 'Yes, Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/signin', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme-aware gradients
    final List<Color> requestGradient = isDark
        ? [theme.colorScheme.primary, theme.colorScheme.secondary]
        : [theme.colorScheme.primary, theme.colorScheme.secondary];
    final List<Color> convoGradient = isDark
        ? [theme.colorScheme.secondary, theme.colorScheme.primary]
        : [theme.colorScheme.secondary, theme.colorScheme.primary];
    final List<Color> reportGradient = isDark
        ? [theme.colorScheme.error, theme.colorScheme.primary]
        : [theme.colorScheme.error, theme.colorScheme.primary];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.authorHome ?? 'Author Home', style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: theme.colorScheme.onPrimary),
            onPressed: () {
              Provider.of<ThemeLocaleProvider>(context, listen: false).toggleLocale();
            },
            tooltip: AppLocalizations.of(context)?.toggleLanguage ?? 'Toggle Language',
          ),
          IconButton(
            icon: Icon(Icons.brightness_6, color: theme.colorScheme.onPrimary),
            onPressed: () {
              Provider.of<ThemeLocaleProvider>(context, listen: false).toggleTheme();
            },
            tooltip: AppLocalizations.of(context)?.toggleTheme ?? 'Toggle Theme',
          ),
          IconButton(
            icon: Icon(Icons.logout, color: theme.colorScheme.onPrimary),
            tooltip: AppLocalizations.of(context)?.signOut ?? 'Sign Out',
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.background, theme.cardColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar and greeting
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: theme.cardColor,
                      backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                      child: user?.photoURL == null
                          ? Icon(Icons.person, size: 48, color: theme.colorScheme.primary)
                          : null,
                    ),
                    SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)?.welcomeAuthor("${user?.displayName ?? AppLocalizations.of(context)?.author ?? 'Author'}") ?? 'Welcome, Author!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 28),
                    _AnimatedGradientButton(
                      icon: Icons.mark_email_unread,
                      label: AppLocalizations.of(context)?.viewChatRequests ?? 'View Chat Requests',
                      gradientColors: requestGradient,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AuthorChatPage()),
                      ),
                    ),
                    SizedBox(height: 24),
                    _AnimatedGradientButton(
                      icon: Icons.forum,
                      label: AppLocalizations.of(context)?.viewConversations ?? 'View Conversations',
                      gradientColors: convoGradient,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AuthorConversationsScreen()),
                      ),
                    ),
                    SizedBox(height: 24),
                    _AnimatedGradientButton(
                      icon: Icons.report,
                      label: AppLocalizations.of(context)?.reportRequests ?? 'Report Requests',
                      gradientColors: reportGradient,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AuthorReviewScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedGradientButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onPressed;

  const _AnimatedGradientButton({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  State<_AnimatedGradientButton> createState() => __AnimatedGradientButtonState();
}

class __AnimatedGradientButtonState extends State<_AnimatedGradientButton> with SingleTickerProviderStateMixin {
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(_controller);
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
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        height: 62,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: widget.gradientColors[0].withOpacity(0.18),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _animateAndAct,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: theme.colorScheme.onPrimary, size: 30),
                SizedBox(width: 18),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black26,
                        offset: Offset(1, 1),
                      ),
                    ],
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
