import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//Aditto_09
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _iconScaleAnimation;

  bool showTagline = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _iconScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    Future.delayed(Duration(milliseconds: 700), () {
      if (mounted) setState(() => showTagline = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _iconScaleAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black12,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Image.asset('assets/images/cor.jpg', width: 120, height: 120),
                    ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Awaj',
                    style: TextStyle(
                      color: Color(0xFF1A237E),
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black12,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  AnimatedOpacity(
                    opacity: showTagline ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 700),
                    child: Text(
                      'Report & Track Corruption Anonymously',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 36),
                  Card(
                    color: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 32),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      child: Column(
                        children: [
                          _AnimatedHomeButton(
                            icon: Icons.login,
                            label: 'Sign In',
                            onTap: () => Navigator.pushNamed(context, '/signin'),
                            color: Color(0xFF1A237E),
                          ),
                          SizedBox(height: 20),
                          _AnimatedHomeButton(
                            icon: Icons.person_add,
                            label: 'Sign Up',
                            onTap: () => Navigator.pushNamed(context, '/signup'),
                            color: Color(0xFF43A047),
                          ),
                          SizedBox(height: 20),
                          _AnimatedHomeButton(
                            icon: Icons.exit_to_app,
                            label: 'Exit',
                            onTap: () => SystemNavigator.pop(),
                            color: Color(0xFFD32F2F),
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

class _AnimatedHomeButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _AnimatedHomeButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  __AnimatedHomeButtonState createState() => __AnimatedHomeButtonState();
}

class __AnimatedHomeButtonState extends State<_AnimatedHomeButton> with SingleTickerProviderStateMixin {
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
    widget.onTap();
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
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
          ),
          onPressed: _animateAndAct,
        ),
      ),
    );
  }
}
