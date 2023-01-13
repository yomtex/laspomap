import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:laspomap/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class MyMap extends StatefulWidget {
  const MyMap({Key? key}) : super(key: key);

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
final Completer<GoogleMapController> _controller = Completer();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
SingleValueDropDownController  route_name = SingleValueDropDownController ();

  List<LatLng> polylineCoordinates = [];
  LocationData? curentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLicationIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation()async{
    Location location = Location();
    //instance of Location
    location.getLocation().then((location){
      curentLocation = location;
    });

    //define controller after getting the current location
    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLoc) {
      curentLocation = newLoc;

      //change camera into new position
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              zoom: 14,
              tilt: 59,
              bearing: -70,
              target: LatLng(
                  newLoc.latitude!,
                  newLoc.longitude!

              ),
          ),
      ));
      setState((){});
    });
  }

  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383,-122.06600055);

  //draw lines
  void getPolyPoints()async
  {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result =await  polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude));
    if(result.points.isNotEmpty){
      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude));
      }
      setState(() {

      });
    }
  }

  void setCustomMarkerIcon(){

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/Pin_source.png").
    then((icon) {
      sourceIcon =icon;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/Pin_destination.png").
    then((icon) {
      destinationIcon =icon;
    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/Badge.png").
    then((icon) {
      currentLicationIcon =icon;
    });
  }

  @override
  void initState() {
    getRout();
    getPolyPoints();
    route_name = SingleValueDropDownController();
    setCustomMarkerIcon();
    getCurrentLocation();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar:  AppBar(
      //   centerTitle: true,
      //   backgroundColor: Colors.blueAccent,
      //   elevation: 0,
      //   title: const Text(
      //     "Laspotech Map",
      //     style: TextStyle(
      //         color: Colors.white,
      //         fontSize: 16,
      //         fontWeight: FontWeight.bold),
      //   ),
      // ),
      body:SlidingUpPanel(
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(
              5.0,
              5.0,
            ),
            blurRadius: 10.0,
            spreadRadius: 2.0,
          ), //BoxShadow
          BoxShadow(
            color: Colors.red,
            offset: Offset(0.0, 0.0),
            blurRadius: 0.0,
            spreadRadius: 0.0,
          ),
        ],
        minHeight: 50,
        maxHeight: 200,
        panel: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10,),
                const Center(child: Text("Laspotech Map"),),
                const SizedBox(height: 15,),
                DropDownTextField(
                  enableSearch: true,
                  clearOption: true,
                  searchDecoration:const InputDecoration(hintText: "Where to ?", border: OutlineInputBorder()),
                  controller: route_name,
                  dropDownList: const [
                    DropDownValueModel(name: "name", value: "value"),
                    DropDownValueModel(name: "name1", value: "value1"),
                    DropDownValueModel(name: "name2", value: "value2"),
                    DropDownValueModel(name: "name3", value: "value3"),
                  ],
                ),
                // TextFormField(
                //   controller: route_name,
                //   decoration: const InputDecoration(
                //       hintText: "Where to ?", border: OutlineInputBorder()),
                // ),
                const SizedBox(height: 20,),
                InkWell(
                  onTap: (){},
                  child:Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.blue
                    ),
                    child:  const Padding(
                      padding:  EdgeInsets.all(15.0),
                      child: Text("Search",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),),
                    ),) ,
                )
              ],
            ),
          ),
        ),
        collapsed: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              // changing radius that we define above
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20))
          ),
          // collapsed text
          child: const Center(
            child: Text(
              "Laspotech Map",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        // main body or content behind the panel
        body:
        curentLocation == null?
        Center(
          child: InkWell(
            onTap: (){
              //print(curentLocation);
             },
              child: const Text("Loading")),): GoogleMap(
          initialCameraPosition: const CameraPosition(
              target: sourceLocation,zoom: 13),
          polylines: {
            Polyline(
                polylineId: const PolylineId("route"),
                points: polylineCoordinates,
                color: Colors.red
            )
          },
          markers: {
            Marker(
                icon: currentLicationIcon,
                markerId: const MarkerId("curentLocation"),
                position: LatLng(curentLocation!.latitude!, curentLocation!.longitude!)),
            Marker(
                icon: sourceIcon,
                markerId: const MarkerId("source"),
                position: sourceLocation),
            Marker(
                icon: destinationIcon,
                markerId: const MarkerId("destination"),
                position: destination),
          },
          onMapCreated: (mapController){
            _controller.complete(mapController);
          },
        ),
        borderRadius:  BorderRadius.circular(20),
      ),


    );
  }
  getRout()async{
  //   Map mapResponse = {};
  //   List transactions=[];
  //   var url = Uri.parse(
  //       "http://127.0.0.1:8000/api/all-route");
  //   http.Response response = await http.get(url, headers: {
  //     'Accept': 'application/json',
  //   });
  //   var data = json.decode(response.body);
  //   //print(data);
  }
}
