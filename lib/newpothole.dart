import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:flutter/material.dart";
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'weatherdata.dart';
import 'userlocation.dart';

class Reportpot extends StatefulWidget {
  Reportpot({Key? key}) : super(key: key);

  @override
  State<Reportpot> createState() => _ReportpotState();
}

class _ReportpotState extends State<Reportpot> {
  final Future<FirebaseApp> DBref = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("report"),
        ),
        body: FutureBuilder(
          future: DBref,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print("errrrrrror");
              return Text("something went wrong");
            } else if (snapshot.hasData) {
              return Center(
                child: Text("added pothole"),
              );
            }
            return Center(
              child: Text("wwent wrong"),
            );
          },
        ));
  }
}
