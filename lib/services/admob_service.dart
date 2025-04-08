import 'dart:io';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

// Import biến trạng thái Firebase từ main.dart
import 'package:newnoteapp/main.dart' show isFirebaseInitialized;

class AdMobService {
  // ID quảng cáo - Cần thay thế bằng ID thật khi publish ứng dụng
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // ID test cho Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // ID test cho iOS
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // ID test cho Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // ID test cho iOS
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // ID test cho Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // ID test cho iOS
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  // References
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  // Khởi tạo biến flags
  bool _isInitialized = false;
  bool _rewardedAdReady = false;
  bool _interstitialAdReady = false;
  
  // Đếm số lần user thực hiện hành động để hiển thị quảng cáo
  int _actionCount = 0;
  static const int actionThreshold = 5; // Sau 5 hành động sẽ hiển thị quảng cáo
  
  // Test ad units for development
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get rewardedAdReady => _rewardedAdReady;
  bool get interstitialAdReady => _interstitialAdReady;

  // Khởi tạo AdMob
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;
      
      // Kiểm tra xem Firebase đã khởi tạo được chưa
      if (!isFirebaseInitialized) {
        debugPrint('AdMobService: Firebase is not initialized, skipping AdMob initialization');
        _isInitialized = false;
        return;
      }
      
      // Thiết lập test mode cho mọi thiết bị
      final testDeviceIds = ["33BE2250B43518CCDA7DE426D04EE231"];
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: testDeviceIds)
      );
      
      _isInitialized = true;
      debugPrint('AdMobService initialized successfully');
    } catch (e) {
      _isInitialized = false;
      debugPrint('Error initializing AdMobService: $e');
    }
  }

  // Tạo banner ad - với kiểm tra Firebase
  BannerAd createBannerAd() {
    if (!_isInitialized || !isFirebaseInitialized) {
      debugPrint('Cannot create BannerAd: AdMobService not initialized or Firebase unavailable');
      // Return a dummy BannerAd that won't crash the app
      return BannerAd(
        adUnitId: _testBannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdFailedToLoad: (ad, error) {
            debugPrint('BannerAd failed to load: ${error.message}');
            ad.dispose();
          },
        ),
      );
    }
    
    return BannerAd(
      adUnitId: _testBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('BannerAd loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: ${error.message}');
          ad.dispose();
        },
      ),
    );
  }

  // Tạo banner ad lớn
  BannerAd createLargeBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.largeBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => print('Large banner ad loaded'),
        onAdFailedToLoad: (ad, error) {
          print('Large banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }

  // Tạo quảng cáo toàn màn hình
  Future<void> _createInterstitialAd() async {
    try {
      if (!_isInitialized || !isFirebaseInitialized) return;
      
      await InterstitialAd.load(
        adUnitId: _testInterstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _interstitialAdReady = true;
            debugPrint('Interstitial ad loaded successfully');
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAdReady = false;
            debugPrint('InterstitialAd failed to load: ${error.message}');
          },
        ),
      );
    } catch (e) {
      _interstitialAdReady = false;
      debugPrint('Error creating interstitial ad: $e');
    }
  }

  // Hiển thị quảng cáo toàn màn hình
  Future<bool> showInterstitialAd() async {
    if (!_isInitialized || !isFirebaseInitialized) {
      debugPrint('Cannot show interstitial ad: AdMobService not initialized or Firebase unavailable');
      return false;
    }
    
    if (_interstitialAd == null) {
      debugPrint('Interstitial ad not loaded yet');
      await _createInterstitialAd();
      return false;
    }
    
    try {
      await _interstitialAd!.show();
      _interstitialAdReady = false;
      _interstitialAd = null;
      _createInterstitialAd(); // Reload ad for next time
      return true;
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
      return false;
    }
  }

  // Tạo quảng cáo có thưởng
  Future<void> _createRewardedAd() async {
    try {
      if (!_isInitialized || !isFirebaseInitialized) return;
      
      await RewardedAd.load(
        adUnitId: _testRewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            _rewardedAd = ad;
            _rewardedAdReady = true;
            debugPrint('Rewarded ad loaded successfully');
          },
          onAdFailedToLoad: (LoadAdError error) {
            _rewardedAdReady = false;
            debugPrint('RewardedAd failed to load: ${error.message}');
          },
        ),
      );
    } catch (e) {
      _rewardedAdReady = false;
      debugPrint('Error creating rewarded ad: $e');
    }
  }

  // Hiển thị quảng cáo có thưởng
  Future<bool> showRewardedAd() async {
    if (!_isInitialized || !isFirebaseInitialized) {
      debugPrint('Cannot show rewarded ad: AdMobService not initialized or Firebase unavailable');
      return false;
    }
    
    if (_rewardedAd == null) {
      debugPrint('Rewarded ad not loaded yet');
      await _createRewardedAd();
      return false;
    }
    
    try {
      final completer = Completer<bool>();
      
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAdReady = false;
          _rewardedAd = null;
          _createRewardedAd(); // Reload ad for next time
          if (!completer.isCompleted) completer.complete(false);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedAdReady = false;
          _rewardedAd = null;
          _createRewardedAd(); // Reload ad for next time
          if (!completer.isCompleted) completer.complete(false);
        },
      );
      
      _rewardedAd!.show(onUserEarnedReward: (_, reward) {
        if (!completer.isCompleted) completer.complete(true);
      });
      
      return await completer.future;
    } catch (e) {
      debugPrint('Error showing rewarded ad: $e');
      return false;
    }
  }

  // Gọi khi người dùng thực hiện một hành động (tạo note, xóa, cập nhật)
  // Sẽ hiển thị quảng cáo sau một số lượng hành động nhất định
  Future<bool> trackUserAction() async {
    try {
      if (!_isInitialized || !isFirebaseInitialized) return false;
      
      _actionCount++;
      
      if (_actionCount >= actionThreshold) {
        _actionCount = 0;
        
        // Ưu tiên hiển thị interstitial first
        if (_interstitialAdReady) {
          return await showInterstitialAd();
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Error tracking user action: $e');
      return false;
    }
  }

  // Tải trước các quảng cáo
  Future<void> preloadAds() async {
    try {
      if (!_isInitialized || !isFirebaseInitialized) {
        debugPrint('Cannot preload ads: AdMobService not initialized or Firebase unavailable');
        return;
      }
      
      await _createInterstitialAd();
      await _createRewardedAd();
    } catch (e) {
      debugPrint('Error preloading ads: $e');
    }
  }

  // Giải phóng tài nguyên
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}