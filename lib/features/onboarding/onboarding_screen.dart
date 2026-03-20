import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../features/home/widgets/star_field_painter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      imagePath: 'assets/icon.png',
      title: '우리가 하는',
      subtitle: '걱정의 90%는\n일어나지 않습니다',
      body: '확인해봐요!',
    ),
    _OnboardingPage(
      imagePath: 'assets/icon.png',
      title: '별처럼 떠 있다가',
      subtitle: '때가 되면\n다시 꺼내봐요',
      body: '지정한 날이 오면\n조용히 알려드릴게요',
    ),
    _OnboardingPage(
      imagePath: 'assets/icon.png',
      title: '그때의 걱정이',
      subtitle: '지금은 어떻게\n느껴지나요?',
      body: '일어나지 않았죠?',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedStarField(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) => _pages[i],
                ),
              ),
              _buildBottom(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottom() {
    final isLast = _currentPage == _pages.length - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
      child: Column(
        children: [
          // Page dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? AppColors.accentBlue
                      : AppColors.starDim,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          // Button
          GestureDetector(
            onTap: isLast
                ? _finish
                : () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                    ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: isLast
                      ? [
                          AppColors.accentBlue.withOpacity(0.8),
                          AppColors.accentPurple.withOpacity(0.8),
                        ]
                      : [
                          AppColors.backgroundCard,
                          AppColors.backgroundCard,
                        ],
                ),
                border: Border.all(
                  color: isLast ? Colors.transparent : AppColors.divider,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  isLast ? '시작하기' : '다음',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          if (!isLast)
            TextButton(
              onPressed: _finish,
              child: const Text(
                '건너뛰기',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String body;

  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Image.asset(
            imagePath,
            width: 180,
            fit: BoxFit.contain,
          )
              .animate()
              .fadeIn(duration: 800.ms, curve: Curves.easeOut)
              .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
          const SizedBox(height: 48),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 600.ms),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w300,
              height: 1.4,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: 400.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.1, curve: Curves.easeOut),
          const SizedBox(height: 24),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: 600.ms)
              .fadeIn(duration: 600.ms),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
