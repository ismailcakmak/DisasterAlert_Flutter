import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:untitled/service/data_service.dart';
import '../models/disaster_card_model.dart';


class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  String _selectedOption = 'Deprem';
  TextEditingController _textFieldController1 = TextEditingController();
  TextEditingController _textFieldController2 = TextEditingController();


  Map<String, bool> helpSources = {
    'Polis': false,
    'İtfaiye': false,
    'Sivil Halk': false,
    'Ambulans': false,
  };


  Map<String, dynamic> info = {
    'disasterType' : '',
    'disasterName' : '',
    'distance' : 0,
    'helpSources' : '',
    'disasterDescription' : ''
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Disaster'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: _selectedOption,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedOption = newValue!;
                });
              },
              items: <String>['Deprem', 'Sel', 'Heyelan', 'Yangın', 'Çatışma','Trafik Kazası']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _textFieldController1,
              decoration: InputDecoration(
                labelText: 'Sorun Nedir ?',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _textFieldController2,
              decoration: InputDecoration(
                labelText: 'Detaylar',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              "Kimlerden Yardım Talep Ediyorsunuz : ",
              textScaleFactor: 1.5,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView(
                children: helpSources.keys.map((String day) {
                  return CheckboxListTile(
                    title: Text(day),
                    value: helpSources[day],
                    onChanged: (bool? value) {
                      setState(() {
                        helpSources[day] = value!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                return ElevatedButton(
                    onPressed: () async {
                      await PrepareData(ref);
                    },
                    child: Text("Talep Oluştur")
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> PrepareData(WidgetRef ref) async {


    Map<String, double> location = {};

    info['disasterType'] = _selectedOption;
    info['disasterName'] = _textFieldController1.text;
    info['disasterDescription'] = _textFieldController2.text;
    info['distance'] = 0;
    info['helpSources'] = helpSources;
    info['location'] = location;

    await getCurrentLocation().then((value) {
      location['latitude'] = value.latitude;
      location['longitude'] = value.longitude;

    });

    await ref.read(dataServiceProvider).addDisasterCard(DisasterCardModel.fromMap(info));

  }

  Future<Position> getCurrentLocation() async {


    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    LocationPermission permission =  await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(' Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error( 'permissionsare permanently denied, we cannot request');
    }

    return await Geolocator.getCurrentPosition();



  }

}
