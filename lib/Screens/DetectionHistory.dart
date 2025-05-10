import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting dates

class DetectionHistory extends StatefulWidget {
  const DetectionHistory({super.key});

  @override
  _DetectionHistoryState createState() => _DetectionHistoryState();
}

class _DetectionHistoryState extends State<DetectionHistory> {
  late Future<Map<String, dynamic>> _dataFuture;
  bool _sortAscending = false; // false = newest first (descending), true = oldest first (ascending)
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  // Function to fetch user data and results from Firestore
  Future<Map<String, dynamic>> _fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Fetch user data
    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      throw Exception('User data not found');
    }

    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    // Fetch results for the user with optional date filtering
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Results')
        .where('userId', isEqualTo: user.uid);

    // Apply date filters if selected
    if (_startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!));
    }
    if (_endDate != null) {
      // Add one day to _endDate to include results on the end date
      DateTime endDateInclusive = _endDate!.add(const Duration(days: 1));
      query = query.where('timestamp', isLessThan: Timestamp.fromDate(endDateInclusive));
    }

    // Apply sorting
    query = query.orderBy('timestamp', descending: !_sortAscending);

    QuerySnapshot resultsSnapshot = await query.get();

    List<Map<String, dynamic>> results = resultsSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    return {
      'userData': userData,
      'results': results,
    };
  }

  // Function to group results by sessionId (one session per image)
  Map<String, List<Map<String, dynamic>>> _groupResultsBySession(
      List<Map<String, dynamic>> results) {
    Map<String, List<Map<String, dynamic>>> groupedResults = {};

    for (var result in results) {
      String sessionId = result['sessionId']?.toString() ?? 'Unknown';
      if (!groupedResults.containsKey(sessionId)) {
        groupedResults[sessionId] = [];
      }
      groupedResults[sessionId]!.add(result);
    }

    // Debug: Print the grouped results to verify
    print('Grouped Results:');
    groupedResults.forEach((sessionId, sessionResults) {
      print('Session ID: $sessionId, Results: $sessionResults');
    });

    return groupedResults;
  }

  // Function to format allergen results for a session
  String _formatAllergenResults(List<Map<String, dynamic>> sessionResults) {
    if (sessionResults.isEmpty) {
      return 'No allergens detected.';
    }

    List<String> allergenEntries = [];
    for (var result in sessionResults) {
      String allergen = result['Class'] ?? 'Unknown';
      double confidence = (result['Confidence'] as num?)?.toDouble() ?? 0.0;
      allergenEntries.add('$allergen (${(confidence * 100).toStringAsFixed(1)}%)');
    }
    return allergenEntries.join('\n');
  }

  // Function to format timestamp
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  // Function to format date range for display
  String _formatDateRange() {
    if (_startDate == null || _endDate == null) return '';
    return '${DateFormat('yyyy-MM-dd').format(_startDate!)} - ${DateFormat('yyyy-MM-dd').format(_endDate!)}';
  }

  // Function to delete results for a specific image (session)
  Future<void> _deleteImageResults(String sessionId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    QuerySnapshot sessionDocs = await FirebaseFirestore.instance
        .collection('Results')
        .where('userId', isEqualTo: user.uid)
        .where('sessionId', isEqualTo: sessionId)
        .get();

    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in sessionDocs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // Refresh the data after deletion
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  // Function to show date picker and set start/end date
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _dataFuture = _fetchData(); // Refresh data with new date range
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Detection History'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Filter by Date',
          ),
          IconButton(
            icon: Icon(_sortAscending ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
                _dataFuture = _fetchData();
              });
            },
            tooltip: _sortAscending ? 'Sort Newest First' : 'Sort Oldest First',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _dataFuture = _fetchData();
              });
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          }

          final data = snapshot.data!;
          final userData = data['userData'] as Map<String, dynamic>;
          final results = data['results'] as List<Map<String, dynamic>>;

          // Extract user information
          String name = userData['username'] ?? 'N/A';

          // Group results by session (one session per image)
          Map<String, List<Map<String, dynamic>>> groupedResults =
          _groupResultsBySession(results);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Food Allergy Test Report',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Table(
                    border: TableBorder.all(color: Colors.black12),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1)),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Patient Information',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(''),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Name'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(name),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Image Results',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (_startDate != null || _endDate != null) ...[
                        Text(
                          _formatDateRange(),
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                              _dataFuture = _fetchData();
                            });
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (groupedResults.isEmpty)
                    const Text(
                      'No images processed.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    )
                  else
                    ...groupedResults.entries.toList().asMap().entries.map((entry) {
                      int index = entry.key + 1; // Image number (1-based index)
                      String sessionId = entry.value.key;
                      List<Map<String, dynamic>> sessionResults = entry.value.value;
                      String dateOfTest = _formatTimestamp(
                          sessionResults.first['timestamp'] as Timestamp?);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Image $index',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Table(
                              border: TableBorder.all(color: Colors.black12),
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(3),
                              },
                              children: [
                                TableRow(
                                  decoration:
                                  BoxDecoration(color: Colors.orange.withOpacity(0.1)),
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Date of Test',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(dateOfTest),
                                    ),
                                  ],
                                ),
                                const TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Test Methodology'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Image-based Allergen Detection (Roboflow API)'),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Allergens Detected'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(_formatAllergenResults(sessionResults)),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Actions'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          await _deleteImageResults(sessionId);
                                        },
                                        tooltip: 'Delete Results',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}