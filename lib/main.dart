import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

FirebaseAuth _auth = FirebaseAuth.instance;

///`Google Sign In`
GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

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
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetContact();
      }
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

  /// `Google SignIn method will get the current account on device`
  Future<void> _handleGetContact() async {
    setState(() => _status = "Loading contact info.......");

    final http.Response response = await http.get(
      'https://people.googleapis.com/v1/people/me/connections'
      '?requestMask.includeField=person.names',
      headers: await _currentUser.authHeaders,
    );

    if (response.statusCode == 200) setState(() => _status = "Connecting.....");

    if (response.statusCode != 200) {
      setState(() {
        _status = "People API gave a ${response.statusCode} "
            "response. Check logs for details.";
      });
      log('People API ${response.statusCode} response: ${response.body}');
      return;
    }

    // user information
    final Map<String, dynamic> userData = jsonDecode(response.body);
    log(" user data: "+userData.toString());
    final String contactName = _pickFirstNameOfContact(userData);

    setState(() =>
        //  checking name availability
        _status = contactName != null
            ? "Hey $contactName"
            : "No contacts to Display.");
  }

  // Pick First Name form jsonData <= GoogleSignIn auth
  String _pickFirstNameOfContact(Map<String, dynamic> data) {
    final List<dynamic> connections = data['connections'];

    /// `.? null safety` https://dart.dev/null-safety
    /// double? d;
    ///print(d?.floor()); // Uses `?.` instead of `.` to invoke `floor()`.
    final Map<String, dynamic> contact = connections?.firstWhere(
      (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    );

    if (contact != null) {
      final Map<String, dynamic> name = contact['names'].firstWhere(
        (dynamic _name) => _name['displayName'] != null,
        orElse: () => null,
      );
      if (name != null) {
        return name['displayName'];
      }
    }
    return null;
  }

  ///` Google SignIn`
  Future<void> _handleGoogleSignIn() async {
    log("Google SignIn......");
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      log(error.toString());
    }
    log("end of Google SignIn......");
  }

  ///` Google SignOut`
  Future<void> _handleGoogleSignOut() {
    setState(() => _status = "SingOut..😥");
    _googleSignIn.disconnect();

    setState(() => _status = "Sign Out🙄");
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
          ],
        ),
      ),
    );
  }
}
