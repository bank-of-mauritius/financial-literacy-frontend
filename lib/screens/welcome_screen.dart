import 'package:flutter/material.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';

// Add this import to your main.dart file:
// import 'package:financial_literacy_frontend/screens/welcome_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _logoController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;

  int _currentPage = 0;

  final List<WelcomeSlide> _slides = [
    WelcomeSlide(
      title: "Welcome to\nFinancial Literacy",
      subtitle: "Your journey to financial freedom starts here",
      description: "Master the art of money management with our comprehensive learning platform",
      icon: Icons.account_balance,
      gradient: [AppColors.primary, AppColors.primaryLight],
      showLogo: true,
    ),
    WelcomeSlide(
      title: "AI Financial\nAssistant",
      subtitle: "Get personalized financial guidance",
      description: "Chat with our intelligent AI assistant for instant answers to your financial questions",
      icon: Icons.smart_toy_outlined,
      gradient: [AppColors.secondary, AppColors.secondaryLight],
      showLogo: false,
    ),
    WelcomeSlide(
      title: "Gamified\nLearning",
      subtitle: "Learn through fun quizzes & achievements",
      description: "Earn points, unlock badges, and compete with others while mastering financial concepts",
      icon: Icons.emoji_events_outlined,
      gradient: [AppColors.success, AppColors.successLight],
      showLogo: false,
    ),
    WelcomeSlide(
      title: "Live Market\nData",
      subtitle: "Stay updated with real-time indicators",
      description: "Track market trends and economic indicators to make informed financial decisions",
      icon: Icons.trending_up,
      gradient: [AppColors.accent, AppColors.primary],
      showLogo: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _logoController.forward();
  }

  void _resetAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _resetAnimations();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _skipToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _slides[_currentPage].gradient,
              ),
            ),
          ),

          // Floating shapes for visual interest
          ...List.generate(6, (index) => _buildFloatingShape(index)),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _skipToHome,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      return _buildSlide(_slides[index]);
                    },
                  ),
                ),

                // Bottom section with indicators and button
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                              (index) => _buildIndicator(index),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Action button
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: SizedBox(
                          key: ValueKey(_currentPage),
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: _slides[_currentPage].gradient[0],
                              elevation: 8,
                              shadowColor: AppColors.primaryLight.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Text(
                              _currentPage == _slides.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(WelcomeSlide slide) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon or Logo
              if (slide.showLogo)
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _logoRotationAnimation.value * 0.1,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.white.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/bank_logo.png',
                              width: 80,
                              height: 80,
                              color: AppColors.white,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              else
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.white.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    slide.icon,
                    size: 60,
                    color: AppColors.white,
                  ),
                ),

              const SizedBox(height: 48),

              // Title
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                slide.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white.withOpacity(0.9),
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 24),

              // Description
              Text(
                slide.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.white
            : AppColors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildFloatingShape(int index) {
    final positions = [
      const Alignment(-0.8, -0.6),
      const Alignment(0.9, -0.4),
      const Alignment(-0.6, 0.3),
      const Alignment(0.7, 0.6),
      const Alignment(-0.3, -0.9),
      const Alignment(0.4, -0.7),
    ];

    final sizes = [60.0, 40.0, 80.0, 50.0, 30.0, 70.0];
    final opacities = [0.1, 0.15, 0.08, 0.12, 0.2, 0.1];

    return AnimatedPositioned(
      duration: Duration(milliseconds: 2000 + (index * 200)),
      left: MediaQuery.of(context).size.width *
          (positions[index].x + 1) / 2 - sizes[index] / 2,
      top: MediaQuery.of(context).size.height *
          (positions[index].y + 1) / 2 - sizes[index] / 2,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 1500 + (index * 300)),
        width: sizes[index],
        height: sizes[index],
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(opacities[index]),
          shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: index % 2 != 0 ? BorderRadius.circular(16) : null,
        ),
      ),
    );
  }
}

class WelcomeSlide {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final bool showLogo;

  WelcomeSlide({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.showLogo,
  });
}