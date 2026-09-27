import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Application commands. The server derives identity, prices, roles and rewards.
class Workflows {
  Workflows({FirebaseFunctions? functions, FirebaseStorage? storage})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'asia-southeast1'),
      _storage = storage ?? FirebaseStorage.instance;
  static final instance = Workflows();
  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;

  String newId() => FirebaseFirestore.instance.collection('reports').doc().id;
  Future<Map<String, dynamic>> call(
    String name,
    Map<String, dynamic> data,
  ) async {
    final result = await _functions.httpsCallable(name).call<Object?>(data);
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<void> upload(String path, Uint8List bytes, String contentType) async {
    // Uploads are immutable. A retry after a lost response reuses the existing file.
    final reference = _storage.ref(path);
    try {
      await reference.getMetadata();
      return;
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') rethrow;
    }
    await reference.putData(bytes, SettableMetadata(contentType: contentType));
  }

  Future<Map<String, dynamic>> checkout({
    required String requestId,
    required String kind,
    double? amount,
    String? projectId,
    List<Map<String, dynamic>>? items,
  }) => call('createCheckout', {
    'requestId': requestId,
    'kind': kind,
    'amount': amount,
    'projectId': projectId,
    'items': items,
  });

  Future<void> requestVolunteer() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final target = FirebaseFirestore.instance.collection('volunteers').doc(uid);
    if ((await target.get()).exists) return;
    await target.set({
      'userId': uid,
      'approvalStatus': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

class ReportDraftStore {
  ReportDraftStore(this.uid);
  final String uid;
  String get _key => 'report_draft_$uid';
  Future<Map<String, dynamic>?> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Map<String, dynamic> data) async =>
      (await SharedPreferences.getInstance()).setString(_key, jsonEncode(data));
  Future<void> clear() async =>
      (await SharedPreferences.getInstance()).remove(_key);
}

double verifiedTotal(Iterable<Map<String, dynamic>> records, String field) =>
    records
        .where(
          (r) =>
              ['verified', 'paid'].contains(r['status']) &&
              r['source'] != 'shop_checkout',
        )
        .fold(
          0,
          (total, r) =>
              total +
              ((r[field] as num?)?.toDouble() ?? 0) -
              ((r['refundedCents'] as num?)?.toDouble() ?? 0) / 100,
        );
