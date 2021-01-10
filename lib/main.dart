import 'dart:developer';
import 'package:FirebaseApp/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  String _status = "Perform Action> ";

  //Google SignIn, set value on initState
  GoogleSignInAccount _currentUser;
  @override
  void initState() {
    super.initState();

    ///` we just have to call this once ` used for firebase
    Firebase.initializeApp().whenComplete(() {
      print("Completed");
      setState(() {});
    });

    //Google SignIn
    googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount account) async {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        String userName = await handleGetContact(_currentUser);
        log("User: $userName");
        setState(() {
          _status = userName;
        });
      }
    });
  }

  ///` Google SignIn`
  Future<void> _handleGoogleSignIn() async {
    log("Google SignIn......");
    try {
      await googleSignIn.signIn();
    } catch (error) {
      log(error.toString());
    }
    log("end of Google SignIn......");
  }

  ///` Google SignOut`
  Future<void> _handleGoogleSignOut() async {
    setState(() => _status = "SignOut....😥");
    await googleSignIn.disconnect();
    setState(() => _status = "Sign Out🙄");
  }

  ///`SignOut`
  void _signOut() async {
    setState(() => _status = "signing out....");
    await auth.signOut();

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
                  onPressed: signInAnon,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: EdgeInsets.all(4),
                  onPressed: _handleGoogleSignIn,
                  child: Text("Google SignIn"),
                ),
                SizedBox(
                  width: 10,
                ),
                RaisedButton(
                  onPressed: _handleGoogleSignOut,
                  child: Text("Google Sign out"),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: EdgeInsets.all(4),
                  onPressed: null,
                  child: Text("Up load text"),
                ),
                SizedBox(
                  width: 10,
                ),
                RaisedButton(
                  onPressed: null,
                  child: Text("Download Text"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
