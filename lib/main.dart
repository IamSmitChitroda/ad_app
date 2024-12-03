import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ads Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AdsDemo(),
    );
  }
}

class AdsDemo extends StatefulWidget {
  @override
  _AdsDemoState createState() => _AdsDemoState();
}

class _AdsDemoState extends State<AdsDemo> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeAds();
  }

  /// Initializes all ad types.
  void _initializeAds() {
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  /// Loads a Banner Ad.
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/9214589741', // Test Ad Unit
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() => _isBannerAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Failed to load Banner Ad: $error');
        },
      ),
    )..load();
  }

  /// Loads an Interstitial Ad.
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test Ad Unit
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Failed to load Interstitial Ad: $error');
        },
      ),
    );
  }

  /// Loads a Rewarded Ad.
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // Test Ad Unit
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
            _isRewardedAdLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          debugPrint('Failed to load Rewarded Ad: $error');
        },
      ),
    );
  }

  /// Shows an Interstitial Ad.
  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd!.dispose();
      _interstitialAd = null;
      _loadInterstitialAd(); // Reload after showing
    }
  }

  /// Shows a Rewarded Ad.
  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reward earned: ${reward.amount} ${reward.type}'),
            ),
          );
        },
      );
      _rewardedAd!.dispose();
      _rewardedAd = null;
      _loadRewardedAd(); // Reload after showing
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ads Demo')),
      body: Column(
        children: [
          if (_isBannerAdLoaded)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed:
                        _isInterstitialAdLoaded ? _showInterstitialAd : null,
                    child: const Text('Show Interstitial Ad'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isRewardedAdLoaded ? _showRewardedAd : null,
                    child: const Text('Show Rewarded Ad'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
