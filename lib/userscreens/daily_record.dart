import 'package:hive/hive.dart';

part 'daily_record.g.dart'; // Generated file for Hive

@HiveType(typeId: 0)
class DailyRecord extends HiveObject {
  @HiveField(0)
  String date;

  @HiveField(1)
  int steps;

  @HiveField(2)
  double calories;

  @HiveField(3)
  double distance;

  DailyRecord({
    required this.date,
    required this.steps,
    required this.calories,
    required this.distance,
  });
}