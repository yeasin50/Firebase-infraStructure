import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

FirebaseAuth auth = FirebaseAuth.instance;

//ensure logIn before operation
Future<bool> ensureLoggedIn() async {
  var user = await auth.currentUser;
  return user != null;
}

///`Google Sign In`
GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

/// `SignIn anonymously`
Future<bool> signInAnon() async {
  log("signing In......");

  var user = (await auth.signInAnonymously()).user;

  if (user != null && user.isAnonymous == true) {
    log("Signed in Anonymously.");
    return true;
  } else {
    log("Failed to SignIn as Anonymously.");
    return false;
  }
}

/// `Google SignIn method will get the current account on device`
Future<String> handleGetContact(currentUser) async {
  log("Loading contact info.......");
  //Google SignIn, set value on initState

  final http.Response response = await http.get(
    'https://people.googleapis.com/v1/people/me/connections'
    '?requestMask.includeField=person.names',
    headers: await currentUser.authHeaders,
  );

  if (response.statusCode != 200) {
    log("People API gave a ${response.statusCode} "
        "response. Check logs for details.");

    return ('People API ${response.statusCode} response: ${response.body}');
  }

  // user information
  final Map<String, dynamic> userData = jsonDecode(response.body);
  log(" user data: " + userData.toString());
  final String contactName = _pickFirstNameOfContact(userData);

  //  checking name availability
  return contactName != null ? "Hey $contactName" : "No contacts to Display.";
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
