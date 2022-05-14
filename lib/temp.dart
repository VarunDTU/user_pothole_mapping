import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'weatherdata.dart';
import 'userlocation.dart';

class Mainpage extends StatefulWidget {
  Mainpage({Key? key}) : super(key: key);

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  double lat = 2.0, long = 2.0;
  String user_city = "delhi";
  var flag = 1;
  var tex_con = "";

  final _pos = Userlocation();
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (flag == 1) {
              _report();
              flag = 0;
              tex_con = "Added your location";
            } else {
              tex_con = "already added your location try again later ";
            }
            setState(() {
              tex_con;
            });
          },
          child: Icon(
            Icons.upload,
          ),
        ),
        body: Center(
            child: Text(
                '\tYour Location \n\n latitude: ${lat} \n longitude: ${long} \n${tex_con}')),
        bottomNavigationBar: Container(
          child: TextButton(
              child: Text('press to get your location'),
              onPressed: () {
                _userpos();
              }),
        ));
  }

  Future _userpos() async {
    final user_location = await _pos.userlocation();
    double lat_t = user_location.latitude, long_t = user_location.longitude;

    setState(() {
      lat = lat_t;
      long = long_t;
    });
  }

  void _report() async {
    await _userpos();
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    FirebaseFirestore.instance
        .collection('pothole2')
        .doc('NW0XrnYLQzgLNObyKbzO')
        .update({
      "array": FieldValue.arrayUnion([GeoPoint(lat, long)])
    });
  }
}
