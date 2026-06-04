import 'package:flutter/material.dart';

import '../models/user_progress.dart';
import '../services/streak_service.dart';
import '../services/xp_service.dart';
import '../widgets/avatar_card.dart';

class RewardScreen extends StatefulWidget {

  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() =>
      _RewardScreenState();
}

class _RewardScreenState
    extends State<RewardScreen> {

  UserProgress progress = UserProgress(
    xp: 0,
    level: 1,
    stars: 0,
    streak: 0,
    avatar: 'assets/avatar1.png',
    lastLogin: '',
  );

  @override
  void initState() {
    super.initState();

    progress =
        StreakService.updateLoginStreak(
            progress);

    progress =
        XPService.addXP(progress, 10);

    progress =
        XPService.addStars(progress, 5);

    progress =
        XPService.updateAvatar(progress);
  }

  void addExpenseReward() {

    setState(() {

      progress =
          XPService.addXP(progress, 5);

      progress =
          XPService.addStars(progress, 2);

      progress =
          XPService.updateAvatar(progress);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Rewards & Avatar'),
      ),

      body: Column(
        children: [

          AvatarCard(progress: progress),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: addExpenseReward,
            child:
                const Text('Add Expense Reward'),
          ),
        ],
      ),
    );
  }
}