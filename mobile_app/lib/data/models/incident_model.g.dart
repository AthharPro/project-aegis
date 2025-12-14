// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IncidentModelAdapter extends TypeAdapter<IncidentModel> {
  @override
  final int typeId = 1;

  @override
  IncidentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IncidentModel(
      id: fields[0] as String,
      type: fields[1] as IncidentType,
      severity: fields[2] as int,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      localImagePath: fields[5] as String?,
      supabaseImageUrl: fields[11] as String?,
      createdAt: fields[6] as DateTime,
      synced: fields[7] as bool,
      userId: fields[8] as String,
      victimCount: fields[9] as int?,
      status: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, IncidentModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.severity)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.localImagePath)
      ..writeByte(11)
      ..write(obj.supabaseImageUrl)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.synced)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.victimCount)
      ..writeByte(10)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncidentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IncidentTypeAdapter extends TypeAdapter<IncidentType> {
  @override
  final int typeId = 0;

  @override
  IncidentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IncidentType.landslide;
      case 1:
        return IncidentType.flood;
      case 2:
        return IncidentType.roadBlock;
      case 3:
        return IncidentType.powerLineDown;
      default:
        return IncidentType.landslide;
    }
  }

  @override
  void write(BinaryWriter writer, IncidentType obj) {
    switch (obj) {
      case IncidentType.landslide:
        writer.writeByte(0);
        break;
      case IncidentType.flood:
        writer.writeByte(1);
        break;
      case IncidentType.roadBlock:
        writer.writeByte(2);
        break;
      case IncidentType.powerLineDown:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncidentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
