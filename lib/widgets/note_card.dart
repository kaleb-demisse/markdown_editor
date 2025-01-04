import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:notes/style/app_style.dart';

Widget noteCard(Function()? onTap, QueryDocumentSnapshot doc) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppStyle.cardsColor[doc['color']],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            doc['title'],
            style: AppStyle.mainTitle,
          ),
          const SizedBox(
            height: 4.0,
          ),
          Text(
            doc['date'],
            style: AppStyle.dateTitle,
          ),
          const SizedBox(
            height: 8.0,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: MarkdownBody(
                data: doc['content'],
                styleSheet: MarkdownStyleSheet(
                  p: AppStyle.mainContent,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
