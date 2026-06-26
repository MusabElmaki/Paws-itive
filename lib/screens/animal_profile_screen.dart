import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AnimalProfileScreen extends StatelessWidget {
  const AnimalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportId =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('reports')
            .doc(reportId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.data!.exists) {
            return const Center(
              child: Text('Report not found'),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (data['imageBase64'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(
                    base64Decode(data['imageBase64']),
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if ((data['catName'] ?? '').toString().isNotEmpty)
                        _item(
                          'Name',
                          data['catName'],
                        ),
                      _item(
                        'Animal Type',
                        data['animalType'] ?? '',
                      ),
                      _item(
                        'Domestic / Stray',
                        data['ownership'] ?? 'Unknown',
                      ),
                      _item(
                        'Health Status',
                        data['healthStatus'] ?? '',
                      ),
                      _item(
                        'Location',
                        data['location'] ?? '',
                      ),
                      _item(
                        'Description',
                        data['description'] ?? '',
                      ),
                      _item(
                        'Status',
                        data['status'] ?? '',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _item(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}