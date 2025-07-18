import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../theme_locale_provider.dart';
import '../l10n/app_localizations.dart';

import 'report_screen.dart';
import 'chat_screen.dart';
import 'post_screen.dart';
import 'about_me_screen.dart';
import 'others_screen.dart';
import 'user_conversations_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({Key? key}) : super(key: key);

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.appTitle ?? 'Auth System'),
        backgroundColor: theme.colorScheme.background,
        elevation: 1,
        centerTitle: true,
        automaticallyImplyLeading: false, // This removes the back button.
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
          IconButton(
            icon: Icon(Icons.logout, color: theme.colorScheme.primary),
            tooltip: 'Sign Out',
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 24),
                  Icon(Icons.shield, size: 72, color: theme.colorScheme.primary),
                  SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)?.welcome ?? 'Welcome!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)?.chooseAction ?? 'Choose an action below.',
                    style: TextStyle(fontSize: 16, color: theme.textTheme.bodyLarge?.color),
                  ),
                  SizedBox(height: 28),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AnimatedMenuButton(
                            icon: Icons.report_problem,
                            label: AppLocalizations.of(context)?.reportProblem ?? 'Report Problem',
                            color: Color(0xFFD32F2F),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubmitReportScreen())),
                          ),
                          SizedBox(height: 18),
                          _AnimatedMenuButton(
                            icon: Icons.chat_bubble_outline,
                            label: AppLocalizations.of(context)?.chat ?? 'Chat',
                            color: theme.colorScheme.primary,
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserConversationsScreen())),
                          ),
                          SizedBox(height: 18),
                          _AnimatedMenuButton(
                            icon: Icons.post_add,
                            label: AppLocalizations.of(context)?.post ?? 'Post',
                            color: Color(0xFF43A047),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PostScreen())),
                          ),
                          SizedBox(height: 18),
                          _AnimatedMenuButton(
                            icon: Icons.person_outline,
                            label: AppLocalizations.of(context)?.aboutMe ?? 'About Me',
                            color: Color(0xFF283593),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AboutMeScreen())),
                          ),
                          SizedBox(height: 18),
                          _AnimatedMenuButton(
                            icon: Icons.more_horiz,
                            label: AppLocalizations.of(context)?.others ?? 'Others',
                            color: Color(0xFF512DA8),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OthersScreen())),
                          ),
                        ],
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

class _AnimatedMenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _AnimatedMenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  State<_AnimatedMenuButton> createState() => __AnimatedMenuButtonState();
}

class __AnimatedMenuButtonState extends State<_AnimatedMenuButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
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
        height: 54,
        child: ElevatedButton.icon(
          icon: Icon(widget.icon, color: Colors.white),
          label: Text(
            widget.label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
          ),
          onPressed: _animateAndAct,
        ),
      ),
    );
  }
}
