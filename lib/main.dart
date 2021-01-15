import 'dart:developer';
import 'package:FirebaseApp/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'realTimeDB.dart';

void main() async {
  //TODO:: init db, storage and firebaseOption or initState
  WidgetsFlutterBinding.ensureInitialized();
  // from jnson and consol +=setting>> cloud>> sender id
  final FirebaseApp app = await Firebase.initializeApp(
          options: FirebaseOptions(
              projectId: "fir-app-95ec5",
              appId: "1:745651411956:android:8cf9b4ed4ef86142d2f7a1",
              apiKey: "AIzaSyDZUrmLGnQMxu7PlLy7dMva1tS1Y2ygO8I",
              databaseURL: "https://fir-app-95ec5-default-rtdb.firebaseio.com/",
              messagingSenderId: "745651411956"))
      .whenComplete(() => log("main Completed"));

  final FirebaseDatabase database = FirebaseDatabase(app: app);
  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  MyApp({this.database});
  final FirebaseDatabase database;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Firebase App', database: database),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final FirebaseDatabase database;
  MyHomePage({Key key, this.title, this.database}) : super(key: key);

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
    //  Future<FirebaseApp> app=  Firebase.initializeApp(
    //     options: FirebaseOptions(
    //       databaseURL: "https://fir-app-95ec5-default-rtdb.firebaseio.com/"
    //     )
    //   ).whenComplete(() {
    //     print("Completed");
    //     setState(() {});
    //   });

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

    ///`init RealTimeDB` from rdb file
    init(widget.database);
    reference.onValue.listen((event) {
      setState(() {
        error = null;
        counter = event.snapshot.value ?? 0;
      });
    }, onError: (e) {
      final DatabaseError er = e;
      setState(() {
        error = er;
      });
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
      body: builAuthentication(),
      // body: TaskManager(),
    );
  }

  Center builAuthentication() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 200,
            child: Text("$counter"),
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
                onPressed: () async {
                  var loggedIn = await ensureLoggedIn();
                  log(loggedIn.toString());
                },
                child: Text("ensure loggedIN"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                padding: EdgeInsets.all(4),
                onPressed: increment,
                child: Text("Increment"),
              ),
              SizedBox(
                width: 10,
              ),
              RaisedButton(
                onPressed: decrement,
                child: Text("Decrement"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                padding: EdgeInsets.all(4),
                onPressed: () {
                  addData("user");
                },
                child: Text("Add data"),
              ),
              SizedBox(
                width: 10,
              ),
              RaisedButton(
                onPressed: () {
                  removeData("user");
                },
                child: Text("removeData"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                padding: EdgeInsets.all(4),
                onPressed: () {
                  setData("user", "key 2", "value set");
                },
                child: Text("Set Data"),
              ),
              SizedBox(
                width: 10,
              ),
              RaisedButton(
                onPressed: () {
                  updateData("user", "key 2", "val updated");
                },
                child: Text("Update Data"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                padding: EdgeInsets.all(4),
                onPressed: () async {
                  String data = await findData("user", "key 2");
                  log("data $data");
                },
                child: Text("Find Data"),
              ),
              SizedBox(
                width: 10,
              ),
              RaisedButton(
                onPressed: () async {
                  String value = await findRange("user", "key 2");
                  log("value $value");
                },
                child: Text("Find DataRange"),
              ),
            ],
          ),
          RaisedButton(
            onPressed: separateKEY,
            child: Text("Separate keys and Vals"),
          ),
        ],
      ),
    );
  }
}
