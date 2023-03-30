
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:untitled/repo/disaster_card_repo.dart';
import 'package:untitled/screens/form.dart';
import 'package:untitled/service/data_service.dart';
import 'package:untitled/utilities/Google_sign_in.dart';


void main() {
  runApp(ProviderScope(child: MyApp()));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(situation: false),
    );
  }
}




class SplashScreen extends StatefulWidget {

  bool situation;
  SplashScreen({required this.situation, super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  late bool loading;

  @override
  void initState() {
    super.initState();
    loading = widget.situation;
    initializeFirebase();
  }


  Future<void> initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    if(loading == false){ loading = true; setState(() {}); }
    if(FirebaseAuth.instance.currentUser != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyHomePage()));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( body : Center(child :  loading
        ? ElevatedButton(
        onPressed: () async {
          await signInWithGoogle();
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyHomePage()));
        },
        child: const Text("Sign In"))
        : const CircularProgressIndicator()));

  }

}




Marker MarkerGenerator({required LatLng position, required String title, required String snippet,}) {
  return Marker( //add second marker
    markerId: MarkerId(position.toString()),
    position: position, //position of marker
    infoWindow: InfoWindow( //popup info
      title: title,
      snippet: snippet,
    ),
    icon: BitmapDescriptor.defaultMarker, //Icon for Marker
  );
}



class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});


  @override
  ConsumerState<MyHomePage>  createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {

  bool check = false;
  LatLng zoomLocation = LatLng(0, 0);


  var disasterCardRepoVar = DisasterCardRepo(DataService());

  Set<Marker> currentMapMarkers = {

    Marker(
      markerId: const MarkerId("istanbul"),
      position: const LatLng(41.0082, 28.9784),
    ),

    Marker(
      markerId: const MarkerId("Ankara"),
      position: const LatLng(39.9334, 32.8597),
    ),
  }; // it always include 2 Marker, first one is locaiton of user.



  Future<void> getCurrentLocation() async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    LocationPermission permission =  await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error( 'permissions are permanently denied, we cannot request');
    }

    var position =  await Geolocator.getCurrentPosition();
    final LatLng location = LatLng(position.latitude, position.longitude);
    var tempMarker = MarkerGenerator(position : location, title : "My Location", snippet : "");
    currentMapMarkers.add(tempMarker);
    zoomLocation = location;


  }


  Set<Marker> setOfLocationMarkers = {};


  Future<void> initilize() async {
    disasterCardRepoVar = ref.watch(disasterCardRepoProvider);
    await disasterCardRepoVar.download();
    setState(() {
      check = true;
    });

  }

  var controller = PageController();


  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  void initState()  {
    super.initState();
    getCurrentLocation();

  }


  @override
  Widget build(BuildContext context) {
    initilize();

    late GoogleMapController mapController;

    Map<MarkerId, Marker> markers = <MarkerId, Marker>{}; // CLASS MEMBER, MAP OF MARKS



    return Scaffold(
      appBar: AppBar(
        title: Text("Disaster Alert"),
      ),
      drawer: Drawer(
          child : ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: Text("${FirebaseAuth.instance.currentUser?.displayName}")
              ),
              ListTile(
                title: Text("Sign Out"),
                onTap: (){
                  signOutWithGoogle();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SplashScreen(situation: true)));
                },
              )
            ],
          )
      ),

      body: Center(child: check
          ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Expanded(
              child: GoogleMap(
                  myLocationEnabled : true,
                  //zoomControlsEnabled: true,
                  markers: Set.from(currentMapMarkers),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: zoomLocation,
                    zoom: 11.0,
                  )
              ),
            ),
            ElevatedButton(
                onPressed: () {

                },
                child: Text("Deneme"),
            ),

            Expanded(
                child: PageView(
                  controller: controller,
                  onPageChanged:  (index){

                    double latitude = disasterCardRepoVar.models[index].location!['latitude'].toDouble() ?? 0.0 ;
                    double longitude = disasterCardRepoVar.models[index].location!['longitude'].toDouble() ?? 0.0;
                    String title = disasterCardRepoVar.models[index].location!['disasterName'] ?? "";

                    mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                            CameraPosition(target: LatLng(latitude, longitude), zoom: 17)
                          //17 is new zoom level
                        )
                    );

                    currentMapMarkers.add(
                      Marker(
                        markerId: MarkerId("$title"),
                        position: LatLng(latitude as double, longitude as double),
                      ),
                    );
                    setState(() {

                    });
                  },
                  children: disasterCardRepoVar.cards,
                )
            ),

            ElevatedButton(
                onPressed: () {
                  disasterCardRepoVar.download();
                },
                child: Text("Get Data")),
          ]
      )
          : CircularProgressIndicator(),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () { Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyScreen())); },
        child: Icon(Icons.add),
      ),
    );
  }


}
