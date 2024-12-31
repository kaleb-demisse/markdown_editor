import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:notes/style/app_style.dart';
import 'edit_note.dart'; // Import the EditNote screen

class NoteReader extends StatefulWidget {
  NoteReader(this.doc, {Key? key}) : super(key: key);
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
            icon: Icon(Icons.edit, color: Colors.black),
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
            icon: Icon(Icons.delete, color: Colors.black),
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
        padding: EdgeInsets.all(16.0), // Keep padding if needed
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

  // Confirmation Dialog
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
}
