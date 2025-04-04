import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:newnoteapp/services/admob_service.dart';

class AdProvider extends ChangeNotifier {
  final AdMobService _adMobService = AdMobService();
  
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool _isInitialized = false;

  // Getters
  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  // Khởi tạo AdMob
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _adMobService.initialize();
    _isInitialized = true;
    
    // Tải quảng cáo banner
    _loadBannerAd();
    
    // Tải trước các quảng cáo
    _adMobService.preloadAds();
  }

  // Tải banner ad
  void _loadBannerAd() {
    _bannerAd = _adMobService.createBannerAd()
      ..load().then((_) {
        _isBannerAdLoaded = true;
        notifyListeners();
      }).catchError((error) {
        print('Error loading banner ad: $error');
        _isBannerAdLoaded = false;
        notifyListeners();
      });
  }

  // Tải lại banner ad
  void reloadBannerAd() {
    _disposeBannerAd();
    _loadBannerAd();
  }

  // Hiển thị quảng cáo toàn màn hình
  Future<void> showInterstitialAd() async {
    await _adMobService.showInterstitialAd();
  }

  // Hiển thị quảng cáo có thưởng
  Future<bool> showRewardedAd() async {
    return await _adMobService.showRewardedAd();
  }

  // Theo dõi hành động người dùng
  Future<void> trackUserAction() async {
    await _adMobService.trackUserAction();
  }

  // Giải phóng tài nguyên
  void _disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  @override
  void dispose() {
    _disposeBannerAd();
    _adMobService.dispose();
    super.dispose();
  }
} 