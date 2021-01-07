import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Firebase App'),
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
  String _status = "londing";

  @override
  void initState() {
    super.initState();

    /// we just have to call this once
    Firebase.initializeApp().whenComplete(() {
      print("Completed");
      setState(() {});
    });
  }

  /// `SignIn anonymously`
  void _signInAnon() async {
    setState(() => _status = "signing In......");

    var user = (await _auth.signInAnonymously()).user;

    if (user != null && user.isAnonymous == true)
      setState(() => _status = "Signed in Anonymously.");
    else
      setState(() => _status = "Failed to SignIn as Anonymously.");
  }

  ///`SignOut`
  void _signOut() async {
    setState(() => _status = "signing out....");
    await _auth.signOut();

    setState(() => _status = "sign Out!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 200,
              child: Text(_status),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: EdgeInsets.all(4),
                  onPressed: _signInAnon,
                  child: Text("SignIn Anon"),
                ),
                SizedBox(
                  width: 10,
                ),
                RaisedButton(
                  onPressed: _signOut,
                  child: Text("Sign off"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
