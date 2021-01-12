
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class UploadTaskListTile extends StatelessWidget {
  // ignore: public_member_api_docs
  const UploadTaskListTile(
      {Key key,
      this.task,
      this.onDismissed,
      this.onDownload,
      this.onDownloadLink})
      : super(key: key);

  /// The [UploadTask].
  final firebase_storage.UploadTask /*!*/ task;

  /// Triggered when the user dismisses the task from the list.
  final VoidCallback /*!*/ onDismissed;

  /// Triggered when the user presses the download button on a completed upload task.
  final VoidCallback /*!*/ onDownload;

  /// Triggered when the user presses the "link" button on a completed upload task.
  final VoidCallback /*!*/ onDownloadLink;

  /// Displays the current transferred bytes of the task.
  String _bytesTransferred(firebase_storage.TaskSnapshot snapshot) {
    return '${snapshot.bytesTransferred}/${snapshot.totalBytes}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_storage.TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (BuildContext context,
            AsyncSnapshot<firebase_storage.TaskSnapshot> asyncSnapshot) {
          Widget subtitle = Text('---');
          firebase_storage.TaskSnapshot snapshot = asyncSnapshot.data;
          firebase_storage.TaskState state = snapshot?.state;

          if (asyncSnapshot.hasError) {
            if (asyncSnapshot.error is firebase_core.FirebaseException &&
                (asyncSnapshot.error as firebase_core.FirebaseException).code ==
                    'canceled') {
              subtitle = Text('Upload canceled.');
            } else {
              print(asyncSnapshot.error);
              subtitle = Text('Something went wrong.');
            }
          } else if (snapshot != null) {
            subtitle =
                Text('${state}: ${_bytesTransferred(snapshot)} bytes sent');
          }

          return Dismissible(
            key: Key(task.hashCode.toString()),
            onDismissed: ($) => onDismissed(),
            child: ListTile(
              title: Text('Upload Task #${task.hashCode}'),
              subtitle: subtitle,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (state == firebase_storage.TaskState.running)
                    IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: () => task.pause(),
                    ),
                  if (state == firebase_storage.TaskState.running)
                    IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () => task.cancel(),
                    ),
                  if (state == firebase_storage.TaskState.paused)
                    IconButton(
                      icon: Icon(Icons.file_upload),
                      onPressed: () => task.resume(),
                    ),
                  if (state == firebase_storage.TaskState.success)
                    IconButton(
                      icon: Icon(Icons.file_download),
                      onPressed: () => onDownload(),
                    ),
                  if (state == firebase_storage.TaskState.success)
                    IconButton(
                      icon: Icon(Icons.link),
                      onPressed: () => onDownloadLink(),
                    ),
                ],
              ),
            ),
          );
        });
  }
}