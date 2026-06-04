import 'package:flutter/material.dart';

import '../models/user_progress.dart';

class AvatarCard extends StatelessWidget {
  final UserProgress progress;

  const AvatarCard({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final double progressValue =
        (progress.xp % 100) / 100;

    return Container(
      width: double.infinity,

      //////////////////////////////////////////////////
      // REMOVE EXTRA HORIZONTAL MARGIN
      //////////////////////////////////////////////////

      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(24),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [
            Color(0xFF6A11CB),
            Color(0xFF9C27B0),
          ],
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.purple.withOpacity(0.3),

            blurRadius: 12,

            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          //////////////////////////////////////////////////
          // AVATAR
          //////////////////////////////////////////////////

          Container(
            padding: const EdgeInsets.all(3),

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),

            child: CircleAvatar(
              radius: 28,

              backgroundImage:
                  AssetImage(progress.avatar),

              backgroundColor: Colors.white,
            ),
          ),

          const SizedBox(width: 12),

          //////////////////////////////////////////////////
          // DETAILS
          //////////////////////////////////////////////////

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisSize: MainAxisSize.min,

              children: [
                //////////////////////////////////////////////////
                // LEVEL
                //////////////////////////////////////////////////

                FittedBox(
                  fit: BoxFit.scaleDown,

                  alignment:
                      Alignment.centerLeft,

                  child: Text(
                    'Level ${progress.level}',

                    maxLines: 1,

                    overflow:
                        TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                //////////////////////////////////////////////////
                // XP BAR
                //////////////////////////////////////////////////

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10),

                  child:
                      LinearProgressIndicator(
                    value: progressValue,

                    minHeight: 8,

                    backgroundColor:
                        Colors.white24,

                    valueColor:
                        const AlwaysStoppedAnimation(
                      Colors.amber,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${progress.xp} XP',

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 12),

                //////////////////////////////////////////////////
                // STARS + STREAK
                //////////////////////////////////////////////////

                Wrap(
                  spacing: 12,
                  runSpacing: 8,

                  children: [
                    //////////////////////////////////////////////////
                    // STARS
                    //////////////////////////////////////////////////

                    Row(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 18,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          '${progress.stars} Stars',

                          overflow:
                              TextOverflow
                                  .ellipsis,

                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight
                                    .w600,

                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    //////////////////////////////////////////////////
                    // STREAK
                    //////////////////////////////////////////////////

                    Row(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [
                        const Icon(
                          Icons
                              .local_fire_department,

                          color: Colors.orange,

                          size: 18,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          '${progress.streak} Day Streak',

                          overflow:
                              TextOverflow
                                  .ellipsis,

                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight
                                    .w600,

                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}