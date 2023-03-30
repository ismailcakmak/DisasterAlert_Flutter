
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../cards/disaster_card_widget.dart';
import 'package:flutter/material.dart';
import '../models/disaster_card_model.dart';
import '../service/data_service.dart';


class DisasterCardRepo extends ChangeNotifier {


  final DataService dataService;


  DisasterCardRepo(this.dataService){}

  List<DisasterCardModel> models = [];
  List<DisasterCardWidget> cards = [];
  //Set<Marker> setOfLocationMarkers = {};
  //List<Marker> listOfLocationMarkers = [];


  Future<void> download() async {

    models = await dataService.getDisasterCard();
    cards = models.map((e) => DisasterCardWidget.fromModel(e)).toList();


     // bu satır neden gerekli emin dğeilim
  }


}



final disasterCardRepoProvider = ChangeNotifierProvider((ref) {
  return DisasterCardRepo(ref.watch(dataServiceProvider));
});