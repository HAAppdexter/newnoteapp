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

  // Biến để theo dõi trạng thái cho interstitial
  DateTime? _lastInterstitialShownTime; // Thời điểm hiển thị quảng cáo gần nhất
  bool _isInEditingMode = false; // Cờ đánh dấu đang trong chế độ soạn thảo
  DateTime _appStartTime = DateTime.now(); // Thời điểm bắt đầu ứng dụng
  
  // Các khoảng thời gian
  static const int initialPeriodSeconds = 15; // 15 giây đầu
  static const int regularPeriodSeconds = 60; // 60 giây sau đó

  // Getters
  BannerAd? get bannerAd => _bannerAd;
  InterstitialAd? get interstitialAd => _interstitialAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;

  // Khởi tạo AdMob
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;
      
      await _adMobService.initialize();
      _isInitialized = true;
      
      // Lưu thời điểm bắt đầu ứng dụng
      _appStartTime = DateTime.now();
      
      // Tải quảng cáo banner với delay để tránh xung đột
      await Future.delayed(Duration(milliseconds: 300));
      await _loadBannerAd();
      
      // Khởi tạo interstitial ad với delay
      await Future.delayed(Duration(milliseconds: 300));
      await loadInterstitialAd();
      
      // Tải trước các quảng cáo
      _adMobService.preloadAds();

      debugPrint('AdProvider initialized at ${_appStartTime.toString()}');
    } catch (e) {
      debugPrint('AdProvider initialization error: $e');
    }
  }

  // Đánh dấu bắt đầu chế độ soạn thảo
  void enterEditingMode() {
    _isInEditingMode = true;
    notifyListeners();
  }

  // Đánh dấu kết thúc chế độ soạn thảo
  void exitEditingMode() {
    _isInEditingMode = false;
    notifyListeners();
  }

  // Kiểm tra xem có thể hiển thị interstitial không
  bool canShowInterstitial() {
    // Không hiển thị khi đang soạn thảo
    if (_isInEditingMode) return false;
    
    final now = DateTime.now();
    final sinceAppStart = now.difference(_appStartTime).inSeconds;
    
    // Trong 15 giây đầu tiên, luôn hiển thị khi có tương tác với button
    if (sinceAppStart <= initialPeriodSeconds) {
      debugPrint('Within initial $initialPeriodSeconds seconds, can show ad');
      return true;
    }
    
    // Sau 15 giây đầu, kiểm tra khoảng thời gian giữa các lần hiển thị
    if (_lastInterstitialShownTime != null) {
      final timeSinceLastAd = now.difference(_lastInterstitialShownTime!).inSeconds;
      
      // Chỉ hiển thị nếu đã qua 60 giây kể từ lần cuối hiển thị
      final canShow = timeSinceLastAd >= regularPeriodSeconds;
      debugPrint('Last ad shown $timeSinceLastAd seconds ago, can show: $canShow');
      return canShow;
    }
    
    // Nếu chưa từng hiển thị quảng cáo, có thể hiển thị
    return true;
  }

  // Cập nhật thời gian hiển thị quảng cáo gần nhất
  void _updateLastShownTime() {
    _lastInterstitialShownTime = DateTime.now();
    debugPrint('Updated last ad shown time to: ${_lastInterstitialShownTime.toString()}');
    notifyListeners();
  }

  // Tải banner ad
  Future<void> _loadBannerAd() async {
    try {
      if (_isLoadingBanner) return;
      _isLoadingBanner = true;
      
      // Dispose quảng cáo cũ nếu có
      if (_bannerAd != null) {
        await _bannerAd!.dispose();
        _bannerAd = null;
        _isBannerAdLoaded = false;
        notifyListeners(); // Notify listeners when the ad is disposed
        
        // Delay nhỏ trước khi tạo ad mới để tránh xung đột
        await Future.delayed(Duration(milliseconds: 100));
      }
      
      // Check if the ad has already been created by another part of the app
      if (!_isBannerAdLoaded) {
        _bannerAd = BannerAd(
          adUnitId: _bannerAdUnitId,
          size: AdSize.banner,
          request: const AdRequest(),
          listener: BannerAdListener(
            onAdLoaded: (_) {
              _isBannerAdLoaded = true;
              _bannerRetryAttempt = 0;
              _isLoadingBanner = false;
              debugPrint('Banner ad loaded successfully');
              notifyListeners();
            },
            onAdFailedToLoad: (ad, error) {
              debugPrint('Banner ad failed to load: ${error.message}');
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
      }
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

  // Tải quảng cáo interstitial
  Future<void> loadInterstitialAd() async {
    try {
      if (_isLoadingInterstitial) return;
      _isLoadingInterstitial = true;
      
      if (_interstitialAd != null) {
        await _interstitialAd!.dispose();
        _interstitialAd = null;
      }
      
      InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
            _interstitialRetryAttempt = 0;
            _isLoadingInterstitial = false;
            
            // Thiết lập callback cho quảng cáo
            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdLoaded = false;
                // Tải lại quảng cáo mới
                loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdLoaded = false;
                // Tải lại quảng cáo mới
                loadInterstitialAd();
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

  // Hiển thị quảng cáo interstitial khi button được click
  Future<bool> showInterstitialOnButtonClick() async {
    // Nếu đang soạn thảo hoặc không thể hiển thị, trả về false
    if (!canShowInterstitial() || _interstitialAd == null) {
      return false;
    }
    
    try {
      debugPrint('Showing interstitial ad');
      await _interstitialAd!.show();
      // Cập nhật thời gian hiển thị gần nhất
      _updateLastShownTime();
      return true;
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
      return false;
    }
  }

  // Hiển thị quảng cáo có thưởng
  Future<bool> showRewardedAd() async {
    try {
      return await _adMobService.showRewardedAd();
    } catch (e) {
      debugPrint('Error showing rewarded ad: $e');
      return false;
    }
  }

  // Theo dõi khi người dùng nhấn button
  Future<void> trackButtonClick() async {
    try {
      // Gọi để hiển thị quảng cáo interstitial theo điều kiện mới
      await showInterstitialOnButtonClick();
    } catch (e) {
      debugPrint('Error tracking button click: $e');
    }
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