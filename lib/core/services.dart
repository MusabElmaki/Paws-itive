import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'domain.dart';
import 'workflows.dart';

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
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  static final instance = AuthService();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signIn({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await NotificationBridge.instance.dispose();
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection(Collections.users).doc(user.uid).update({
          'pushToken': FieldValue.delete(),
        });
      } catch (_) {}
    }
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Unable to create account.');
    }

    final profile = AppUserProfile(
      uid: user.uid,
      email: email,
      fullName: fullName,
      role: UserRole.user,
      status: UserStatus.active,
      createdAt: DateTime.now(),
      isApprovedVolunteer: false,
    );

    final batch = _firestore.batch();
    batch.set(
      _firestore.collection(Collections.users).doc(user.uid),
      profile.toMap(),
    );
    if (role == UserRole.volunteer) {
      batch.set(_firestore.collection(Collections.volunteers).doc(user.uid), {
        'userId': user.uid,
        'approvalStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    await user.sendEmailVerification();
  }

  Future<AppUserProfile?> loadProfile(String uid) async {
    final doc = await _firestore.collection(Collections.users).doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return AppUserProfile.fromMap(doc.id, doc.data()!);
  }

  Stream<AppUserProfile?> watchUser(String uid) {
    return _firestore.collection(Collections.users).doc(uid).snapshots().map((
      doc,
    ) {
      final data = doc.data();
      if (data == null) return null;
      return AppUserProfile.fromMap(doc.id, data);
    });
  }
}

class FirestoreGateway {
  FirestoreGateway({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static final instance = FirestoreGateway();

  final FirebaseFirestore _firestore;

  Stream<List<CatReport>> watchReports({
    bool onlyActive = false,
    String? reporterId,
    int limit = 100,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(
      Collections.reports,
    );
    if (reporterId != null) {
      query = query.where('reporterId', isEqualTo: reporterId);
    }
    if (onlyActive) {
      query = query.where(
        'status',
        whereIn: ['reported', 'underReview', 'beingAssisted'],
      );
    }
    return query
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (s) => s.docs
              .where((d) => d.data()['archived'] != true)
              .map((d) => CatReport.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Stream<AppUserProfile?> watchUser(String uid) {
    return _firestore.collection(Collections.users).doc(uid).snapshots().map((
      doc,
    ) {
      final data = doc.data();
      if (data == null) return null;
      return AppUserProfile.fromMap(doc.id, data);
    });
  }

  Stream<List<CatProfile>> watchCats() {
    return _firestore
        .collection(Collections.cats)
        .orderBy('lastUpdated', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where(
                (d) =>
                    d.data()['archived'] != true &&
                    d.data()['linkedTo'] == null,
              )
              .map((doc) => CatProfile.fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  Stream<List<NotificationRecord>> watchNotifications(
    String userId, {
    UserRole role = UserRole.user,
  }) {
    final audiences = [
      'all',
      if (role != UserRole.user) 'volunteers',
      if (role == UserRole.admin) 'admins',
    ];
    return _firestore
        .collection(Collections.notifications)
        .where(
          Filter.or(
            Filter('targetUserId', isEqualTo: userId),
            Filter('audience', whereIn: audiences),
          ),
        )
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => NotificationRecord.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Stream<List<ShopItem>> watchShopItems() {
    return _firestore
        .collection(Collections.shopItems)
        .where('active', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ShopItem.fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  Stream<List<Clinic>> watchClinics() {
    return _firestore
        .collection(Collections.clinics)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Clinic.fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  Stream<List<LeaderboardEntry>> watchLeaderboard() {
    return _firestore
        .collection(Collections.leaderboard)
        .orderBy('points', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => LeaderboardEntry(
                  userId: doc.id,
                  name: (doc.data()['name'] ?? '').toString(),
                  points: (doc.data()['points'] as num?)?.toInt() ?? 0,
                  weeklyPoints:
                      (doc.data()['weeklyPoints'] as num?)?.toInt() ?? 0,
                  monthlyPoints:
                      (doc.data()['monthlyPoints'] as num?)?.toInt() ?? 0,
                  casesClosed:
                      (doc.data()['casesClosed'] as num?)?.toInt() ?? 0,
                  healthUpdates:
                      (doc.data()['healthUpdates'] as num?)?.toInt() ?? 0,
                  feedingUpdates:
                      (doc.data()['feedingUpdates'] as num?)?.toInt() ?? 0,
                ),
              )
              .toList(growable: false),
        );
  }

  Stream<List<Map<String, dynamic>>> watchDonations(String userId) {
    return _firestore
        .collection(Collections.donations)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
          items.sort((a, b) {
            final aTs = a['createdAt'];
            final bTs = b['createdAt'];
            if (aTs is Timestamp && bTs is Timestamp) return bTs.compareTo(aTs);
            return 0;
          });
          return items;
        });
  }

  Future<void> setReportStatus(String reportId, ReportStatus status) async {
    await Workflows.instance.call('changeCase', {
      'reportId': reportId,
      'status': status.name,
    });
  }

  Future<void> assignReport(
    String reportId, {
    required String volunteerId,
    ReportStatus? status,
  }) async {
    await Workflows.instance.call('changeCase', {
      'reportId': reportId,
      'volunteerId': volunteerId,
    });
  }

  Future<void> deleteReport(String reportId) async {
    await Workflows.instance.call('archiveRecord', {
      'collection': 'reports',
      'id': reportId,
    });
  }

  // --- Cats -----------------------------------------------------------------

  Stream<CatProfile?> watchCat(String catId) {
    return _firestore.collection(Collections.cats).doc(catId).snapshots().map((
      doc,
    ) {
      final data = doc.data();
      if (data == null) return null;
      return CatProfile.fromMap(doc.id, data);
    });
  }

  Future<void> deleteCat(String catId) {
    return Workflows.instance
        .call('archiveRecord', {'collection': 'cats', 'id': catId})
        .then((_) {});
  }

  // --- Shop items: admin CRUD ----------------------------------------------

  Stream<List<ShopItem>> watchAllShopItems() {
    return _firestore
        .collection(Collections.shopItems)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ShopItem.fromMap(doc.id, doc.data()))
              .toList(growable: false),
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
    return _firestore
        .collection(Collections.users)
        .limit(500)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppUserProfile.fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await Workflows.instance.call('manageUser', {
      'uid': uid,
      'role': data['role'],
      'suspended': data['isSuspended'] == true,
    });
  }

  // --- Treasury: donations + shop orders ------------------------------------

  Stream<List<Map<String, dynamic>>> watchAllDonations() {
    return _firestore
        .collection(Collections.donations)
        .snapshots()
        .map(_sortedByCreatedAt);
  }

  Stream<List<Map<String, dynamic>>> watchOrders() {
    return _firestore
        .collection(Collections.orders)
        .snapshots()
        .map(_sortedByCreatedAt);
  }

  List<Map<String, dynamic>> _sortedByCreatedAt(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final items = snapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();
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
    return Workflows.instance
        .call('createFundRequest', {
          'requestId': Workflows.instance.newId(),
          'reportId': reportId,
          'amount': amount,
          'reason': reason,
        })
        .then((_) {});
  }

  Stream<List<Map<String, dynamic>>> watchFundRequests({String? requestedBy}) {
    Query<Map<String, dynamic>> query = _firestore.collection(
      Collections.fundRequests,
    );
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
  }) async {
    await Workflows.instance.call('reviewFundRequest', {
      'id': requestId,
      'status': approve ? 'approved' : 'rejected',
      'note': note ?? '',
    });
  }

  // --- Fundraising projects -------------------------------------------------

  Stream<List<FundraisingProject>> watchFundraising({
    bool onlyActive = false,
    String? createdBy,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(
      Collections.fundraising,
    );
    if (onlyActive) query = query.where('active', isEqualTo: true);
    if (createdBy != null) {
      query = query.where('createdBy', isEqualTo: createdBy);
    }
    return query.limit(100).snapshots().map((s) {
      final projects = s.docs
          .where((d) => d.data()['archived'] != true)
          .map((d) => FundraisingProject.fromMap(d.id, d.data()))
          .toList();
      projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return projects;
    });
  }

  Future<void> createFundraising(FundraisingProject project) {
    final doc = project.id.isEmpty
        ? _firestore.collection(Collections.fundraising).doc()
        : _firestore.collection(Collections.fundraising).doc(project.id);
    final data = project.toMap();
    if (project.id.isNotEmpty) {
      for (final key in [
        'raisedAmount',
        'createdBy',
        'createdByName',
        'createdAt',
      ]) {
        data.remove(key);
      }
    } else {
      data['raisedAmount'] = 0;
    }
    return doc.set(data, SetOptions(merge: true));
  }

  Future<void> deleteFundraising(String projectId) async {
    await Workflows.instance.call('archiveRecord', {
      'collection': 'fundraising',
      'id': projectId,
    });
  }

  Future<int> _safeCount(String collection) async =>
      (await _firestore.collection(collection).count().get()).count ?? 0;

  Future<Map<String, int>> computeCounts() async {
    final entries = await Future.wait([
      _safeCount(Collections.users),
      _safeCount(Collections.reports),
      _safeCount(Collections.cats),
      Future.value(0),
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

  Future<void> seedDemoData() async {
    throw StateError(
      'Demo seeding is disabled. Configure real clinics and shop items before launch.',
    );
  }
}

class NotificationBridge {
  static final instance = NotificationBridge();
  StreamSubscription<String>? _refresh;
  String? _uid;
  Future<void> initialize(String userId) async {
    if (_uid == userId) return;
    await dispose();
    _uid = userId;
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _save(userId, token);
      _refresh = FirebaseMessaging.instance.onTokenRefresh.listen((
        token,
      ) async {
        try {
          await _save(userId, token);
        } catch (_) {}
      });
    } catch (_) {
      _uid = null;
    } // In-app notifications remain available without device push.
  }

  Future<void> _save(String uid, String token) async {
    if (FirebaseAuth.instance.currentUser?.uid != uid) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'pushToken': token,
    });
  }

  Future<void> dispose() async {
    await _refresh?.cancel();
    _refresh = null;
    _uid = null;
  }
}
