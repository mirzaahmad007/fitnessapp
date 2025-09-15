// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyRecordAdapter extends TypeAdapter<DailyRecord> {
  @override
  final int typeId = 0;

  @override
  DailyRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyRecord(
      date: fields[0] as String,
      steps: fields[1] as int,
      calories: fields[2] as double,
      distance: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DailyRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.steps)
      ..writeByte(2)
      ..write(obj.calories)
      ..writeByte(3)
      ..write(obj.distance);
  }
}