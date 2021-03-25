import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:zm_supplier/createOrder/market_list_page.dart';
import 'package:zm_supplier/models/ordersResponseList.dart';
import 'package:zm_supplier/models/user.dart';
import 'package:zm_supplier/services/ordersApi.dart';
import 'package:zm_supplier/utils/color.dart';
import 'package:zm_supplier/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:zm_supplier/utils/eventsList.dart';
import 'dart:math' as math;

import 'package:zm_supplier/utils/webview.dart';

import '../utils/color.dart';
import '../utils/color.dart';
import '../utils/color.dart';
import 'orderActivityPage.dart';

class OrderDetailsPage extends StatefulWidget {
  String orderId;
  Orders order;

  OrderDetailsPage(this.order);

  @override
  State<StatefulWidget> createState() {
    return OrderDetailsDesign();
  }
}

class OrderDetailsDesign extends State<OrderDetailsPage>
    with TickerProviderStateMixin {
  Widget appBarTitle = new Text(
    "Order details",
    style: TextStyle(
        color: Colors.black, fontFamily: "SourceSansProBold", fontSize: 18),
  );
  Icon icon = new Icon(
    Icons.more_horiz,
    color: Colors.black,
  );
  final TextEditingController _controller = new TextEditingController();

  Orders order;
  bool _isSearching;
  String supplierID;
  String mudra;
  int totalNoRecords = 0;
  int pageNum = 1;
  bool isPageLoading = false;
  int totalNumberOfPages = 0;
  int pageSize = 50;
  ScrollController controller;
  String searchedString;
  LoginResponse userData;

  Constants events = Constants();

  @override
  void initState() {
    loadSharedPrefs();
    order = widget.order;
    super.initState();
    events.mixPanelEvents();
  }

  @override
  void dispose() {
    // controller.removeListener(_scrollListener);
    super.dispose();
  }

  SharedPref sharedPref = SharedPref();

  loadSharedPrefs() async {
    try {
      LoginResponse loginResponse = LoginResponse.fromJson(
          await sharedPref.readData(Constants.login_Info));
      setState(() {
        if (loginResponse.mudra != null) {
          mudra = loginResponse.mudra;
        }
        if (loginResponse.user.supplier.elementAt(0).supplierId != null) {
          supplierID = loginResponse.user.supplier.elementAt(0).supplierId;
          // ordersList = callRetreiveOrdersAPI();
        }
      });
    } catch (Exception) {
      // do something

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      bottomNavigationBar: Container(
          height: 80.0,
          color: Colors.white,
          child: Center(
              child: Container(
                  height: 50,
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Row(children: <Widget>[
                    FloatingActionButton.extended(
                      heroTag: "btn1",
                      backgroundColor: faintGrey,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        events.mixpanel
                            .track(Events.TAP_ORDER_DETAILS_REPEAT_ORDER);
                        events.mixpanel.flush();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => new MarketListPage(
                                    order.outlet.outletId,
                                    order.outlet.outletName,
                                    order.products)));
                      },
                      label: Text(
                        'Repeat order',
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'SourceSansProSemiBold',
                            color: azul_blue),
                      ),
                      icon: Icon(
                        Icons.repeat_one_rounded,
                        size: 22,
                        color: buttonBlue,
                      ),
                      elevation: 0,
                    ),
                    new Spacer(),
                    FloatingActionButton.extended(
                      heroTag: "btn2",
                      backgroundColor: azul_blue,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        _openBottomSheet();
                      },
                      label: Text(
                        'Respond',
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'SourceSansProSemiBold',
                            color: Colors.white),
                      ),
                      elevation: 0,
                    ),
                  ])))),
      backgroundColor: faintGrey,
      body: ListView(
        children: <Widget>[
          banner(context),
          deliveryBanner(context),
          skuBanner(context),
          if (order.notes != null && order.notes.isNotEmpty)
            notesBanner(context),

          skuDetails(context),
          spaceBanner(context),
          priceDetails(context),
          smallSpaceBanner(context),
          contactDetails(context),
          smallSpaceBanner(context),
          // displayList(context),
        ],
      ),
    );
  }

  // Widget buildAppBar(BuildContext context) {
  //   return new AppBar(
  //       centerTitle: true,
  //       title: appBarTitle,
  //       backgroundColor: Colors.white,
  //       bottomOpacity: 0.0,
  //       elevation: 0.0,
  //       leading: IconButton(
  //         icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
  //         onPressed: () => Navigator.of(context).pop(),
  //       ),
  //       actions: <Widget>[
  //         new IconButton(
  //           icon: icon,
  //           onPressed: () {
  //             _moreActionBottomSheet(context);
  //           },
  //         ),
  //       ]);
  // }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        centerTitle: true,
        title: appBarTitle,
        backgroundColor: Colors.white,
        bottomOpacity: 0.0,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          new IconButton(
            icon: icon,
            onPressed: () {
              events.mixpanel.track(Events.TAP_ORDER_DETAILS_MORE_OPTIONS);
              events.mixpanel.flush();
              _moreActionBottomSheet(context);
            },
          ),
        ]);
  }

  Widget isAcknowledged() {
    if (order.isAcknowledged != null && order.isAcknowledged) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                //  padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text("#" + order.orderId,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: "SourceSansProBold",
                        color: greyText))),
            SizedBox(
              width: 6,
            ),
            Image.asset(
              "assets/images/icon-tick-green.png",
              width: 12,
              height: 12,
            ),
            SizedBox(
              width: 2,
            ),
            Text(
              'Acknowledged',
              style: TextStyle(
                  fontSize: 12,
                  color: green,
                  fontFamily: 'SourceSansProRegular'),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                //  padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text("#" + order.orderId,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: "SourceSansProBold",
                        color: greyText))),
          ],
        ),
      );
    }
  }

  void _openBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          // return StatefulBuilder(
          // builder: (BuildContext context, StateSetter setState) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Container(
                  height: 40,
                  child: new ListTile(
                      title: new Text(
                        'Respond to this order (optional)',
                        style: TextStyle(
                            fontSize: 14, fontFamily: 'SourceSansProSemibold'),
                      ),
                      onTap: () => {}),
                ),
                if (order.isAcknowledged == null)
                  Container(
                    height: 40,
                    child: new ListTile(
                      leading: Image.asset(
                        'assets/images/icon_tick_grey.png',
                        width: 22,
                        height: 22,
                      ),
                      title: Transform.translate(
                        offset: Offset(-25, 0),
                        child: Text('Acknowledge',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'SourceSansProRegular')),
                      ),
                      onTap: () {
                        setState(() {
                          acknowledgeOrder();
                          // selectedFilterType = 'RecentOrdered';
                          //
                          // selectedCustomersDataFuture =
                          //     getCustomersListCalling(false, true);
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Divider(
                    thickness: 2,
                    color: faintGrey,
                  ),
                ),
                Container(
                  height: 40,
                  child: new ListTile(
                    leading: Image.asset(
                      'assets/images/icon_close-red.png',
                      width: 22,
                      height: 22,
                    ),
                    title: Transform.translate(
                      offset: Offset(-25, 0),
                      child: new Text('Void order',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'SourceSansProRegular',
                              color: warningRed)),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      voidOrderReasons();
                      // setState(() {
                      //   // print('void tapped');
                      //   // voidOrderReasons();
                      //   // selectedFilterType = 'A-Z';
                      //   // selectedCustomersDataFuture =
                      //   //     getCustomersListCalling(false, true);
                      // });
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, 20)),
              ],
            ),
            // }
          );
        });
  }

  acknowledgeOrder() async {
    OrderApi acknowledge = new OrderApi();

    userData =
        LoginResponse.fromJson(await sharedPref.readData(Constants.login_Info));
    acknowledge
        .acknowledgeOrder(
            userData.mudra, userData.supplier.first.supplierId, order.orderId)
        .then((value) async {
      if (value == Constants.status_success) {
        print('isAcknowledged success');
        setState(() {
          order.isAcknowledged = true;
          DartNotificationCenter.post(channel: Constants.acknowledge_notifier);
        });
      }
    });
  }

  void voidOrderReasons() {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SingleChildScrollView(
              child: Container(
            padding: EdgeInsets.only(
                top: 15.0, right: 10.0, left: 10.0, bottom: 15.0),
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 5, left: 17.0, bottom: 0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Add a reason",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontFamily: "SourceSansProSemiBold"))),
                  ),
                  ListTile(
                    title: Text(
                      'Can’t fulfil the order',
                      style: TextStyle(
                          fontSize: 16, fontFamily: 'SourceSansProRegular'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 17.0, right: 17, top: 20),
                    child: Divider(thickness: 2, color: faintGrey),
                  ),
                  Container(
                    height: 40,
                    color: Colors.yellow,
                    child: Text(
                        'Requested by buyer',
                        style: TextStyle(
                            fontSize: 16, fontFamily: 'SourceSansProRegular'),
                      ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 17.0, right: 17, top: 20),
                    child: Divider(thickness: 2, color: faintGrey),
                  ),                  Container(
                    height: 20,
                    child: ListTile(
                      title: Text(
                        'Other reason (type below)',
                        style: TextStyle(
                            fontSize: 16, fontFamily: 'SourceSansProRegular'),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    margin: EdgeInsets.only(top: 20.0),
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.text,
                      maxLines: null,
                      //  maxLength: 150,
                      autofocus: true,
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        fillColor: faintGrey,
                        filled: true,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        // hintText: Constants.txt_add_notes,
                        // hintStyle: new TextStyle(
                        //     color: greyText,
                        //     fontSize: 16.0,
                        //     fontFamily: "SourceSansProRegular"),
                      ),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontFamily: "SourceSansProRegular"),
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        // if (_txtOrderNotesEditController.text != null &&
                        //     _txtOrderNotesEditController.text.isNotEmpty) {
                        //   setState(() {
                        //     orderNotes = _txtOrderNotesEditController.text;
                        //   });
                        // } else {
                        //   setState(() {
                        //     orderNotes = "Notes";
                        //   });
                        // }
                        Navigator.pop(context);
                      },
                      child: Container(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          margin: EdgeInsets.only(
                              top: 20.0, right: 20.0, left: 20.0),
                          height: 47.0,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: buttonBlue,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          child: Center(
                              child: Text(
                            "Done",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: "SourceSansProSemiBold"),
                          ))))
                ],
              ),
            ),
          ));
        });
  }

  Widget banner(BuildContext context) {
    return new Container(
      padding:
          new EdgeInsets.only(top: 20, left: 10.0, bottom: 8.0, right: 10.0),
      decoration: new BoxDecoration(color: faintGrey),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          new Card(
            child: new Column(
              children: <Widget>[
                Center(child: isAcknowledged()),

                // Container(
                //     padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                //     child: Text("#" + order.orderId,
                //         textAlign: TextAlign.center,
                //         style: TextStyle(
                //             fontSize: 14,
                //             fontFamily: "SourceSansProBold",
                //             color: greyText))),
                Center(
                    child: Container(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: Text(order.outlet.outletName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                fontFamily: "SourceSansProBold")))),
                Center(
                    child: Container(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Text("Placed: " + order.getDatePlaced(),
                            style: TextStyle(
                                fontSize: 12,
                                fontFamily: "SourceSansProRegular")))),
                Constants.OrderStatusColor(order),
                Center(
                    child: Container(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Text('', style: TextStyle(fontSize: 4)))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget deliveryBanner(BuildContext context) {
    return new Container(
      padding: new EdgeInsets.only(top: 0, left: 0.0, bottom: 0.0, right: 0.0),
      decoration: new BoxDecoration(color: faintGrey),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          new Card(
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 5.0),
                      color: faintGrey,
                      height: 26.0,
                      width: 26.0,
                      child: ImageIcon(
                          AssetImage('assets/images/icon_delivery_truck.png')),
                    ),
                    Text(order.getDeliveryDay(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.0,
                            fontFamily: "SourceSansProRegular")),
                  ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text("                ",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontFamily: "SourceSansProBold")),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                          child: Text(order.getDeliveryDateMonthYear(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: "SourceSansProBold")),
                        ),
                      ]),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
                  if (order.deliveryInstruction != null &&
                      order.deliveryInstruction.isNotEmpty)
                    new Card(
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      color: keyLineGrey,
                      child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 20, 0, 5)),
                              Text("    Delivery instructions",
                                  style: TextStyle(
                                      color: greyText,
                                      fontSize: 10.0,
                                      fontFamily: "SourceSansProBold")),
                            ]),
                            Padding(padding: EdgeInsets.fromLTRB(20, 5, 20, 0)),
                            Row(children: <Widget>[
                              Text("     " + order.deliveryInstruction,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.0,
                                      fontFamily: "SourceSansProRegular")),
                            ]),
                            Padding(padding: EdgeInsets.fromLTRB(20, 5, 20, 0)),
                          ]),
                    ),
                ]),
          )
        ],
      ),
    );
  }

  Widget skuBanner(BuildContext context) {
    int count = order.products.length;
    return Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Text('$count items',
            style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontFamily: "SourceSansProBold")));
  }

  Widget notesBanner(BuildContext context) {
    return new Card(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
      color: yellow,
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: <Widget>[
              Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
              Text("       Notes or Special request",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 10.0,
                      fontFamily: "SourceSansProBold")),
            ]),
            Row(children: <Widget>[
              Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 0)),
              Text("     " + order.notes,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontFamily: "SourceSansProRegular")),
            ]),
            Padding(padding: EdgeInsets.fromLTRB(10, 5, 20, 5)),
          ]),
    );
  }

  Widget skuDetails(BuildContext context) {
    List<Products> products = order.products;
    var listView = ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            LeftRightAlign(
                                left: Text(products[index].productName,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: "SourceSansProBold")),
                                right: Text(
                                    products[index].quantity.toString() +
                                        " " +
                                        products[index].unitSizeAlias.shortName,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: "SourceSansProRegular"))),
                            Padding(padding: EdgeInsets.fromLTRB(10, 5, 20, 0)),
                            Row(children: <Widget>[
                              Text(products[index].totalPrice.getDisplayValue(),
                                  style: TextStyle(
                                      color: grey_text,
                                      fontSize: 12.0,
                                      fontFamily: "SourceSansProRegular")),
                            ])
                          ]),
                      if (products[index].notes != null &&
                          products[index].notes.isNotEmpty)
                        new Card(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          color: faintGrey,
                          child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(children: <Widget>[
                                  Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 15, 0, 10)),
                                  Text("      Special notes",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 10.0,
                                          fontFamily: "SourceSansProBold")),
                                ]),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0)),
                                Row(children: <Widget>[
                                  Text("     " + products[index].notes,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14.0,
                                          fontFamily: "SourceSansProRegular")),
                                ]),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5)),
                              ]),
                        ),
                      Divider(color: greyText)
                    ]),
              ],
            ),
          );
        });

    // return listView;
    return Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0), child: listView);
  }

  Widget spaceBanner(BuildContext context) {
    return Padding(padding: EdgeInsets.fromLTRB(20, 5, 20, 20));
  }

  Widget smallSpaceBanner(BuildContext context) {
    return Padding(padding: EdgeInsets.fromLTRB(10, 5, 10, 5));
  }

  Widget priceDetails(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(children: <Widget>[
                        Expanded(
                          child: LeftRightAlign(
                              left: Text("Subtotal",
                                  style: TextStyle(
                                      color: greyText,
                                      fontSize: 16.0,
                                      fontFamily: "SourceSansProRegular")),
                              right: Text(
                                  order.amount.subTotal.getDisplayValue(),
                                  style: TextStyle(
                                      color: greyText,
                                      fontSize: 16.0,
                                      fontFamily: "SourceSansProRegular"))),
                        )
                      ])
                    ]),
                Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
                if (order.promoCode != null && order.promoCode.isNotEmpty)
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(children: <Widget>[
                          Expanded(
                            child: LeftRightAlign(
                                left: Text("Promocode",
                                    style: TextStyle(
                                        color: greyText,
                                        fontSize: 16.0,
                                        fontFamily: "SourceSansProRegular")),
                                right: Text(
                                    getAmountDisplayValue(
                                        order.amount.subTotal.amountV1),
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16.0,
                                        fontFamily: "SourceSansProRegular"))),
                          )
                        ])
                      ]),
                if (order.amount.deliveryFee != null &&
                    order.amount.deliveryFee.amountV1 != null)
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(children: <Widget>[
                          Expanded(
                            child: LeftRightAlign(
                                left: Text("Delivery fee",
                                    style: TextStyle(
                                        color: greyText,
                                        fontSize: 16.0,
                                        fontFamily: "SourceSansProRegular")),
                                right: Text(
                                    order.amount.deliveryFee.getDisplayValue(),
                                    style: TextStyle(
                                        color: greyText,
                                        fontSize: 16.0,
                                        fontFamily: "SourceSansProRegular"))),
                          )
                        ])
                      ]),
                Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(children: <Widget>[
                        Expanded(
                          child: LeftRightAlign(
                              left: Text("GST ",
                                  style: TextStyle(
                                      color: greyText,
                                      fontSize: 16.0,
                                      fontFamily: "SourceSansProRegular")),
                              right: Text(order.amount.gst.getDisplayValue(),
                                  style: TextStyle(
                                      color: greyText,
                                      fontSize: 16.0,
                                      fontFamily: "SourceSansProRegular"))),
                        )
                      ])
                    ]),
                Divider(color: greyText),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(children: <Widget>[
                        Expanded(
                          child: LeftRightAlign(
                              left: Text("Total ",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontFamily: "SourceSansProBold")),
                              right: Text(order.amount.total.getDisplayValue(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontFamily: "SourceSansProBold"))),
                        )
                      ])
                    ]),
              ]),
          Padding(padding: EdgeInsets.fromLTRB(20, 5, 20, 20)),
        ],
      ),
    );
  }

  String getAmountDisplayValue(var amount) {
    return "\$$amount";
  }

  Widget contactDetails(BuildContext context) {
    return ListTile(
      //contentPadding: EdgeInsets.all(<some value here>),//change for side padding
      title: Row(
        children: <Widget>[
          Expanded(
              child: RaisedButton(
                  color: Colors.white,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  onPressed: () {
                    events.mixpanel.track(Events.TAP_ORDER_DETAILS_CONTACT);
                    events.mixpanel.flush();
                    _newTaskModalBottomSheet(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ImageIcon(AssetImage('assets/images/icon_phone.png'),
                          color: buttonBlue),
                      Text(
                        ' Contact',
                        style: TextStyle(
                            color: buttonBlue,
                            fontSize: 16.0,
                            fontFamily: "SourceSansProSemiBold"),
                      ),
                    ],
                  ))),
          Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
          Expanded(
              child: RaisedButton(
                  color: Colors.white,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  onPressed: () {
                    events.mixpanel.track(Events.TAP_ORDER_DETAILS_VIEW_AS_PDF);
                    events.mixpanel.flush();
                    openPdf(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ImageIcon(AssetImage('assets/images/icon_view_pdf.png'),
                          color: buttonBlue),
                      Text(
                        ' View as PDF',
                        style: TextStyle(
                            color: buttonBlue,
                            fontSize: 16.0,
                            fontFamily: "SourceSansProSemiBold"),
                      ),
                    ],
                  )))
        ],
      ),
    );
  }

  openPdf(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewContainer(order.pdfURL, "")));
  }

  void _newTaskModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                if (order.outlet.company.email != null &&
                    order.outlet.company.email.isNotEmpty)
                  new ListTile(
                      leading: new Icon(Icons.email),
                      title: new Text(order.outlet.company.email),
                      onTap: () => {
                            Clipboard.setData(new ClipboardData(
                                text: order.outlet.company.email))
                          }),
                if (order.outlet.company.phone != null &&
                    order.outlet.company.phone.isNotEmpty)
                  new ListTile(
                    leading: new Icon(Icons.phone),
                    title: new Text(order.outlet.company.phone),
                    onTap: () => {
                      Clipboard.setData(
                          new ClipboardData(text: order.outlet.company.phone))
                    },
                  ),
                Padding(padding: EdgeInsets.fromLTRB(20, 5, 20, 20)),
              ],
            ),
          );
        });
  }

  void _moreActionBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Padding(padding: EdgeInsets.fromLTRB(15, 5, 0, 0)),
                new Text("More options",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "SourceSansProSemiBold",
                        fontSize: 14)),

                // new Text("More options", style: TextStyle(
                //     color: Colors.black, fontFamily: "SourceSansProSemiBold", fontSize: 14)),
                new ListTile(
                  title: new Text("Activity history",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "SourceSansProRegular",
                          fontSize: 16)),
                  onTap: () =>
                      {Navigator.pop(context), moveToOrderActivityPage(order)},
                ),
              ],
            ),
          );
        });
  }

  moveToOrderActivityPage(Orders element) {
    events.mixpanel.track(Events.TAP_ORDER_DETAILS_ACTIVITY_HISTORY);
    events.mixpanel.flush();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new OrderActivityPage(element.orderId)));
  }
}

class LeftRightAlign extends MultiChildRenderObjectWidget {
  LeftRightAlign({
    Key key,
    @required Widget left,
    @required Widget right,
  }) : super(key: key, children: [left, right]);

  @override
  RenderLeftRightAlign createRenderObject(BuildContext context) {
    return RenderLeftRightAlign();
  }
}

class LeftRightAlignParentData extends ContainerBoxParentData<RenderBox> {}

class RenderLeftRightAlign extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, LeftRightAlignParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, LeftRightAlignParentData> {
  RenderLeftRightAlign({
    List<RenderBox> children,
  }) {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! LeftRightAlignParentData)
      child.parentData = LeftRightAlignParentData();
  }

  @override
  void performLayout() {
    final BoxConstraints childConstraints = constraints.loosen();

    final RenderBox leftChild = firstChild;
    final RenderBox rightChild = lastChild;

    leftChild.layout(childConstraints, parentUsesSize: true);
    rightChild.layout(childConstraints, parentUsesSize: true);

    final LeftRightAlignParentData leftParentData = leftChild.parentData;
    final LeftRightAlignParentData rightParentData = rightChild.parentData;

    final bool wrapped =
        leftChild.size.width + rightChild.size.width > constraints.maxWidth;

    leftParentData.offset = Offset.zero;
    rightParentData.offset = Offset(
        constraints.maxWidth - rightChild.size.width,
        wrapped ? leftChild.size.height : 0);

    size = Size(
        constraints.maxWidth,
        wrapped
            ? leftChild.size.height + rightChild.size.height
            : math.max(leftChild.size.height, rightChild.size.height));
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
