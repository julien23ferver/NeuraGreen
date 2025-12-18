// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_usage_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AiUsageLogAdapter extends TypeAdapter<AiUsageLog> {
  @override
  final int typeId = 0;

  @override
  AiUsageLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiUsageLog(
      provider: fields[0] as String,
      modelId: fields[1] as String,
      promptTokens: fields[2] as int,
      completionTokens: fields[3] as int,
      timestamp: fields[4] as DateTime,
      costUsd: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, AiUsageLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.provider)
      ..writeByte(1)
      ..write(obj.modelId)
      ..writeByte(2)
      ..write(obj.promptTokens)
      ..writeByte(3)
      ..write(obj.completionTokens)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.costUsd);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiUsageLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
