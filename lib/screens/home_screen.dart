import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/screens/note_editor.dart';
import 'package:notes/screens/note_reader.dart';
import 'package:notes/screens/profile.dart';
import 'package:notes/style/app_style.dart';
import 'package:notes/widgets/note_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> importMarkdownFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        String mid = file.path.split('/').last;
        String title = mid.split('.')[0];
        String date = DateTime.now().toLocal().toString().split(' ')[0];
        String content = await file.readAsString();
        int color = Random().nextInt(AppStyle.cardsColor.length);

        try {
          final docRef =
              await FirebaseFirestore.instance.collection("notes").add({
            "title": title.trim(),
            "date": date,
            "content": content.trim(),
            "color": color,
            "userId": user?.uid,
          });
          print("Note saved with ID: ${docRef.id}");
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
    } catch (e) {
      print('Error importing file: $e');
    }
  }

  void _showMarkdownPopup(String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Markdown Content'),
          content: SizedBox(
            height: 300,
            width: 400,
            child: Markdown(
              data: content,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(fontSize: 14),
                h1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.mainColor,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("Markdown Editor"),
        centerTitle: true,
        backgroundColor: AppStyle.mainColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Import',
            onPressed: () {
              importMarkdownFile();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Profile(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your Notes",
                style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                )),
            const SizedBox(height: 20.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("notes")
                    .where("userId", isEqualTo: user?.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    return GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                      children: snapshot.data!.docs
                          .map((note) => noteCard(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NoteReader(note),
                                  ),
                                );
                              }, note))
                          .toList(),
                    );
                  }
                  return Text(
                    "No notes found",
                    style: GoogleFonts.nunito(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 15.0,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditor(),
            ),
          );
        },
        label: const Text("Add Note"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
