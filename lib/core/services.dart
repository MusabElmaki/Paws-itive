import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'domain.dart';

class Collections {
  static const users = 'users';
  static const volunteers = 'volunteers';
  static const admins = 'admins';
  static const cats = 'cats';
  static const reports = 'reports';
  static const notifications = 'notifications';
  static const donations = 'donations';
  static const shopItems = 'shop_items';
  static const orders = 'orders';
  static const leaderboard = 'leaderboard';
  static const clinics = 'clinics';
  static const fundRequests = 'fund_requests';
  static const fundraising = 'fundraising';
}

class AuthService {
  AuthService._();

  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signIn({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user;
    if (user == null) {
      throw StateError('Unable to create account.');
    }

    final profile = AppUserProfile(
      uid: user.uid,
      email: email,
      fullName: fullName,
      role: role,
      status: role == UserRole.volunteer ? UserStatus.pending : UserStatus.active,
      createdAt: DateTime.now(),
      isApprovedVolunteer: role == UserRole.volunteer,
    );

    await _firestore.collection(Collections.users).doc(user.uid).set(profile.toMap());
    if (role == UserRole.volunteer) {
      await _firestore.collection(Collections.volunteers).doc(user.uid).set({
        'userId': user.uid,
        'approvalStatus': 'pending',
        'role': 'volunteer',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<AppUserProfile?> loadProfile(String uid) async {
    final doc = await _firestore.collection(Collections.users).doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return AppUserProfile.fromMap(doc.id, doc.data()!);
  }

  Stream<AppUserProfile?> watchUser(String uid) {
    return _firestore.collection(Collections.users).doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return AppUserProfile.fromMap(doc.id, data);
    });
  }
}

class FirestoreGateway {
  FirestoreGateway._();

  static final instance = FirestoreGateway._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CatReport>> watchReports({bool onlyActive = false, String? reporterId}) {
    // Only order on the server (single-field index, always available). Status
    // and reporter filters are applied client-side so we never depend on a
    // composite index that may not be deployed — that was silently breaking the
    // volunteer "cases" list.
    const activeStatuses = {ReportStatus.reported, ReportStatus.underReview, ReportStatus.beingAssisted};
    return _firestore
        .collection(Collections.reports)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      var reports = snapshot.docs.map((doc) => CatReport.fromMap(doc.id, doc.data()));
      if (onlyActive) {
        reports = reports.where((report) => activeStatuses.contains(report.status));
      }
      if (reporterId != null) {
        reports = reports.where((report) => report.reporterId == reporterId);
      }
      return reports.toList(growable: false);
    });
  }

  Stream<AppUserProfile?> watchUser(String uid) {
    return _firestore.collection(Collections.users).doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return AppUserProfile.fromMap(doc.id, data);
    });
  }

  Stream<List<CatProfile>> watchCats() {
    return _firestore.collection(Collections.cats).orderBy('lastUpdated', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => CatProfile.fromMap(doc.id, doc.data())).toList(growable: false));
  }

  Stream<List<NotificationRecord>> watchNotifications(String userId) {
    return _firestore.collection(Collections.notifications).orderBy('createdAt', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => NotificationRecord.fromMap(doc.id, doc.data())).where((item) => item.targetUserId == null || item.targetUserId == userId).toList(growable: false));
  }

  Stream<List<ShopItem>> watchShopItems() {
    return _firestore.collection(Collections.shopItems).where('active', isEqualTo: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => ShopItem.fromMap(doc.id, doc.data())).toList(growable: false));
  }

  Stream<List<Clinic>> watchClinics() {
    return _firestore.collection(Collections.clinics).orderBy('name').snapshots().map((snapshot) => snapshot.docs.map((doc) => Clinic.fromMap(doc.id, doc.data())).toList(growable: false));
  }

  Stream<List<LeaderboardEntry>> watchLeaderboard() {
    return _firestore.collection(Collections.leaderboard).orderBy('points', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => LeaderboardEntry(
      userId: doc.id,
      name: (doc.data()['name'] ?? '').toString(),
      points: (doc.data()['points'] as num?)?.toInt() ?? 0,
      weeklyPoints: (doc.data()['weeklyPoints'] as num?)?.toInt() ?? 0,
      monthlyPoints: (doc.data()['monthlyPoints'] as num?)?.toInt() ?? 0,
      casesClosed: (doc.data()['casesClosed'] as num?)?.toInt() ?? 0,
      healthUpdates: (doc.data()['healthUpdates'] as num?)?.toInt() ?? 0,
      feedingUpdates: (doc.data()['feedingUpdates'] as num?)?.toInt() ?? 0,
    )).toList(growable: false));
  }

  Future<CatReport> createReport(CatReport report) async {
    final doc = _firestore.collection(Collections.reports).doc();
    await doc.set(report.toMap());
    return CatReport.fromMap(doc.id, (await doc.get()).data() ?? report.toMap());
  }

  Future<void> upsertCat(CatProfile cat) {
    return _firestore.collection(Collections.cats).doc(cat.id).set(cat.toMap(), SetOptions(merge: true));
  }

  Future<void> addNotification({required String title, required String body, String? targetUserId, String? type, String? actionPath}) {
    return _firestore.collection(Collections.notifications).add({
      'title': title,
      'body': body,
      'targetUserId': targetUserId,
      'type': type,
      'actionPath': actionPath,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addDonation(Map<String, dynamic> data) => _firestore.collection(Collections.donations).add(data);

  /// Records a donation made through the QR / DuitNow flow.
  Future<void> recordDonation({
    required String userId,
    required String userName,
    required double amount,
    String source = 'qr_duitnow',
  }) {
    return _firestore.collection(Collections.donations).add({
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'source': source,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchDonations(String userId) {
    return _firestore
        .collection(Collections.donations)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      items.sort((a, b) {
        final aTs = a['createdAt'];
        final bTs = b['createdAt'];
        if (aTs is Timestamp && bTs is Timestamp) return bTs.compareTo(aTs);
        return 0;
      });
      return items;
    });
  }

  Future<void> addOrder(Map<String, dynamic> data) => _firestore.collection(Collections.orders).add(data);

  Future<void> addFundRequest(Map<String, dynamic> data) => _firestore.collection(Collections.fundRequests).add(data);

  // --- Reports: admin/volunteer management ---------------------------------

  Future<void> updateReport(String reportId, Map<String, dynamic> data) {
    return _firestore.collection(Collections.reports).doc(reportId).set(
      {...data, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  Future<void> setReportStatus(String reportId, ReportStatus status) {
    return updateReport(reportId, {'status': status.name});
  }

  Future<void> assignReport(String reportId, {required String volunteerId, ReportStatus? status}) {
    return updateReport(reportId, {
      'assignedVolunteerId': volunteerId,
      if (status != null) 'status': status.name,
    });
  }

  Future<void> deleteReport(String reportId) {
    return _firestore.collection(Collections.reports).doc(reportId).delete();
  }

  // --- Cats -----------------------------------------------------------------

  Stream<CatProfile?> watchCat(String catId) {
    return _firestore.collection(Collections.cats).doc(catId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return CatProfile.fromMap(doc.id, data);
    });
  }

  Future<void> deleteCat(String catId) {
    return _firestore.collection(Collections.cats).doc(catId).delete();
  }

  // --- Shop items: admin CRUD ----------------------------------------------

  Stream<List<ShopItem>> watchAllShopItems() {
    return _firestore.collection(Collections.shopItems).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => ShopItem.fromMap(doc.id, doc.data())).toList(growable: false),
        );
  }

  Future<void> upsertShopItem(ShopItem item) {
    final doc = item.id.isEmpty
        ? _firestore.collection(Collections.shopItems).doc()
        : _firestore.collection(Collections.shopItems).doc(item.id);
    return doc.set({
      'name': item.name,
      'price': item.price,
      'category': item.category,
      'description': item.description,
      'imageUrl': item.imageUrl,
      'active': item.active,
    }, SetOptions(merge: true));
  }

  Future<void> deleteShopItem(String itemId) {
    return _firestore.collection(Collections.shopItems).doc(itemId).delete();
  }

  // --- Users: admin CRUD ----------------------------------------------------

  Stream<List<AppUserProfile>> watchAllUsers() {
    return _firestore.collection(Collections.users).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => AppUserProfile.fromMap(doc.id, doc.data())).toList(growable: false),
        );
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return _firestore.collection(Collections.users).doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> setUserSuspended(String uid, bool suspended) {
    return updateUser(uid, {'isSuspended': suspended, 'status': suspended ? 'suspended' : 'active'});
  }

  Future<void> setUserRole(String uid, UserRole role) {
    return updateUser(uid, {
      'role': role.name,
      'isApprovedVolunteer': role == UserRole.volunteer || role == UserRole.admin,
    });
  }

  Future<void> deleteUserDoc(String uid) {
    return _firestore.collection(Collections.users).doc(uid).delete();
  }

  // --- Treasury: donations + shop orders ------------------------------------

  Stream<List<Map<String, dynamic>>> watchAllDonations() {
    return _firestore.collection(Collections.donations).snapshots().map(_sortedByCreatedAt);
  }

  Stream<List<Map<String, dynamic>>> watchOrders() {
    return _firestore.collection(Collections.orders).snapshots().map(_sortedByCreatedAt);
  }

  List<Map<String, dynamic>> _sortedByCreatedAt(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final items = snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    items.sort((a, b) {
      final aTs = a['createdAt'];
      final bTs = b['createdAt'];
      if (aTs is Timestamp && bTs is Timestamp) return bTs.compareTo(aTs);
      return 0;
    });
    return items;
  }

  // --- Fund requests --------------------------------------------------------

  Future<void> createFundRequest({
    required String catId,
    required String catName,
    required String requestedBy,
    required String requestedByName,
    required double amount,
    required String reason,
    String? reportId,
  }) {
    return _firestore.collection(Collections.fundRequests).add({
      'catId': catId,
      'catName': catName,
      'reportId': reportId,
      'requestedBy': requestedBy,
      'requestedByName': requestedByName,
      'amount': amount,
      'reason': reason,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchFundRequests({String? requestedBy}) {
    Query<Map<String, dynamic>> query = _firestore.collection(Collections.fundRequests);
    if (requestedBy != null) {
      query = query.where('requestedBy', isEqualTo: requestedBy);
    }
    return query.snapshots().map(_sortedByCreatedAt);
  }

  Future<void> reviewFundRequest({
    required String requestId,
    required bool approve,
    required String reviewedBy,
    String? note,
  }) {
    return _firestore.collection(Collections.fundRequests).doc(requestId).set({
      'status': approve ? 'approved' : 'rejected',
      'reviewedBy': reviewedBy,
      'reviewNote': note,
      'reviewedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // --- Fundraising projects -------------------------------------------------

  Stream<List<FundraisingProject>> watchFundraising({bool onlyActive = false, String? createdBy}) {
    return _firestore.collection(Collections.fundraising).snapshots().map((snapshot) {
      var projects = snapshot.docs.map((doc) => FundraisingProject.fromMap(doc.id, doc.data()));
      if (onlyActive) projects = projects.where((p) => p.active);
      if (createdBy != null) projects = projects.where((p) => p.createdBy == createdBy);
      final list = projects.toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> createFundraising(FundraisingProject project) {
    final doc = project.id.isEmpty
        ? _firestore.collection(Collections.fundraising).doc()
        : _firestore.collection(Collections.fundraising).doc(project.id);
    return doc.set(project.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteFundraising(String projectId) {
    return _firestore.collection(Collections.fundraising).doc(projectId).delete();
  }

  /// Donates to a project: increments the project's raised amount and records a
  /// donation document (all in Firestore, no paid services required).
  Future<void> donateToProject({
    required String projectId,
    required String projectTitle,
    required String userId,
    required String userName,
    required double amount,
  }) async {
    await _firestore.collection(Collections.fundraising).doc(projectId).set(
      {'raisedAmount': FieldValue.increment(amount)},
      SetOptions(merge: true),
    );
    await _firestore.collection(Collections.donations).add({
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'source': 'fundraising',
      'projectId': projectId,
      'projectTitle': projectTitle,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<int> _safeCount(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).count().get();
      return snapshot.count ?? 0;
    } catch (_) {
      // A role may not be allowed to read every collection (e.g. a user cannot
      // list donations). Treat denied/failed counts as 0 instead of throwing,
      // so the dashboard still renders the numbers it can see.
      try {
        final snapshot = await _firestore.collection(collection).get();
        return snapshot.size;
      } catch (_) {
        return 0;
      }
    }
  }

  Future<Map<String, int>> computeCounts() async {
    final entries = await Future.wait([
      _safeCount(Collections.users),
      _safeCount(Collections.reports),
      _safeCount(Collections.cats),
      _safeCount(Collections.notifications),
      _safeCount(Collections.shopItems),
      _safeCount(Collections.donations),
      _safeCount(Collections.clinics),
    ]);

    return {
      'users': entries[0],
      'reports': entries[1],
      'cats': entries[2],
      'notifications': entries[3],
      'shopItems': entries[4],
      'donations': entries[5],
      'clinics': entries[6],
    };
  }

  /// Populates clinics, shop items, and the volunteer leaderboard with sample
  /// content so every role sees data immediately. Admin-only (matches rules).
  /// Safe to run repeatedly: it uses fixed document IDs and merges.
  Future<void> seedDemoData() async {
    final batch = _firestore.batch();

    const clinics = [
      {
        'id': 'clinic_utm_vet',
        'name': 'UTM Campus Animal Care',
        'address': 'Block T05, Universiti Teknologi Malaysia, Skudai',
        'latitude': 1.5587,
        'longitude': 103.6370,
        'phone': '+60 7-553 3333',
        'emergency': true,
      },
      {
        'id': 'clinic_skudai_pet',
        'name': 'Skudai Pet Clinic',
        'address': 'Jalan Pendidikan, Taman Universiti, Skudai',
        'latitude': 1.5410,
        'longitude': 103.6200,
        'phone': '+60 7-520 1234',
        'emergency': false,
      },
      {
        'id': 'clinic_jb_emergency',
        'name': 'JB 24H Emergency Vet',
        'address': 'Jalan Tun Abdul Razak, Johor Bahru',
        'latitude': 1.4927,
        'longitude': 103.7414,
        'phone': '+60 7-333 9999',
        'emergency': true,
      },
    ];
    for (final clinic in clinics) {
      final data = Map<String, dynamic>.from(clinic)..remove('id');
      batch.set(_firestore.collection(Collections.clinics).doc(clinic['id'] as String), data, SetOptions(merge: true));
    }

    const shopItems = [
      {
        'id': 'shop_food_bag',
        'name': 'Premium Cat Food (2kg)',
        'price': 35.0,
        'category': 'Food',
        'description': 'Feeds a campus cat for two weeks. Proceeds fund stray care.',
        'active': true,
      },
      {
        'id': 'shop_tshirt',
        'name': 'Paws-itive T-Shirt',
        'price': 45.0,
        'category': 'Merchandise',
        'description': 'Cotton tee. Every sale supports neutering programs.',
        'active': true,
      },
      {
        'id': 'shop_coffee',
        'name': 'Cafe Coffee + Donation',
        'price': 12.0,
        'category': 'Cafe',
        'description': 'A warm cup at the cat cafe; RM3 goes to medical funds.',
        'active': true,
      },
      {
        'id': 'shop_vaccine_voucher',
        'name': 'Sponsor a Vaccination',
        'price': 60.0,
        'category': 'Sponsorship',
        'description': 'Covers one stray cat vaccination handled by our volunteers.',
        'active': true,
      },
    ];
    for (final item in shopItems) {
      final data = Map<String, dynamic>.from(item)..remove('id');
      batch.set(_firestore.collection(Collections.shopItems).doc(item['id'] as String), data, SetOptions(merge: true));
    }

    const leaderboard = [
      {'id': 'demo_v1', 'name': 'Aisyah (Volunteer)', 'points': 480, 'weeklyPoints': 60, 'monthlyPoints': 210, 'casesClosed': 18, 'healthUpdates': 24, 'feedingUpdates': 40},
      {'id': 'demo_v2', 'name': 'Daniel (Volunteer)', 'points': 365, 'weeklyPoints': 45, 'monthlyPoints': 150, 'casesClosed': 12, 'healthUpdates': 19, 'feedingUpdates': 33},
      {'id': 'demo_v3', 'name': 'Mei Ling (Volunteer)', 'points': 290, 'weeklyPoints': 30, 'monthlyPoints': 120, 'casesClosed': 9, 'healthUpdates': 14, 'feedingUpdates': 27},
    ];
    for (final entry in leaderboard) {
      final data = Map<String, dynamic>.from(entry)..remove('id');
      batch.set(_firestore.collection(Collections.leaderboard).doc(entry['id'] as String), data, SetOptions(merge: true));
    }

    // Sample cat profiles with public photos so cards, maps and detail pages
    // show real pictures/data even before any report is filed.
    final cats = [
      {
        'id': 'demo_cat_oyen',
        'name': 'Oyen',
        'photoUrls': ['https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Cat03.jpg/320px-Cat03.jpg'],
        'currentLocationName': 'Faculty of Computing (N28)',
        'latitude': 1.5598,
        'longitude': 103.6360,
        'healthStatus': 'healthy',
        'classification': 'stray',
        'currentStatus': 'resolved',
        'lastUpdated': Timestamp.now(),
      },
      {
        'id': 'demo_cat_tompok',
        'name': 'Tompok',
        'photoUrls': ['https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Cat_August_2010-4.jpg/320px-Cat_August_2010-4.jpg'],
        'currentLocationName': 'Arked Angkasa Cafeteria',
        'latitude': 1.5611,
        'longitude': 103.6377,
        'healthStatus': 'injured',
        'classification': 'stray',
        'currentStatus': 'beingAssisted',
        'lastUpdated': Timestamp.now(),
      },
      {
        'id': 'demo_cat_snowy',
        'name': 'Snowy',
        'photoUrls': ['https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Cat_November_2010-1a.jpg/320px-Cat_November_2010-1a.jpg'],
        'currentLocationName': 'Kolej Tun Dr Ismail (KTDI)',
        'latitude': 1.5575,
        'longitude': 103.6402,
        'healthStatus': 'recovering',
        'classification': 'domestic',
        'currentStatus': 'underReview',
        'lastUpdated': Timestamp.now(),
      },
    ];
    for (final cat in cats) {
      final data = Map<String, dynamic>.from(cat)..remove('id');
      batch.set(_firestore.collection(Collections.cats).doc(cat['id'] as String), data, SetOptions(merge: true));
    }

    final projects = [
      {
        'id': 'demo_fund_tompok',
        'title': 'Surgery for Tompok',
        'description': 'Tompok was injured near the cafeteria and needs surgery and medication.',
        'goalAmount': 800.0,
        'raisedAmount': 320.0,
        'createdBy': 'demo',
        'createdByName': 'Aisyah (Volunteer)',
        'catId': 'demo_cat_tompok',
        'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Cat_August_2010-4.jpg/320px-Cat_August_2010-4.jpg',
        'active': true,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'demo_fund_neuter',
        'title': 'Campus Neutering Drive',
        'description': 'Help us neuter 10 campus strays this semester to keep the colony healthy.',
        'goalAmount': 1500.0,
        'raisedAmount': 600.0,
        'createdBy': 'demo',
        'createdByName': 'Daniel (Volunteer)',
        'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Cat03.jpg/320px-Cat03.jpg',
        'active': true,
        'createdAt': Timestamp.now(),
      },
    ];
    for (final project in projects) {
      final data = Map<String, dynamic>.from(project)..remove('id');
      batch.set(_firestore.collection(Collections.fundraising).doc(project['id'] as String), data, SetOptions(merge: true));
    }

    await batch.commit();
  }
}

class NotificationBridge {
  Future<void> initialize(String userId) async {
    await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await FirebaseFirestore.instance.collection(Collections.users).doc(userId).set({
        'pushToken': token,
      }, SetOptions(merge: true));
    }
  }
}