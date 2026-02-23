import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:united_areechola/common/common.dart';
import 'package:united_areechola/launch/launch_Splash.dart';

import 'package:united_areechola/intro/onboarding_main.dart';

/// Main launcher that coordinates the launch experience
/// Shows splash → onboarding → main app
class AppLauncher extends StatefulWidget {
  final Widget mainApp;
  const AppLauncher({super.key, required this.mainApp});

  @override
  State<AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  bool _showSplash = true;
  bool _showOnboarding = false;
  bool _showMainApp = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final settings = await db.collection("settings").doc("settings").get();
      final data = settings.data() ?? {};
      
      // Default to FALSE if key is missing
      final bool showLaunchExperience = data['app_launch'] ?? false;

      if (!showLaunchExperience) {
        // Force skip if app_launch is false or missing
        if (mounted) {
          setState(() {
            _showSplash = false;
            _showOnboarding = false;
            _showMainApp = true;
          });
        }
        return;
      }
      
      // Validated: app_launch is TRUE.
      // Now checking if user has already seen it (optional - could force show if needed)
      
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      // If you want to FORCE show it every time app_launch is true, comment out this block:
      if (hasSeenOnboarding) {
         // setState(() {
         //   _showSplash = false;
         //   _showMainApp = true;
         // });
      }
      
    } catch (e) {
      debugPrint("Error checking launch settings: $e");
      // Fallback: Skip to main app on error
      if (mounted) {
        setState(() {
          _showSplash = false;
          _showOnboarding = false;
          _showMainApp = true;
        });
      }
    }
  }

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
      _showOnboarding = true;
    });
  }

  Future<void> _onOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    setState(() {
      _showOnboarding = false;
      _showMainApp = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return LaunchSplashScreen(onComplete: _onSplashComplete);
    }


    
    if (_showOnboarding) {
      return OnboardingMain(onComplete: _onOnboardingComplete);
    }

    return widget.mainApp;
  }
}

/// Alternative: Simple version without checking SharedPreferences
/// Use this if you want to show splash and onboarding to everyone on launch day
class SimpleLauncher extends StatefulWidget {
  final Widget mainApp;
  const SimpleLauncher({super.key, required this.mainApp});

  @override
  State<SimpleLauncher> createState() => _SimpleLauncherState();
}

class _SimpleLauncherState extends State<SimpleLauncher> {
  int _currentStep = 0; // 0: splash, 1: onboarding, 2: main app

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return LaunchSplashScreen(
          onComplete: () => setState(() => _currentStep = 1),
        );
      case 1:
        return OnboardingMain(
          onComplete: () => setState(() => _currentStep = 2),
        );
      default:
        return widget.mainApp;
    }
  }
}
