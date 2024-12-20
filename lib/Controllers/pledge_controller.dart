import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/PledgeModel.dart';

class PledgeController{
  /// Save Pledge to Firestore
   Future<void> saveToFirestore(PledgeModel pledge) async {
    await PledgeModel.saveToFirestore(pledge);
  }

  Future<void> updateInFirestore(PledgeModel pledge) async {
    await PledgeModel.updateInFirestore(pledge);
  }

  Future<List<PledgeModel>> getFromFirestoreByUserId(String pledgedTo) async {
    return await PledgeModel.getFromFirestoreByUserId(pledgedTo);
  }

}