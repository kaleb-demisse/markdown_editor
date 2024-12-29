import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/style/app_style.dart';

class NoteEditor extends StatefulWidget {
  NoteEditor({Key? key}) : super(key: key);

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  int color = Random().nextInt(AppStyle.cardsColor.length);
  String date = DateTime.now().toLocal().toString().split(' ')[0];
  TextEditingController _titleController = TextEditingController();
  TextEditingController _mainController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.cardsColor[color],
      appBar: AppBar(
        backgroundColor: AppStyle.cardsColor[color],
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "New Note",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
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
              SizedBox(height: 5.0),
              Text(
                date,
                style: AppStyle.dateTitle,
              ),
              SizedBox(
                height: 20.0,
              ),
              TextField(
                controller: _mainController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Note content',
                ),
                style: AppStyle.mainContent,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyle.accentColor,
        onPressed: () async {
          final user = FirebaseAuth.instance.currentUser;
          FirebaseFirestore.instance.collection("notes").add({
            "title": _titleController.text,
            "date": date,
            "content": _mainController.text,
            "color": color,
            "userId": user?.uid, // Associate with the current user
          }).then((value) {
            print("Note ID: ${value.id}");
            Navigator.pop(context);
          }).catchError((error) {
            print("Failed to add new note: $error");
          });
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
