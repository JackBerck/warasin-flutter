import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/onboarding_model.dart';
import '../../providers/onboarding_provider.dart';
import '../../../../core/config/router.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data onboarding
  final List<OnboardingModel> _onboardingPages = [
    OnboardingModel(
      title: 'Pengingat Obat Otomatis',
      description:
          'Tidak akan pernah lupa minum obat lagi! WarasIn akan mengingatkan Anda tepat waktu setiap harinya.',
      image: 'assets/images/onboarding/flag.png',
    ),
    OnboardingModel(
      title: 'Catatan Kesehatan Harian',
      description:
          'Catat tekanan darah, gula darah, dan kondisi kesehatan Anda dengan mudah. Pantau perkembangan kesehatan Anda.',
      image: 'assets/images/onboarding/book.png',
    ),
    OnboardingModel(
      title: 'Mudah & Ramah Lansia',
      description:
          'Antarmuka sederhana dan mudah dipahami. Dirancang khusus untuk orang tua dan lansia.',
      image: 'assets/images/onboarding/elderly.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleOfflineMode() async {
    final onboardingService = ref.read(onboardingServiceProvider);

    // Set mode offline
    await onboardingService.setAppMode(true);
    await onboardingService.completeOnboarding();

    if (mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  void _handleOnlineMode() async {
    final onboardingService = ref.read(onboardingServiceProvider);

    // Set mode online
    await onboardingService.setAppMode(false);
    await onboardingService.completeOnboarding();

    if (mounted) {
      context.go(AppRoutes.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _onboardingPages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (!isLastPage)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    _pageController.animateToPage(
                      _onboardingPages.length - 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Lewati', style: TextStyle(fontSize: 16)),
                ),
              ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingPages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingContent(_onboardingPages[index]);
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _onboardingPages.length,
                effect: WormEffect(
                  dotHeight: 12,
                  dotWidth: 12,
                  spacing: 16,
                  dotColor: Colors.grey.shade300,
                  activeDotColor: Theme.of(context).primaryColor,
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: isLastPage
                  ? _buildModeSelectionButtons()
                  : _buildNextButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingContent(OnboardingModel page) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(page.image, height: 250, fit: BoxFit.contain),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Lanjut',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildModeSelectionButtons() {
    return Column(
      children: [
        // Info text
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Pilih mode aplikasi:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Online mode button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _handleOnlineMode,
            icon: const Icon(Icons.cloud),
            label: const Text(
              'Mode Online',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Offline mode button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _handleOfflineMode,
            icon: const Icon(Icons.cloud_off),
            label: const Text(
              'Mode Offline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Helper text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Mode online memerlukan akun untuk sinkronisasi data.\nMode offline dapat langsung digunakan tanpa akun.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
