import 'package:delivery/src/pages/client/orders/map/client_orders_map_controller.dart';
import 'package:delivery/src/pages/delivery/orders/map/delivery_orders_map_controller.dart';
import 'package:delivery/src/utils/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClientOrdersMapPage extends StatefulWidget {
  @override
  _ClientOrdersMapPageState createState() => _ClientOrdersMapPageState();
}

class _ClientOrdersMapPageState extends State<ClientOrdersMapPage> {
  ClientOrdersMapController _con=new ClientOrdersMapController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _con.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height*0.67,
            child: _googleMaps()
          ),
          SafeArea(
            child: Column(
              children: [
                _buttonCenterPosition(),
                Spacer(),
                _cardOrderInfo(),
              ],
            ),
          ),
          /*
          Positioned(
            top: 90,
            left: 15,
            child: _iconWaze(),
          )*/
        ],
      ),
    );
  }

  Widget _cardOrderInfo(){
    return Container(
      height: MediaQuery.of(context).size.height *0.33,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20)
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0,3)
          )
        ]
      ),
      child: Column(
        children: [
          _listTileAddress('Barrio',_con.order?.address?.neighborhood, Icons.my_location),
          _listTileAddress('Dirección',_con.order?.address?.address, Icons.location_on),
          Divider(color: Colors.grey[400], endIndent: 30, indent: 30,),
          _clientInfo()
        ],
      ),
    );
  }
  Widget _clientInfo(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 35, vertical: 3),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            child: FadeInImage(
              image: _con.order?.delivery?.image != null ?
                      NetworkImage(_con.order?.delivery?.image):
                      AssetImage('assets/img/no-image.png'),
              fit: BoxFit.contain,
              fadeInDuration: Duration(milliseconds: 50),
              placeholder: AssetImage('assets/img/no-image.png'),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(
              '${_con.order?.delivery?.name??''} ${_con.order?.delivery?.lastname??''}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16
              ),
              maxLines: 1,
            ),
          ),
          Spacer(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: Colors.grey[300]
            ),
            child: IconButton(
              onPressed: _con.call,
              icon:Icon(Icons.phone, color: Colors.black,)
            ),
          )
        ],
      ),
    );
  }
  Widget _listTileAddress(String title, String subtitle, IconData iconData){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: ListTile(
        title: Text(
          title ??'',
          style: TextStyle(
            fontSize: 13
          ),
        ),
        subtitle: Text('$subtitle'),
        trailing: Icon(iconData),
      ),
    );
  }
  Widget _buttonCenterPosition(){
    return GestureDetector(
      onTap: (){},
      child: Container(
        alignment: Alignment.centerRight,
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          shape: CircleBorder(),
          color: Colors.white,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.location_searching,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
  Widget _googleMaps(){
    return  GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _con.initialPosition,
        onMapCreated: _con.onMapCreated,
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
        markers: Set<Marker>.of(_con.markers.values),
        polylines: _con.polylines,
    );
  }
  Widget _iconWaze(){
    return GestureDetector(
      onTap: _con.launchWaze,
      child: Container(
        child: Image.asset(
          'assets/img/waze.png',
          height: 35,
          width: 35,
        ),
      ),
    );
  }
  Widget _iconGoogleMaps(){
    return GestureDetector(
      onTap: _con.launchGoogle,
      child: Container(
        child: Image.asset(
          'assets/img/google_maps.png',
          height: 35,
            width: 35,
        ),
      ),
    );
  }
  void refresh(){
    if(!mounted) return;
    setState(() {

    });
  }

}