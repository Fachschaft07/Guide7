import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guide7 Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSerifTC',
      ),
      home: MyHomePage(title: 'Guide7'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double imageWidth;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      imageWidth = size.width / 2;
    } else {
      imageWidth = size.width / 4;
    }

    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "res/images/guide7_logo.png",
            width: imageWidth,
          ),
          Container(
            child: Text(
              "Guide7",
              style: TextStyle(fontFamily: 'Raleway'),
              textScaleFactor: 4.0,
            ),
            padding: EdgeInsets.only(top: 20.0),
          ),
          Text("Eine App der Fachschaft 07")
        ],
      ),
    ));
  }
}
