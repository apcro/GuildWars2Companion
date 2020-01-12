import 'package:guildwars2_companion/models/achievement/achievement.dart';
import 'package:guildwars2_companion/models/achievement/achievement_group.dart';
import 'package:guildwars2_companion/models/achievement/daily.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AchievementState {}
  
class LoadingAchievementsState extends AchievementState {}

class LoadedAchievementsState extends AchievementState {
  final List<AchievementGroup> achievementGroups;
  final DailyGroup dailyGroup;
  final List<Achievement> achievements;
  final bool includesProgress;

  LoadedAchievementsState({
    @required this.achievementGroups,
    @required this.dailyGroup,
    @required this.achievements,
    @required this.includesProgress,
  });
}