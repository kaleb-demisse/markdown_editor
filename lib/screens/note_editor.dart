import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/style/app_style.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

class NoteEditor extends StatefulWidget {
  const NoteEditor({Key? key}) : super(key: key);

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final int color = Random().nextInt(AppStyle.cardsColor.length);
  final String date = DateTime.now().toLocal().toString().split(' ')[0];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _saveNote() async {
    final user = FirebaseAuth.instance.currentUser;

    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Title and content cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final docRef = await FirebaseFirestore.instance.collection("notes").add({
        "title": _titleController.text.trim(),
        "date": date,
        "content": _contentController.text,
        "color": color,
        "userId": user?.uid,
      });
      print("Note saved with ID: ${docRef.id}");
      Navigator.pop(context);
    } catch (error) {
      print("Failed to save note: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save note. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.cardsColor[color],
      appBar: AppBar(
        backgroundColor: AppStyle.cardsColor[color],
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "New Note",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Note Title',
            ),
            style: AppStyle.mainTitle,
            maxLines: 2,
          ),
          const SizedBox(height: 10.0),
          Text(
            date,
            style: AppStyle.dateTitle,
          ),
          const SizedBox(height: 20.0),
          MarkdownAutoPreview(
            controller: _contentController,
            enableToolBar: true,
            emojiConvert: true,
            maxLines: null,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveNote,
        child: const Icon(Icons.save),
      ),
    );
  }
}
