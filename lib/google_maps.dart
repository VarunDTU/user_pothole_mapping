import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/main.dart';
import 'package:maps/newpothole.dart';
import 'package:maps/temp.dart';
import 'weatherdata.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'userlocation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:maps/google_maps.dart';
import 'main.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class Google_maps extends StatefulWidget {
  Google_maps({Key? key}) : super(key: key);

  @override
  State<Google_maps> createState() => _Google_mapsState();
}

class _Google_mapsState extends State<Google_maps> {
  final _getweather = Getweather(); //calling instance of get weather
  final _pos = Userlocation();
  var rain = 'Sync for weather';
  var city = 'error';
  var lat = 28.610;
  var long = 77.00;
  var flag = false;

  late final Completer<GoogleMapController> _controller = Completer();
  List<Marker> marker = [];
  var refreshtime = 4;
  //list of marker to be placed on map

  @override
  void initState() {
    _search();

    Timer.periodic(Duration(hours: refreshtime), (timer) {
      getlist();
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("map screen - ${rain}"),
      //   backgroundColor: Colors.black,
      // ),
      body: Stack(
        children: [
          GoogleMap(
            markers: Set<Marker>.of(marker),
            initialCameraPosition: CameraPosition(
              target: LatLng(lat, long),
              zoom: 17,
            ),
            myLocationEnabled: true,
            mapType: MapType.normal,
            onLongPress: _adddesmarker,
            trafficEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
          await _firebaseAuth.signOut();
          await GoogleSignIn().signOut();
          setState(() {});

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignInScreen()));

          //getlist();
        },
        child: Icon(Icons.dangerous),
        backgroundColor: Color.fromARGB(255, 156, 4, 4),
      ), //button checks weather-> add user coordinates in database->reloads the widget
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,

      bottomNavigationBar: Container(
        child: TextButton(
            child: Text("report pothole in your location?"),
            onPressed: () async {
              if (flag == false) {
                _search();
                _reportdb();
                flag = true;
                Fluttertoast.showToast(msg: "Thanks for sharing this info :)");
                final timer = Timer(const Duration(seconds: 10), () {
                  flag = false;
                });
              } else {
                Fluttertoast.showToast(
                    msg: "wait for 10 seconds :( to report again");
              }
              setState(() {
                flag;
              });
            }),
      ),
      backgroundColor: Colors.black,
    );
  }

  Future _userpos() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    final user_location = await _pos.userlocation();
    double lat_t = user_location.latitude, long_t = user_location.longitude;

    setState(() {
      lat = lat_t;
      long = long_t;
    });
  }

  Future _search() async {
    //set city variable has to be dynamic with user location

    await _userpos();
    final response = await _getweather.getweather(lat, long);
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    city = placemarks[0].administrativeArea.toString().toLowerCase();
    String rain_a = response.weatherDescription.toString().toLowerCase();

    if (rain_a.contains('rain')) ;
    {
      refreshtime = 2;
    }
    setState(() {
      rain = rain_a;
      city;
      refreshtime; //reloads widget
    });
    getlist();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, long), zoom: 17)));
  }

  void _report() async {
    FirebaseFirestore.instance
        .collection('pothole2')
        .doc('NW0XrnYLQzgLNObyKbzO')
        .update({
      "${city}": FieldValue.arrayUnion([GeoPoint(lat, long)])
    });
  }

  void _reportdb() async {
    await _search();

    _report();
  }

  FirebaseFirestore? _instance;

  Future<void> getlist() async {
    _instance = FirebaseFirestore.instance;
    CollectionReference markers = _instance!.collection('pothole2');
    DocumentSnapshot snapshot = await markers.doc('NW0XrnYLQzgLNObyKbzO').get();
    var data = snapshot.data() as Map;

    final List<dynamic> citydata;
    citydata = data['${city}'];
    marker.clear();
    int x = 2;
    citydata.forEach((element) {
      x++;

      marker.add(Marker(
        markerId: MarkerId("${x}"),
        position: LatLng(element.latitude, element.longitude),
      ));
    });

    setState(() {
      marker;
    });
  }

  var destination;
  void _adddesmarker(LatLng argument) {
    destination = LatLng(argument.latitude, argument.longitude);
    Timer.periodic(Duration(seconds: 5), (timer) {
      _userpos();

      marker.removeWhere((item) => item.markerId == "origin");
      setState(() {
        marker.add(Marker(
            markerId: MarkerId("origin"),
            position: LatLng(lat, long),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueCyan)));
      });
    });
    setState(() {});
    setState(() {
      destination;
      marker;
      marker.add(Marker(
        markerId: MarkerId("dest"),
        position: argument,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    });
  }
}

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}
