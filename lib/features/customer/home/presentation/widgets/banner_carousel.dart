import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class BannerCarousel extends StatefulWidget {
  final List<String> banners;

  const BannerCarousel({
    super.key,
    required this.banners,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < widget.banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.all(AppSizes.paddingMD),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            child: SizedBox(
              height: AppSizes.bannerHeight,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: widget.banners.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: AppColors.primaryOrange.withValues(alpha: 0.1),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant,
                            size: AppSizes.iconXXL,
                            color: AppColors.primaryOrange,
                          ),
                          SizedBox(height: AppSizes.spacingSM),
                          Text(
                            'Delicious Food Awaits!',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: AppSizes.spacingXS),
                          Text(
                            'Order now and enjoy',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: AppSizes.spacingSM),
          SmoothPageIndicator(
            controller: _pageController,
            count: widget.banners.length,
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.primaryOrange,
              dotColor: AppColors.divider,
              dotHeight: 8,
              dotWidth: 8,
              spacing: 4,
            ),
          ),
        ],
      ),
    );
  }
}
