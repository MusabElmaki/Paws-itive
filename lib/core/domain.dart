import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { user, volunteer, admin }
enum UserStatus { active, pending, suspended }
enum CatClassification { stray, domestic }
enum CatHealthStatus { unknown, healthy, injured, sick, recovering, critical }
enum ReportStatus { reported, underReview, beingAssisted, resolved }

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.user => 'User',
        UserRole.volunteer => 'Volunteer',
        UserRole.admin => 'Admin',
      };
}

extension UserStatusX on UserStatus {
  String get value => name;
}

extension ReportStatusX on ReportStatus {
  String get label => switch (this) {
        ReportStatus.reported => 'Reported',
        ReportStatus.underReview => 'Under Review',
        ReportStatus.beingAssisted => 'Being Assisted',
        ReportStatus.resolved => 'Resolved',
      };
}

extension CatHealthStatusX on CatHealthStatus {
  String get label => switch (this) {
        CatHealthStatus.unknown => 'Unknown',
        CatHealthStatus.healthy => 'Healthy',
        CatHealthStatus.injured => 'Injured',
        CatHealthStatus.sick => 'Sick',
        CatHealthStatus.recovering => 'Recovering',
        CatHealthStatus.critical => 'Critical',
      };
}

class AppUserProfile {
  const AppUserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    required this.status,
    required this.createdAt,
    this.phoneNumber,
    this.photoUrl,
    this.bio = '',
    this.points = 0,
    this.isApprovedVolunteer = false,
    this.isSuspended = false,
  });

  final String uid;
  final String email;
  final String fullName;
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;
  final String? phoneNumber;
  final String? photoUrl;
  final String bio;
  final int points;
  final bool isApprovedVolunteer;
  final bool isSuspended;

  Map<String, dynamic> toMap() => {
        'email': email,
        'fullName': fullName,
        'role': role.name,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
        'phoneNumber': phoneNumber,
        'photoUrl': photoUrl,
        'bio': bio,
        'points': points,
        'isApprovedVolunteer': isApprovedVolunteer,
        'isSuspended': isSuspended,
      };

  static AppUserProfile fromMap(String uid, Map<String, dynamic> data) {
    return AppUserProfile(
      uid: uid,
      email: (data['email'] ?? '').toString(),
      fullName: (data['fullName'] ?? data['name'] ?? 'UTM Member').toString(),
      role: _roleFrom(data['role']?.toString()),
      status: _statusFrom(data['status']?.toString()),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      phoneNumber: data['phoneNumber']?.toString(),
      photoUrl: data['photoUrl']?.toString(),
      bio: data['bio']?.toString() ?? '',
      points: (data['points'] as num?)?.toInt() ?? 0,
      isApprovedVolunteer: data['isApprovedVolunteer'] as bool? ?? false,
      isSuspended: data['isSuspended'] as bool? ?? false,
    );
  }
}

class CatReport {
  const CatReport({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.locationName,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.catId,
    this.photoUrl = '',
    this.latitude,
    this.longitude,
    this.imageSignature = const [],
    this.duplicateMessage = '',
    this.duplicateConfidence = 0,
    this.assignedVolunteerId,
    this.analysisLabel = 'Cat',
    this.analysisConfidence = 0,
  });

  final String id;
  final String reporterId;
  final String reporterName;
  final String? catId;
  final String photoUrl;
  final String locationName;
  final double? latitude;
  final double? longitude;
  final String description;
  final ReportStatus status;
  final List<double> imageSignature;
  final String duplicateMessage;
  final double duplicateConfidence;
  final String? assignedVolunteerId;
  final String analysisLabel;
  final double analysisConfidence;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => {
        'reporterId': reporterId,
        'reporterName': reporterName,
        'catId': catId,
        'photoUrl': photoUrl,
        'locationName': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'status': status.name,
        'imageSignature': imageSignature,
        'duplicateMessage': duplicateMessage,
        'duplicateConfidence': duplicateConfidence,
        'assignedVolunteerId': assignedVolunteerId,
        'analysisLabel': analysisLabel,
        'analysisConfidence': analysisConfidence,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  static CatReport fromMap(String id, Map<String, dynamic> data) {
    return CatReport(
      id: id,
      reporterId: (data['reporterId'] ?? '').toString(),
      reporterName: (data['reporterName'] ?? '').toString(),
      catId: data['catId']?.toString(),
      photoUrl: (data['photoUrl'] ?? '').toString(),
      locationName: (data['locationName'] ?? '').toString(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      description: (data['description'] ?? '').toString(),
      status: _reportStatusFrom(data['status']?.toString()),
      imageSignature: (data['imageSignature'] as List?)?.map((value) => (value as num).toDouble()).toList(growable: false) ?? const [],
      duplicateMessage: (data['duplicateMessage'] ?? '').toString(),
      duplicateConfidence: (data['duplicateConfidence'] as num?)?.toDouble() ?? 0,
      assignedVolunteerId: data['assignedVolunteerId']?.toString(),
      analysisLabel: (data['analysisLabel'] ?? 'Cat').toString(),
      analysisConfidence: (data['analysisConfidence'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class CatProfile {
  const CatProfile({
    required this.id,
    required this.currentStatus,
    required this.healthStatus,
    required this.classification,
    required this.lastUpdated,
    required this.currentLocationName,
    this.name,
    this.photoUrls = const [],
    this.latitude,
    this.longitude,
    this.feedingHistory = const [],
    this.volunteerNotes = const [],
    this.medicalNotes = const [],
    this.reportIds = const [],
    this.imageSignature = const [],
    this.matchedReportId,
  });

  final String id;
  final String? name;
  final List<String> photoUrls;
  final String currentLocationName;
  final double? latitude;
  final double? longitude;
  final CatHealthStatus healthStatus;
  final CatClassification classification;
  final List<String> feedingHistory;
  final List<String> volunteerNotes;
  final List<String> medicalNotes;
  final List<String> reportIds;
  final List<double> imageSignature;
  final ReportStatus currentStatus;
  final DateTime lastUpdated;
  final String? matchedReportId;

  Map<String, dynamic> toMap() => {
        'name': name,
        'photoUrls': photoUrls,
        'currentLocationName': currentLocationName,
        'latitude': latitude,
        'longitude': longitude,
        'healthStatus': healthStatus.name,
        'classification': classification.name,
        'feedingHistory': feedingHistory,
        'volunteerNotes': volunteerNotes,
        'medicalNotes': medicalNotes,
        'reportIds': reportIds,
        'imageSignature': imageSignature,
        'currentStatus': currentStatus.name,
        'lastUpdated': Timestamp.fromDate(lastUpdated),
        'matchedReportId': matchedReportId,
      };

  static CatProfile fromMap(String id, Map<String, dynamic> data) {
    return CatProfile(
      id: id,
      name: data['name']?.toString(),
      photoUrls: (data['photoUrls'] as List?)?.map((value) => value.toString()).toList(growable: false) ?? const [],
      currentLocationName: (data['currentLocationName'] ?? '').toString(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      healthStatus: _healthFrom(data['healthStatus']?.toString()),
      classification: _classificationFrom(data['classification']?.toString()),
      feedingHistory: (data['feedingHistory'] as List?)?.map((value) => value.toString()).toList(growable: false) ?? const [],
      volunteerNotes: (data['volunteerNotes'] as List?)?.map((value) => value.toString()).toList(growable: false) ?? const [],
      medicalNotes: (data['medicalNotes'] as List?)?.map((value) => value.toString()).toList(growable: false) ?? const [],
      reportIds: (data['reportIds'] as List?)?.map((value) => value.toString()).toList(growable: false) ?? const [],
      imageSignature: (data['imageSignature'] as List?)?.map((value) => (value as num).toDouble()).toList(growable: false) ?? const [],
      currentStatus: _reportStatusFrom(data['currentStatus']?.toString()),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      matchedReportId: data['matchedReportId']?.toString(),
    );
  }
}

class NotificationRecord {
  const NotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.targetUserId,
    this.type,
    this.read = false,
    this.actionPath,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? targetUserId;
  final String? type;
  final bool read;
  final String? actionPath;

  static NotificationRecord fromMap(String id, Map<String, dynamic> data) {
    return NotificationRecord(
      id: id,
      title: (data['title'] ?? '').toString(),
      body: (data['body'] ?? '').toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      targetUserId: data['targetUserId']?.toString(),
      type: data['type']?.toString(),
      read: data['read'] as bool? ?? false,
      actionPath: data['actionPath']?.toString(),
    );
  }
}

class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    this.imageUrl,
    this.active = true,
  });

  final String id;
  final String name;
  final double price;
  final String category;
  final String description;
  final String? imageUrl;
  final bool active;

  static ShopItem fromMap(String id, Map<String, dynamic> data) {
    return ShopItem(
      id: id,
      name: (data['name'] ?? '').toString(),
      price: (data['price'] as num?)?.toDouble() ?? 0,
      category: (data['category'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      imageUrl: data['imageUrl']?.toString(),
      active: data['active'] as bool? ?? true,
    );
  }
}

class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.emergency = false,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phone;
  final bool emergency;

  static Clinic fromMap(String id, Map<String, dynamic> data) {
    return Clinic(
      id: id,
      name: (data['name'] ?? '').toString(),
      address: (data['address'] ?? '').toString(),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      phone: data['phone']?.toString(),
      emergency: data['emergency'] as bool? ?? false,
    );
  }
}

class FundRequest {
  const FundRequest({
    required this.id,
    required this.catId,
    required this.requestedBy,
    required this.amount,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.reviewedBy,
    this.reviewNote,
  });

  final String id;
  final String catId;
  final String requestedBy;
  final double amount;
  final String reason;
  final String status;
  final DateTime createdAt;
  final String? reviewedBy;
  final String? reviewNote;
}

class FundraisingProject {
  const FundraisingProject({
    required this.id,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.raisedAmount,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    this.imageUrl,
    this.catId,
    this.active = true,
  });

  final String id;
  final String title;
  final String description;
  final double goalAmount;
  final double raisedAmount;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final String? imageUrl;
  final String? catId;
  final bool active;

  double get progress => goalAmount <= 0 ? 0 : (raisedAmount / goalAmount).clamp(0.0, 1.0);

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'goalAmount': goalAmount,
        'raisedAmount': raisedAmount,
        'createdBy': createdBy,
        'createdByName': createdByName,
        'imageUrl': imageUrl,
        'catId': catId,
        'active': active,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static FundraisingProject fromMap(String id, Map<String, dynamic> data) {
    return FundraisingProject(
      id: id,
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      goalAmount: (data['goalAmount'] as num?)?.toDouble() ?? 0,
      raisedAmount: (data['raisedAmount'] as num?)?.toDouble() ?? 0,
      createdBy: (data['createdBy'] ?? '').toString(),
      createdByName: (data['createdByName'] ?? '').toString(),
      imageUrl: data['imageUrl']?.toString(),
      catId: data['catId']?.toString(),
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.points,
    required this.weeklyPoints,
    required this.monthlyPoints,
    required this.casesClosed,
    required this.healthUpdates,
    required this.feedingUpdates,
  });

  final String userId;
  final String name;
  final int points;
  final int weeklyPoints;
  final int monthlyPoints;
  final int casesClosed;
  final int healthUpdates;
  final int feedingUpdates;
}

UserRole _roleFrom(String? value) {
  switch ((value ?? 'user').toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'volunteer':
      return UserRole.volunteer;
    default:
      return UserRole.user;
  }
}

UserStatus _statusFrom(String? value) {
  switch ((value ?? 'active').toLowerCase()) {
    case 'pending':
      return UserStatus.pending;
    case 'suspended':
      return UserStatus.suspended;
    default:
      return UserStatus.active;
  }
}

ReportStatus _reportStatusFrom(String? value) {
  switch ((value ?? 'reported').toLowerCase()) {
    case 'underreview':
    case 'under_review':
      return ReportStatus.underReview;
    case 'beingassisted':
    case 'being_assisted':
      return ReportStatus.beingAssisted;
    case 'resolved':
      return ReportStatus.resolved;
    default:
      return ReportStatus.reported;
  }
}

CatHealthStatus _healthFrom(String? value) {
  switch ((value ?? 'unknown').toLowerCase()) {
    case 'healthy':
      return CatHealthStatus.healthy;
    case 'injured':
      return CatHealthStatus.injured;
    case 'sick':
      return CatHealthStatus.sick;
    case 'recovering':
      return CatHealthStatus.recovering;
    case 'critical':
      return CatHealthStatus.critical;
    default:
      return CatHealthStatus.unknown;
  }
}

CatClassification _classificationFrom(String? value) {
  switch ((value ?? 'stray').toLowerCase()) {
    case 'domestic':
      return CatClassification.domestic;
    default:
      return CatClassification.stray;
  }
}