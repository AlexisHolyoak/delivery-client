import 'package:delivery/src/models/order.dart';
import 'package:delivery/src/pages/client/orders/list/client_orders_list_controller.dart';
import 'package:delivery/src/pages/delivery/orders/list/delivery_orders_list_controller.dart';
import 'package:delivery/src/pages/restaurant/orders/list/restaurant_orders_list_controller.dart';
import 'package:delivery/src/utils/my_colors.dart';
import 'package:delivery/src/widgets/no_data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ClientOrdersListPage extends StatefulWidget {
  @override
  _ClientOrdersListPageState createState() => _ClientOrdersListPageState();
}

class _ClientOrdersListPageState extends State<ClientOrdersListPage> {
  ClientOrdersListController _con = new ClientOrdersListController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }
  @override
  Widget build(BuildContext context) {
    return  DefaultTabController(
      length: _con.status?.length,
      child: Scaffold(
          key: _con.key,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(100),
            child: AppBar(
              title: Text('Mis pedidos'),
                //change default drawer button
                backgroundColor: MyColors.primaryColor,
                bottom: TabBar(
                  indicatorColor: MyColors.primaryColor,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[400],
                  isScrollable: true,
                  tabs: List<Widget>.generate(_con.status.length, (index) {
                    return Tab(
                        child: Text(_con.status[index]??'')
                    );
                  }),
                )
            ),
          ),
          body: TabBarView(
            children: _con.status.map((String status){
              return FutureBuilder(
                  future: _con.getOrders(status)!=null? _con.getOrders(status): [],
                  builder: (context, AsyncSnapshot<List<Order>> snapshot){
                    if(snapshot.hasData){
                      if(snapshot.data.length>0){
                        return ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                            itemCount: snapshot.data?.length?? 0,
                            itemBuilder: (_,index){
                              return _cardOrder(snapshot.data[index]);
                            });
                      }else{
                        return NoDataWidget(text: "No hay ordenes");
                      }
                    }else{
                      return NoDataWidget(text: "No hay ordenes");
                    }
                  }
              );
            }).toList(),
          )
      ),
    );
  }
  Widget _cardOrder(Order order){
    return GestureDetector(
      onTap: (){
        _con.openBottomSheet(order);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        height: 160,
        child: Card(
          elevation: 3.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
          child: Stack(
            children: [
              Positioned(
                child: Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width*0.9,
                  decoration: BoxDecoration(
                      color: MyColors.primaryColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)
                      )
                  ),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text('Orden #${order.id??''}',
                        style: TextStyle(fontSize: 15, color: Colors.white, fontFamily: 'NimbusSans')
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 40,left: 20,right: 20),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      width: double.infinity,
                      child: Text('Fecha: ${order.timestamp??''}',
                        style: TextStyle(
                            fontSize: 13
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      width: double.infinity,
                      child: Text('Repartidor: ${order.delivery?.name??'Sin asignar'} ${order.delivery?.lastname??''}',
                        style: TextStyle(
                            fontSize: 13),
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      width: double.infinity,
                      child: Text('Dirección: ${order.address?.address??''}',
                        style: TextStyle(
                            fontSize: 13),
                        maxLines: 2,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget _textFieldSearch(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
            hintText: 'Buscar',
            suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                    color: Colors.grey[300]
                )
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                    color: Colors.grey[200]
                )
            ),
            contentPadding: EdgeInsets.all(15)
        ),
      ),
    );
  }
  void refresh(){
    setState(() {

    });
  }
}
