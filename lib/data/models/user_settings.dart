import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 1)
class UserSettings extends HiveObject {
  @HiveField(0)
  double? co2Budget;

  @HiveField(1)
  double? waterBudget;

  @HiveField(2)
  double? costBudget;
}
