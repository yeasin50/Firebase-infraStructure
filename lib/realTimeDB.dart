import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

// import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

int counter = 0;
DatabaseReference reference;
DatabaseError error;

void init(FirebaseDatabase database) async {
  reference = FirebaseDatabase.instance.reference().child("test/counter");

  // if any change occur effects the hole dataset and clients
  reference.keepSynced(true);

  database.setPersistenceEnabled(true);
  database.setPersistenceCacheSizeBytes(1000000);
  log("init RealTimeDB");
}

Future<int> getCounter() async {
  int val;
  await reference.once().then((DataSnapshot snapshot) {
    print("snap: " + snapshot.toString());
    val = snapshot.value;
  });
  return val;
}

Future<int> getCount() async {
  return await getCounter();
}

Future<Null> setCounter(int value) async {
  final TransactionResult result =
      await reference.runTransaction((MutableData mutableData) async {
    mutableData.value = value;
    return mutableData;
  });

  if (result.committed) {
    log("saved $value to database");
  } else {
    log("failed to save");
    if (result.error != null) {
      print(result.error.message);
    }
  }
}

void increment() async {
  int value = counter += 1;
  setCounter(value);
}

void decrement() async {
  int value = counter -= 1;
  setCounter(value);
}

Future<Null> addData(String text) async {
  DatabaseReference _ref;
  _ref = await FirebaseDatabase.instance.reference().child("messages/$text");

  for (int i = 0; i < 10; i++) {
    //mapping
    _ref.update(<String, String>{'key $i': 'val $i'});
  }
}

Future<Null> removeData(String text) async {
  DatabaseReference _ref;
  _ref = FirebaseDatabase.instance.reference().child("messages/$text");
  _ref.remove();
}

Future<Null> updateData(String text, String key, String value) async {
  DatabaseReference _ref;
  _ref = FirebaseDatabase.instance.reference().child("messages/$text");
  _ref.update(<String, String>{key: value});
}

// set remove everything and set just this one
Future<Null> setData(String text, String key, String value) async {
  DatabaseReference _ref;
  _ref = FirebaseDatabase.instance.reference().child("messages/$text");
  _ref.set(<String, String>{key: value});
}

Future<String> findData(String user, String key) async {
  DatabaseReference reference =
      FirebaseDatabase.instance.reference().child("messages/$user");

  String value;
  Query query = reference.equalTo(value, key: key);
  await query.once().then((dataSnapshot) {
    value = dataSnapshot.value.toString();
  });

  return value;
}

Future<String> findRange(String user, String key) async {
  DatabaseReference _messageRef;
  _messageRef = FirebaseDatabase.instance.reference().child('messages/${user}');
  String value;
  Query query = _messageRef.endAt(value, key: key);
  await query.once().then((DataSnapshot snapshot) {
    value = snapshot.value.toString();
  });

  return value;
}

//separate Keys and values
Future<Null> separateKEY() async {
  DatabaseReference reference =
      FirebaseDatabase.instance.reference().child("messages/user/");
// FIXME:: get separated keys and values 👿👿👿

  await reference.once().then((DataSnapshot snapshot) {
    log(snapshot.value.keys[1].toString());
  });

  // Map<dynamic, dynamic> json = jsonDecode(key);
  log("runTime>> ${json.runtimeType}");
}

// Returns a Pro created from JSON

class Pro {
  String uid, email;
  Pro();
  factory Pro.fromJson(Map<String, dynamic> json) {
    Pro pro = Pro();

    pro.uid = json['uid'];
    pro.email = json['email'];
  }
}
