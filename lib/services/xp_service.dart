import '../models/user_progress.dart';

class XPService {

  static const int xpPerLevel = 100;

  static int calculateLevel(int xp) {

    if (xp < 0) {
      return 1;
    }

    return (xp ~/ xpPerLevel) + 1;
  }

  static int currentLevelXP(int xp) {

    return xp % xpPerLevel;
  }

  static int xpToNextLevel(int xp) {

    return xpPerLevel -
        currentLevelXP(xp);
  }

  static UserProgress addXP(
    UserProgress progress,
    int points,
  ) {

    if (points <= 0) {
      return progress;
    }

    progress.xp += points;

    progress.level =
        calculateLevel(progress.xp);

    progress =
        updateAvatar(progress);

    return progress;
  }

  static UserProgress removeXP(
    UserProgress progress,
    int points,
  ) {

    if (points <= 0) {
      return progress;
    }

    progress.xp -= points;

    if (progress.xp < 0) {

      progress.xp = 0;
    }

    progress.level =
        calculateLevel(progress.xp);

    progress =
        updateAvatar(progress);

    return progress;
  }


  static UserProgress addStars(
    UserProgress progress,
    int stars,
  ) {

    if (stars <= 0) {
      return progress;
    }

    progress.stars += stars;

    return progress;
  }

  static UserProgress removeStars(
    UserProgress progress,
    int stars,
  ) {

    if (stars <= 0) {
      return progress;
    }

    progress.stars -= stars;

    if (progress.stars < 0) {

      progress.stars = 0;
    }

    return progress;
  }

  static UserProgress addBonusXP(
    UserProgress progress,
  ) {

    progress.xp += 50;

    progress.level =
        calculateLevel(progress.xp);

    progress =
        updateAvatar(progress);

    return progress;
  }


  static UserProgress dailyReward(
    UserProgress progress,
  ) {

 

    progress.xp += 20;

    progress.stars += 5;

  

    if (progress.streak >= 7) {

      progress.xp += 30;

      progress.stars += 10;
    }

    progress.level =
        calculateLevel(progress.xp);

    progress =
        updateAvatar(progress);

    return progress;
  }


  static UserProgress rewardTransaction(
    UserProgress progress,
    double amount,
  ) {

    

    progress =
        addXP(progress, 15);

    progress =
        addStars(progress, 2);

  

    if (amount >= 1000) {

      progress =
          addXP(progress, 20);

      progress =
          addStars(progress, 5);
    }

    

    if (amount >= 5000) {

      progress =
          addXP(progress, 50);

      progress =
          addStars(progress, 10);
    }

    return progress;
  }


  static UserProgress updateAvatar(
    UserProgress progress,
  ) {


    if (progress.level >= 15) {

      progress.avatar =
          'assets/avatar1.png';
    }

   

    else if (progress.level >= 10) {

      progress.avatar =
          'assets/avatar3.png';
    }


    else if (progress.level >= 5) {

      progress.avatar =
          'assets/avatar2.png';
    }

 

    else {

      progress.avatar =
          'assets/avatar1.png';
    }

    return progress;
  }



  static UserProgress updateProgress(
    UserProgress progress,
  ) {

    if (progress.xp < 0) {

      progress.xp = 0;
    }

    if (progress.stars < 0) {

      progress.stars = 0;
    }


    progress.level =
        calculateLevel(progress.xp);

    

    if (progress.level < 1) {

      progress.level = 1;
    }


    progress =
        updateAvatar(progress);

    return progress;
  }
}