import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'package:FirebaseApp/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:image_picker/image_picker.dart';

import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:path/path.dart';

import 'uploadTaskList.dart';

/// Enum representing the upload task types the example app supports.
enum UploadType {
  /// Uploads a randomly generated string (as a file) to Storage.
  string,

  /// Uploads a file from the device.
  file,

  /// Clears any tasks from the list.
  /// next day
  clear,
}

class TaskManager extends StatefulWidget {
  TaskManager({Key key}) : super(key: key);

  @override
  _TaskManagerState createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  List<firebase_storage.UploadTask> _uploadTask = [];

  /// pickedFile from ImagePicker package
  Future<firebase_storage.UploadTask> uploadFile(PickedFile file) async {
    if (file == null) {
      log("no file :(");
      return null;
    }

    firebase_storage.UploadTask uploadTask;

    // getting file name
    String baseName = basename(file.path);

    // Create a Reference to the file
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child("test")
        .child(baseName);

    final metaData = firebase_storage.SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'file-path': file.path},
    );

    /// flutter foundation package provides
    /// There is a `global boolean kIsWeb` which can tell you whether or not the app was compiled to run on the web.
    if (kIsWeb) {
      //if in web
      uploadTask = ref.putData(await file.readAsBytes(), metaData);
    } else {
      uploadTask = ref.putFile(File(file.path), metaData);
    }

    return Future.value(uploadTask);
  }

  /// Handles the user pressing the PopupMenuItem item.
  void handleUploadType(UploadType type) async {
    switch (type) {
      case UploadType.string:
        setState(() {
          _uploadTask = [..._uploadTask, uploadString()];
        });
        break;

      case UploadType.file:
        PickedFile file =
            await ImagePicker().getImage(source: ImageSource.gallery);
        firebase_storage.UploadTask task = await uploadFile(file);

        if (task != null) {
          setState(() {
            _uploadTask = [..._uploadTask, task];
          });
        }
        break;

      case UploadType.clear:
        setState(() {
          _uploadTask = [];
        });
        break;
    }
  }

  _removeTaskAtIndex(int index) {
    setState(() {
      _uploadTask = _uploadTask..removeAt(index);
    });
  }

  Future<void> _downloadBytes(firebase_storage.Reference ref) async {
    final bytes = await ref.getData();

    //Download...
    await ImageGallerySaver.saveImage(bytes);
  }

  Future<void> _downloadLink(firebase_storage.Reference ref) async {
    final link = await ref.getDownloadURL();

    await Clipboard.setData(ClipboardData(
      text: link,
    ));
    log("link:: " + link);
  }

  Future<void> _downloadFile(firebase_storage.Reference ref) async {
    final Directory sysTempDir = Directory.systemTemp;
    final File tempFile = File('${sysTempDir.path}/temp-${ref.name}');

    if (tempFile.existsSync()) await tempFile.delete();

    await ref.writeToFile(tempFile);

    log('Success!\n Downloaded ${ref.name} \n from bucket: ${ref.bucket}\n '
        'at path: ${ref.fullPath} \n'
        'Wrote "${ref.fullPath}" to tmp-${ref.name}.txt');
  }

// Testing uploading without auth
  void uploadText() {
    var text = uploadString();
    print(text.runtimeType);
    print(text.toString());
    log("snapShot: " + text.snapshot.toString());
  }

//upload String Text maker..
  firebase_storage.UploadTask uploadString() {
    const String putStringText =
        "hey amigo, test file Uploadinggggggggggggggggggggg :)";

    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child("test")
        .child("/string-example.txt");

    /// metaData for fbase console review 😶
    return ref.putString(putStringText,
        metadata: firebase_storage.SettableMetadata(
            contentLanguage: 'en',
            customMetadata: <String, String>{"example": 'putString'}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            PopupMenuButton<UploadType>(
                onSelected: handleUploadType,
                icon: Icon(Icons.add),
                itemBuilder: (context) => [
                      const PopupMenuItem(
                          child: Text("Upload string"),
                          value: UploadType.string),
                      const PopupMenuItem(
                          child: Text("Upload local file"),
                          value: UploadType.file),
                      const PopupMenuItem(
                          child: Text("Upload local file"),
                          value: UploadType.file),
                      if (_uploadTask.isNotEmpty)
                        PopupMenuItem(
                            child: Text("Clear list"), value: UploadType.clear)
                    ])
          ],
        ),
        body: _uploadTask.isEmpty
            ? Center(child: Text("Press the '+' button to add a new file."))
            : ListView.builder(
                itemCount: _uploadTask.length,
                itemBuilder: (context, index) => UploadTaskListTile(
                    task: _uploadTask[index],
                    onDismissed: () => _removeTaskAtIndex(index),
                    onDownloadLink: () {
                      return _downloadLink(_uploadTask[index].snapshot.ref);
                    },
                    onDownload: () {
                      if (kIsWeb) {
                        return _downloadBytes(_uploadTask[index].snapshot.ref);
                      } else {
                        return _downloadFile(_uploadTask[index].snapshot.ref);
                      }
                    })));
  }
}
