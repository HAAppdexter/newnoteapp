import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

  // Singleton pattern
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Biến lưu trữ các quảng cáo
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _interstitialLoadAttempts = 0;
  int _rewardedAdLoadAttempts = 0;
  int _actionsSinceLastInterstitial = 0;
  
  // Số lượng hành động trước khi hiển thị quảng cáo
  static const int actionsBeforeInterstitial = 5;
  
  // Số lần tối đa thử tải quảng cáo
  static const int maxFailedLoadAttempts = 3;

  // Khởi tạo AdMob
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    
    // Tải quảng cáo toàn màn hình
    _createInterstitialAd();
  }

  // Tạo banner ad
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => print('Ad loaded: ${ad.adUnitId}'),
        onAdFailedToLoad: (ad, error) {
          print('Ad failed to load: ${ad.adUnitId}, $error');
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
  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          _interstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_interstitialLoadAttempts < maxFailedLoadAttempts) {
            _createInterstitialAd();
          }
        },
      ),
    );
  }

  // Hiển thị quảng cáo toàn màn hình
  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) {
      print('Warning: hiển thị quảng cáo khi chưa sẵn sàng.');
      _createInterstitialAd();
      return;
    }
    
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _createInterstitialAd();
      },
    );
    
    await _interstitialAd!.show();
    _interstitialAd = null;
  }

  // Tạo quảng cáo có thưởng
  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAdLoadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          _rewardedAdLoadAttempts += 1;
          _rewardedAd = null;
          if (_rewardedAdLoadAttempts < maxFailedLoadAttempts) {
            _createRewardedAd();
          }
        },
      ),
    );
  }

  // Hiển thị quảng cáo có thưởng
  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      print('Warning: hiển thị quảng cáo có thưởng khi chưa sẵn sàng.');
      _createRewardedAd();
      return false;
    }
    
    bool userEarnedReward = false;
    
    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        userEarnedReward = true;
      },
    );
    
    _rewardedAd = null;
    _createRewardedAd();
    
    return userEarnedReward;
  }

  // Gọi khi người dùng thực hiện một hành động (tạo note, xóa, cập nhật)
  // Sẽ hiển thị quảng cáo sau một số lượng hành động nhất định
  Future<void> trackUserAction() async {
    _actionsSinceLastInterstitial++;
    
    if (_actionsSinceLastInterstitial >= actionsBeforeInterstitial) {
      _actionsSinceLastInterstitial = 0;
      await showInterstitialAd();
    }
  }

  // Tải trước các quảng cáo
  void preloadAds() {
    if (_interstitialAd == null) {
      _createInterstitialAd();
    }
    
    if (_rewardedAd == null) {
      _createRewardedAd();
    }
  }

  // Giải phóng tài nguyên
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}