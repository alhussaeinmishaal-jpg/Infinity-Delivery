import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // جلب بيانات المستخدم الحالي كـ Stream (يتحدث تلقائياً عند تغيير الرصيد مثلاً)
  Stream<DocumentSnapshot> getUserData() {
    String uid = _auth.currentUser?.uid ?? "";
    return _db.collection('users').doc(uid).snapshots();
  }

  // جلب العروض الخاصة من Firestore
  Stream<QuerySnapshot> getOffers() {
    return _db.collection('offers').snapshots();
  }
}
