import 'package:flutter/material.dart';
import 'package:radio_player/core/theme/app_theme.dart';
import 'package:radio_player/core/theme/text_styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sensors, size: 96, color: AppTheme.primaryPurple),
            const SizedBox(height: 28),
            Text('RadioWave', style: AppTextStyles.splashTitle),
            const SizedBox(height: 8),
            Text(
              'Listen to your favorite radio stations',
              style: AppTextStyles.splashSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}
