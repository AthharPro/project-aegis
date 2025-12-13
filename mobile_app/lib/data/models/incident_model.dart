import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'incident_model.g.dart';

@HiveType(typeId: 0)
enum IncidentType {
  @HiveField(0)
  landslide,
  @HiveField(1)
  flood,
  @HiveField(2)
  roadBlock,
  @HiveField(3)
  powerLineDown,
}

@HiveType(typeId: 1)
class IncidentModel extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final IncidentType type;

  @HiveField(2)
  final int severity; // 1-5

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final String? imagePath;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  bool synced;

  @HiveField(8)
  final String userId;

  @HiveField(9)
  final int? victimCount;

  @HiveField(10)
  final String status; // pending, resolved, completed

  IncidentModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.latitude,
    required this.longitude,
    this.imagePath,
    required this.createdAt,
    this.synced = false,
    required this.userId,
    this.victimCount,
    this.status = 'pending',
  });

  @override
  List<Object?> get props => [id, type, severity, latitude, longitude, imagePath, createdAt, synced, userId, victimCount, status];

  Map<String, dynamic> toSupabaseMap() {
    String typeStr;
    switch (type) {
      case IncidentType.landslide: typeStr = 'Landslide'; break;
      case IncidentType.flood: typeStr = 'Flood'; break;
      case IncidentType.roadBlock: typeStr = 'Road Block'; break;
      case IncidentType.powerLineDown: typeStr = 'Power Line Down'; break;
    }

    return {
      'id': id,
      'user_id': userId,
      'incident_type': typeStr,
      'severity': severity, // User specified "Severity" capitalized in request, keeping consistent if case-sensitive, otherwise DB usually ignores case. user said "Severity - 1 to 5"
      'incident_time': createdAt.toIso8601String(),
      'victim_count': victimCount,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imagePath, // Mapping local path to image_url for now as requested "null or string"
      'status': status, // User specified "Status" capitalized
    };
  }
}
