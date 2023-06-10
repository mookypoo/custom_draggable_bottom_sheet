import 'package:flutter/material.dart';

import 'custom_bottom_sheet.dart';

void main() => runApp(const Main());

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final Widget _header = Container(
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 6.0, bottom: 8.0),
          width: 40.0, // 10.w
          height: 6.5, // 0.8.h
          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(50)),
        ),
        Text("Drag the header to see bottom sheet"),
      ],
    ),
  );

  Widget _listItem(String text) => Container(
    width: double.infinity,
    height: 40.0,
    alignment: Alignment.center,
    child: Text(text),
  );

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(height: _size.height,),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: CustomBottomSheet(
              maxHeight: _size.height * 0.745,
              headerHeight: 50.0,
              header: this._header,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
              boxShadow: <BoxShadow>[
                BoxShadow(color: Colors.black26, blurRadius: 10.0, spreadRadius: -1.0, offset: Offset(0.0, 3.0)),
                BoxShadow(color: Colors.black26, blurRadius: 4.0, spreadRadius: -1.0, offset: Offset(0.0, 0.0)),
              ],
              // body: Container(
              //   decoration: const BoxDecoration(
              //     border: Border(top: BorderSide(color: Colors.grey, width: 1.0)),
              //   ),
              //   width: _size.width,
              //   alignment: Alignment.center,
              //   height: _size.height * 0.6,
              //   child: Text("body")
              // ),
              children: List.generate(30, (int index) => this._listItem("list item $index")),
            ),
          )
        ],
      ),
    );
  }
}
