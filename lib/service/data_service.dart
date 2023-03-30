
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/disaster_card_model.dart';
import 'package:untitled/repo/disaster_card_repo.dart';
import '../cards/disaster_card_widget.dart';


class DataService {

  Future<void> addDisasterCard(DisasterCardModel model) async {
    await FirebaseFirestore.instance.collection('DisasterCards').add(model.toMap());

  }

  
  Future<List<DisasterCardModel>> getDisasterCard() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('DisasterCards').get();
     return querySnapshot.docs.map((e) => DisasterCardModel.fromMap(e.data())).toList();
  }


}


  final dataServiceProvider = Provider((ref) {
    return DataService();
  });
