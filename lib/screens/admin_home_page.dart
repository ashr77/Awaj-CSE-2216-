import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_post_page.dart';
import 'admin_report_page.dart';
import '../theme_locale_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> with SingleTickerProviderStateMixin {
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.adminDashboard ?? 'Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF1A237E),
        automaticallyImplyLeading: false,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.white),
            onPressed: () {
              Provider.of<ThemeLocaleProvider>(context, listen: false).toggleLocale();
            },
            tooltip: AppLocalizations.of(context)?.toggleLanguage ?? 'Toggle Language',
          ),
          IconButton(
            icon: Icon(Icons.brightness_6, color: Colors.white),
            onPressed: () {
              Provider.of<ThemeLocaleProvider>(context, listen: false).toggleTheme();
            },
            tooltip: AppLocalizations.of(context)?.toggleTheme ?? 'Toggle Theme',
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: AppLocalizations.of(context)?.signOut ?? 'Sign Out',
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AnimatedAdminCard(
                    icon: Icons.post_add,
                    label: AppLocalizations.of(context)?.managePosts ?? 'Manage Posts',
                    color: Color(0xFF1A237E),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPostPage()));
                    },
                  ),
                  SizedBox(height: 32),
                  _AnimatedAdminCard(
                    icon: Icons.report,
                    label: AppLocalizations.of(context)?.manageReports ?? 'Manage Reports',
                    color: Color(0xFFD32F2F),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AdminReportPage()));
                    },
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

class _AnimatedAdminCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _AnimatedAdminCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  State<_AnimatedAdminCard> createState() => __AnimatedAdminCardState();
}

class __AnimatedAdminCardState extends State<_AnimatedAdminCard> with SingleTickerProviderStateMixin {
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
        height: 80,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.18),
              blurRadius: 12,
              offset: Offset(0, 6),
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
                Icon(widget.icon, color: Colors.white, size: 32),
                SizedBox(width: 20),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
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
