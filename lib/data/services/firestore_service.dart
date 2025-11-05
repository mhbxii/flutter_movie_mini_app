import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create document
  Future<void> createDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(docId).set(data);
  }

  // Get single document
  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    final doc = await _db.collection(collection).doc(docId).get();
    return doc.exists ? doc.data() : null;
  }

  // Update document
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(docId).update(data);
  }

  // Delete document
  Future<void> deleteDocument(String collection, String docId) async {
    await _db.collection(collection).doc(docId).delete();
  }

  // Query documents with WHERE clause
  Future<List<Map<String, dynamic>>> queryDocuments(
    String collection, {
    String? whereField,
    dynamic whereValue,
  }) async {
    Query query = _db.collection(collection);
    
    if (whereField != null) {
      query = query.where(whereField, isEqualTo: whereValue);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Get all documents in collection
  Future<List<Map<String, dynamic>>> getAllDocuments(String collection) async {
    final snapshot = await _db.collection(collection).get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Stream single document
  Stream<Map<String, dynamic>?> streamDocument(String collection, String docId) {
    return _db.collection(collection).doc(docId).snapshots().map((doc) {
      return doc.exists ? doc.data() : null;
    });
  }

  // Stream collection
  Stream<List<Map<String, dynamic>>> streamCollection(String collection) {
    return _db.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}