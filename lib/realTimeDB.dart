import 'dart:async';
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

Future<int> getCount() async{
  return  await getCounter();
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
