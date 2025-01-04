import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';
import 'package:notes/style/app_style.dart';
import 'home_screen.dart';

class EditNote extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  EditNote(this.doc, {Key? key}) : super(key: key);

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  late TextEditingController _titleController;
  late TextEditingController _mainController;
  late int color;

  @override
  void initState() {
    super.initState();
    color = widget.doc['color'];
    _titleController = TextEditingController(text: widget.doc['title']);
    _mainController = TextEditingController(text: widget.doc['content']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.cardsColor[color],
      appBar: AppBar(
        backgroundColor: AppStyle.cardsColor[color],
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Edit Note",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Note Title',
                ),
                style: AppStyle.mainTitle,
              ),
              SizedBox(height: 8.0),
              Text(
                widget.doc['date'],
                style: AppStyle.dateTitle,
              ),
              SizedBox(height: 28.0),
              MarkdownAutoPreview(
                controller: _mainController,
                enableToolBar: true,
                emojiConvert: true,
                maxLines: null,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final user = FirebaseAuth.instance.currentUser;
          if (widget.doc['userId'] == user?.uid) {
            FirebaseFirestore.instance
                .collection("notes")
                .doc(widget.doc.id)
                .update({
              "title": _titleController.text,
              "content": _mainController.text,
              "color": color,
            }).then((value) {
              print("Note updated successfully");

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            }).catchError((error) {
              print("Failed to update note: $error");
            });
          } else {
            print("User not authorized to edit this note");
          }
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
