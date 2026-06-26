import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'All';
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: const Text('UTM Paws-itive'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/notifications',
              );
            },
            icon: const Icon(Icons.notifications),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/profile',
                );
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/report',
          );
        },
        icon: const Icon(Icons.pets),
        label: const Text('Report Animal'),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back 👋',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Animal Reports',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search location or animal...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip('All'),
                _filterChip('Cat'),
                _filterChip('Unknown'),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .orderBy(
                    'createdAt',
                    descending: true,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final reports = snapshot.data!.docs;

                final filteredReports = reports.where((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>;

                  final animalType =
                      (data['animalType'] ?? '')
                          .toString();

                  final location =
                      (data['location'] ?? '')
                          .toString()
                          .toLowerCase();

                  final description =
                      (data['description'] ?? '')
                          .toString()
                          .toLowerCase();

                  final filterMatch =
                      selectedFilter == 'All'
                          ? true
                          : animalType ==
                              selectedFilter;

                  final searchMatch =
                      searchText.isEmpty ||
                          location.contains(
                            searchText,
                          ) ||
                          description.contains(
                            searchText,
                          );

                  return filterMatch &&
                      searchMatch;
                }).toList();

                if (filteredReports.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets,
                          size: 80,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No reports found',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final report =
                        filteredReports[index].data()
                            as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/animal-profile',
                          arguments:
                              filteredReports[index].id,
                        );
                      },
                      child: Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 16,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                                child:
                                    report['imageBase64'] !=
                                            null
                                        ? Image.memory(
                                            base64Decode(
                                              report[
                                                  'imageBase64'],
                                            ),
                                            width: 100,
                                            height: 100,
                                            fit:
                                                BoxFit.cover,
                                          )
                                        : Container(
                                            width: 100,
                                            height: 100,
                                            color:
                                                Colors.grey,
                                            child:
                                                const Icon(
                                              Icons.pets,
                                            ),
                                          ),
                              ),

                              const SizedBox(
                                  width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      report[
                                              'animalType'] ??
                                          'Unknown',
                                      style:
                                          const TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 8),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons
                                              .location_on,
                                          size: 16,
                                        ),
                                        const SizedBox(
                                            width: 4),
                                        Expanded(
                                          child: Text(
                                            report[
                                                    'location'] ??
                                                '',
                                            maxLines: 2,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                        height: 8),

                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color: AppTheme
                                            .primary
                                            .withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      child: Text(
                                        report[
                                                'healthStatus'] ??
                                            '',
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedFilter == label,
        onSelected: (_) {
          setState(() {
            selectedFilter = label;
          });
        },
      ),
    );
  }
}