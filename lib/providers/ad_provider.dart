import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:newnoteapp/services/admob_service.dart';
import 'package:flutter/foundation.dart';

class AdProvider extends ChangeNotifier {
  final AdMobService _adMobService = AdMobService();
  
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isInitialized = false;
  
  // Số lần thử lại load quảng cáo
  int _bannerRetryAttempt = 0;
  int _interstitialRetryAttempt = 0;
  
  // Giới hạn số lần thử lại
  static const int maxRetryAttempts = 3;
  
  // Khóa cờ báo hiệu đang tải quảng cáo để tránh gọi đồng thời
  bool _isLoadingBanner = false;
  bool _isLoadingInterstitial = false;

  // Test ad units
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  // Getters
  BannerAd? get bannerAd => _bannerAd;
  InterstitialAd? get interstitialAd => _interstitialAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;

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
  Future<void> _loadBannerAd() async {
    if (_isLoadingBanner) return;
    _isLoadingBanner = true;
    
    try {
      // Dispose quảng cáo cũ nếu có
      if (_bannerAd != null) {
        await _bannerAd!.dispose();
        _bannerAd = null;
        _isBannerAdLoaded = false;
      }
      
      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            _isBannerAdLoaded = true;
            _bannerRetryAttempt = 0;
            _isLoadingBanner = false;
            notifyListeners();
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _bannerAd = null;
            _isBannerAdLoaded = false;
            _isLoadingBanner = false;
            
            // Thử lại load quảng cáo với delay tăng dần
            if (_bannerRetryAttempt < maxRetryAttempts) {
              _bannerRetryAttempt++;
              Future.delayed(
                Duration(milliseconds: _bannerRetryAttempt * 1000),
                _loadBannerAd,
              );
            }
            
            notifyListeners();
          },
        ),
      );

      await _bannerAd!.load();
    } catch (e) {
      _isBannerAdLoaded = false;
      _isLoadingBanner = false;
      debugPrint('Error loading banner ad: $e');
      
      // Thử lại load quảng cáo với delay tăng dần nếu xảy ra lỗi
      if (_bannerRetryAttempt < maxRetryAttempts) {
        _bannerRetryAttempt++;
        Future.delayed(
          Duration(milliseconds: _bannerRetryAttempt * 1000),
          _loadBannerAd,
        );
      }
    }
  }

  // Tải quảng cáo interstitial với cơ chế retry và bảo vệ gọi đồng thời
  Future<void> loadInterstitialAd() async {
    if (_isLoadingInterstitial) return;
    _isLoadingInterstitial = true;
    
    try {
      // Dispose quảng cáo cũ nếu có
      if (_interstitialAd != null) {
        await _interstitialAd!.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;
      }
      
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
            _interstitialRetryAttempt = 0;
            _isLoadingInterstitial = false;
            
            // Cài đặt callback khi ad bị đóng
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdLoaded = false;
                notifyListeners();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdLoaded = false;
                notifyListeners();
              },
            );
            
            notifyListeners();
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd = null;
            _isInterstitialAdLoaded = false;
            _isLoadingInterstitial = false;
            
            // Thử lại load quảng cáo với delay tăng dần
            if (_interstitialRetryAttempt < maxRetryAttempts) {
              _interstitialRetryAttempt++;
              Future.delayed(
                Duration(milliseconds: _interstitialRetryAttempt * 1000),
                loadInterstitialAd,
              );
            }
            
            notifyListeners();
          },
        ),
      );
    } catch (e) {
      _isInterstitialAdLoaded = false;
      _isLoadingInterstitial = false;
      debugPrint('Error loading interstitial ad: $e');
      
      // Thử lại load quảng cáo với delay tăng dần nếu xảy ra lỗi
      if (_interstitialRetryAttempt < maxRetryAttempts) {
        _interstitialRetryAttempt++;
        Future.delayed(
          Duration(milliseconds: _interstitialRetryAttempt * 1000),
          loadInterstitialAd,
        );
      }
    }
  }

  // Hiển thị quảng cáo interstitial nếu đã tải xong
  Future<bool> showInterstitialAd() async {
    if (_interstitialAd == null) {
      return false;
    }
    
    try {
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
      return false;
    }
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