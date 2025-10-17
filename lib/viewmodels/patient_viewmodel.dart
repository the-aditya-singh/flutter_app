import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hospital_management/models/patient.dart'; // Import the model

class PatientViewModel extends ChangeNotifier {
  final CollectionReference patientsCol =
      FirebaseFirestore.instance.collection('patients');

  Stream<List<Patient>> watchPatients() {
    return patientsCol
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) => Patient.fromDoc(d)).toList();
    });
  }

  Future<void> addPatient({
    required String name,
    required int age,
    required String phone,
    required String notes,
  }) async {
    final data = {
      'name': name,
      'age': age,
      'phone': phone,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await patientsCol.add(data);
  }

  Future<void> updatePatient({
    required String id,
    required String name,
    required int age,
    required String phone,
    required String notes,
  }) async {
    final data = {
      'name': name,
      'age': age,
      'phone': phone,
      'notes': notes,
    };
    await patientsCol.doc(id).update(data);
  }

  Future<void> deletePatient(String id) async {
    await patientsCol.doc(id).delete();
  }
}