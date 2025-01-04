import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:notes/style/app_style.dart';
import 'package:permission_handler/permission_handler.dart';
import 'edit_note.dart';

class NoteReader extends StatefulWidget {
  const NoteReader(this.doc, {super.key});
  final QueryDocumentSnapshot doc;

  @override
  State<NoteReader> createState() => _NoteReaderState();
}

class _NoteReaderState extends State<NoteReader> {
  @override
  Widget build(BuildContext context) {
    int color = widget.doc['color'];

    return Scaffold(
      backgroundColor: AppStyle.cardsColor[color],
      appBar: AppBar(
        backgroundColor: AppStyle.cardsColor[color],
        elevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.black),
            onPressed: () {
              exportMarkdownFile();
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNote(widget.doc),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () async {
              bool confirm = await _showDeleteConfirmationDialog(context);
              if (confirm) {
                FirebaseFirestore.instance
                    .collection("notes")
                    .doc(widget.doc.id)
                    .delete()
                    .then((value) {
                  Navigator.pop(context);
                }).catchError((error) {
                  print("Failed to delete the note: $error");
                });
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            widget.doc['title'],
            style: AppStyle.mainTitle,
          ),
          const SizedBox(
            height: 4.0,
          ),
          Text(
            widget.doc['date'],
            style: AppStyle.dateTitle,
          ),
          const SizedBox(
            height: 28.0,
          ),
          MarkdownBody(
            data: widget.doc['content'],
            styleSheet: MarkdownStyleSheet(
              p: AppStyle.mainContent,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Note"),
          content: const Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> exportMarkdownFile() async {
    PermissionStatus status;
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 30) {
        status = await Permission.manageExternalStorage.request();
      } else {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.storage.request();
    }
    if (status.isGranted) {
      try {
        String title = widget.doc['title'];
        String content = widget.doc['content'];

        String markdownContent = content;

        String? directory = await FilePicker.platform.getDirectoryPath();

        final path = '${directory}/$title.md';

        final file = File(path);
        await file.writeAsString(markdownContent);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note exported to $path')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting note: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
    }
  }
}
