
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cards/disaster_widget_card.dart';
import 'package:flutter/material.dart';
import '../models/disaster_card_model.dart';
import '../service/data_service.dart';


class DisasterCardRepo extends ChangeNotifier {


  final DataService dataService;

  DisasterCardRepo(this.dataService){}

  List<DisasterCardWidget> cards = [];



  void download() async {
    List<DisasterCardModel> models = await dataService.getDisasterCard();
    cards = models.map((e) => DisasterCardWidget.fromModel(e)).toList();

    notifyListeners(); // bu satır neden gerekli emin dğeilim
  }


}



final disasterCardRepoProvider = ChangeNotifierProvider((ref) {
  return DisasterCardRepo(ref.watch(dataServiceProvider));
});







