import 'dart:async';

import 'package:delivery/src/api/environment.dart';
import 'package:delivery/src/models/order.dart';
import 'package:delivery/src/models/product.dart';
import 'package:delivery/src/models/response_api.dart';
import 'package:delivery/src/models/user.dart';
import 'package:delivery/src/provider/orders_provider.dart';
import 'package:delivery/src/utils/my_colors.dart';
import 'package:delivery/src/utils/my_snackbar.dart';
import 'package:delivery/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:url_launcher/url_launcher.dart';

class ClientOrdersMapController{
  BuildContext context;
  Function refresh;
  CameraPosition initialPosition = CameraPosition(
      target: LatLng(-12.0630149, -77.0296179), // position close to Huacho
      zoom: 14);
  Completer<GoogleMapController> _mapController = Completer();
  Position _position;
  String addressName;
  LatLng addressLatLng;
  BitmapDescriptor deliveryMarker;
  BitmapDescriptor toMarker;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  // to draw route line from delivery point to customer point
  Set<Polyline> polylines ={};
  List<LatLng> points=[];
  Order order;
  User user;
  // for event in real time
  StreamSubscription _positionStream;
  SharedPref _sharedPref= new SharedPref();
  OrdersProvider _ordersProvider = new OrdersProvider();
  double _distanceBetween;
  Future init(BuildContext context, Function refresh) async{
    this.context = context;
    this.refresh = refresh;
    // bring the order from  DeliveryOrdersDetailController passed as an argument
    order = Order.fromJson(ModalRoute.of(context).settings.arguments as Map<String, dynamic>);
    // define custom marker icon
    deliveryMarker = await createMarkFromAsset('assets/img/delivery2.png');
    toMarker = await createMarkFromAsset('assets/img/home.png');
    user = User.fromJson(await _sharedPref.read('user'));
    _ordersProvider.init(context, user);
    checkGPS();
  }
  // check if deliverer is close to destination to finish order
  void isCloseToDeliveryPosition(lat, lng){
    _distanceBetween = Geolocator.distanceBetween(lat, lng, order.address.lat, order.address.lng);
    print('distancia $_distanceBetween');
  }

  void updateToDelivered() async{
    if(_distanceBetween<=200){
      print('Distance is close enough to deliver $_distanceBetween');
    }else{
      print('Distance is not close enough to deliver $_distanceBetween');
      //MySnackbar.show(context, "Debes estar cerca al destino");
    }
    ResponseApi responseApi = await _ordersProvider.updateToDelivered(order);
    if(responseApi.success){
      Fluttertoast.showToast(msg: responseApi.message, toastLength: Toast.LENGTH_LONG);
      Navigator.pushNamedAndRemoveUntil(context,'delivery/orders/list', (route) => false);
    }
    // min distance between delivery man and destination is 200

  }
  Future<BitmapDescriptor> createMarkFromAsset(String path) async{
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor descriptor = await BitmapDescriptor.fromAssetImage(configuration, path);
    return descriptor;
  }
  Future<void> setPolylines(LatLng from, LatLng to) async{
    PointLatLng pointFrom = PointLatLng(from.latitude, from.longitude);
    PointLatLng pointTo = PointLatLng(to.latitude, to.longitude);
    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
        Environment.API_KEY_MAPS,
        pointFrom,
        pointTo
    );
    for(PointLatLng point in result.points){
      points.add(LatLng(point.latitude, point.longitude));
    }
    Polyline polyline = Polyline(
        polylineId: PolylineId('poly'),
        color: MyColors.primaryColor,
        points: points,
      width: 5
    );
    polylines.add(polyline);
    refresh();
  }
  void dispose(){
    _positionStream?.cancel();
  }
  void call(){
    launch("tel://${order.client.phone}");
  }
  void addMarker(String markerId, double lat, double lng,String title, String content, BitmapDescriptor iconMarker){
    MarkerId id = MarkerId(markerId);
    Marker marker= Marker(
      markerId: id,
      icon: iconMarker,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: content)
    );
    markers[id]=marker;
    refresh();
  }
  Future<Null> setLocationDraggableInfo() async{
    if(initialPosition!=null){
      double lat = initialPosition.target.latitude;
      double lng = initialPosition.target.longitude;

      List<Placemark> address = await placemarkFromCoordinates(lat,lng);
      if(address!=null){
        if(address.length >0){
          String direction = address[0].thoroughfare;
          String street = address[0].subThoroughfare;
          String city = address[0].locality;
          String department = address[0].administrativeArea;
          String country = address[0].country;
          addressName = '$direction #$street, $city, $department';
          addressLatLng = new LatLng(lat, lng );
          refresh();
        }
      }
    }

  }
  void selectReferencePoint(){
    Map<String, dynamic> data ={
      'address': addressName,
      'lat': addressLatLng.latitude,
      'lng': addressLatLng.longitude
    };
    Navigator.pop(context, data);
  }
  void onMapCreated(GoogleMapController controller){
    controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#f5f5f5"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#f5f5f5"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},{"featureType":"road.arterial","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#dadada"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#c9c9c9"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]}]');
    _mapController.complete(controller);
  }
  void updateLocation() async{
    try{
      await _determinePosition(); // get current position and ask for permissions
      _position = await Geolocator.getLastKnownPosition(); // get lat and lng
      animateCameraToPosition(_position.latitude, _position.longitude);
      addMarker('delivery', _position.latitude, _position.longitude, 'Tu posición','', deliveryMarker);
      addMarker('home', order.address.lat, order.address.lng, 'Lugar de entrega','', toMarker);
      // Configuring line of the maps
      LatLng from = new LatLng(_position.latitude, _position.longitude);
      LatLng to = new LatLng(order.address.lat, order.address.lng);
      setPolylines(from, to);

      // update location while moving
      _positionStream = Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best, distanceFilter: 1).listen((position) {
        addMarker('delivery', position.latitude, position.longitude, 'Tu posición','', deliveryMarker);
        animateCameraToPosition(_position.latitude, _position.longitude);
        isCloseToDeliveryPosition(position.latitude, position.longitude);
        refresh();
      });
    }catch(e){
      print('Error: $e');
    }
  }
  void checkGPS() async{
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if(isLocationEnabled){
      updateLocation();
    }else{
      bool locationGPS = await location.Location().requestService();
      if(locationGPS){
        updateLocation();
      }
    }
  }
  Future animateCameraToPosition(double lat, double lng) async{
    GoogleMapController controller= await _mapController.future;
    if(controller!= null){
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(lat, lng),
            zoom: 13,
            bearing: 0
        )
      ));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }
  void launchGoogle() async {
    var url ='google.navigation:q=${order.address.lat},${order.address.lng}';
    var fallbackUrl = 'https://google.com/maps/search/?api=1&query=${order.address.lat},${order.address.lng}';
    try{
      bool launched = await launch(url, forceSafariVC: false, forceWebView:false);
      if(!launched){
        await launch(fallbackUrl, forceSafariVC: false, forceWebView:false);
      }
    }catch(e){
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }
  void launchWaze() async {
    var url ='waze://?ll=${order.address.lat},${order.address.lng}';
    var fallbackUrl = 'https://waze.com/ul?ll=${order.address.lat},${order.address.lng}&navigate=yes';
    try{
      bool launched = await launch(url, forceSafariVC: false, forceWebView:false);
      if(!launched){
        await launch(fallbackUrl, forceSafariVC: false, forceWebView:false);
      }
    }catch(e){
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }
}