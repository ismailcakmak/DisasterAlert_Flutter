
import 'package:flutter/material.dart';
import '../models/disaster_card_model.dart';


class DisasterCardWidget extends StatelessWidget {

  final String? _disasterName;
  final String? _disasterType;
  final int? _distance;


  DisasterCardWidget() : this._disasterType = "Sel Felaketi", this._distance = 400, this._disasterName = "Evimizi su bastı" {}
  DisasterCardWidget.fromModel(DisasterCardModel model):  this._disasterType = model.disasterType, this._distance = model.distance, this._disasterName = model.disasterName {}



  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 400,
      child: Container(
          color : Colors.white24,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children :  [
                    Text(_disasterName!,textScaleFactor: 2,),
                    SizedBox(height: 4, width: 100,),
                    ElevatedButton(
                      onPressed: null,
                      child: Icon(Icons.share),
                    ),
                  ]
              ),
              Text("Disaster Type : $_disasterType "),
              Text("Felaketin Uzaklığı : $_distance"),
            ],
          )
      ),
    );
  }


}