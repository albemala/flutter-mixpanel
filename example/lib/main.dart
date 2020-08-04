import 'package:flutter/material.dart';
import 'package:fluttermixpanel/fluttermixpanel.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
    _sendEvents();
  }

  _sendEvents() async {
    final mixPanel = Mixpanel("<your token>");
    await mixPanel.initialize();

//    await mixPanel.track("track");
//    await mixPanel.trackJSON("json", '{"toto":"toto","titi":"titi"}');
    await mixPanel.trackMap("test_event", {
      "prop1": "test1",
      "prop2": "test2",
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Text('Hello world!'),
      ),
    );
  }
}
