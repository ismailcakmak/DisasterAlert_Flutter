
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:untitled/repo/disaster_card_repo.dart';
import 'package:untitled/screens/form.dart';
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





class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    late GoogleMapController mapController;

    final LatLng exlocation = const LatLng(45.999999, -122.4444);

    void _onMapCreated(GoogleMapController controller) {
      mapController = controller;
    }

    final Set<Marker> markers = <Marker> {};

    markers.add(Marker( //add second marker
      markerId: MarkerId(exlocation.toString()),
      position: exlocation, //position of marker
      infoWindow: InfoWindow( //popup info
        title: 'My Custom Title ',
        snippet: 'My Custom Subtitle',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    PageController controller = PageController(initialPage: 0);

    final disasterCardRepoVar = ref.watch(disasterCardRepoProvider);

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Expanded(
              child: GoogleMap(
                  markers: markers,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: exlocation,
                    zoom: 11.0,
                  )
              ),
            ),
            Expanded(
              child: PageView(
                controller: controller,
                onPageChanged:  (index) {
                  location = disasterCardRepoVar.cards[index].location;
                  markers.add( Marker(
                    markerId: MarkerId(exlocation.toString()),
                    position: exlocation,
                    infoWindow: InfoWindow(
                      title: 'My Custom Title ',
                      snippet: 'My Custom Subtitle',
                    ),
                    icon: BitmapDescriptor.defaultMarker, //Icon for Marker
                  )
                  );
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyScreen())); },
        child: Icon(Icons.add),
      ),
    );
  }

}










