import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/poll_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User _user;
  bool _isLoading = true;
  List<Map<String, dynamic>> _previousPolls = [];
  List<Map<String, dynamic>> _upcomingPolls = [];
  List<Map<String, dynamic>> _activePolls = [];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _fetchPollsData();
  }

  Future<void> _fetchPollsData() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final pollsSnapshot =
        await FirebaseFirestore.instance.collection('polls').get();

    // Categorize polls based on the date
    final currentDate = DateTime.now();
    List<Map<String, dynamic>> active = [];
    List<Map<String, dynamic>> upcoming = [];
    List<Map<String, dynamic>> previous = [];

    for (var doc in pollsSnapshot.docs) {
      final pollData = doc.data();
      final startDate = (pollData['startDate'] as Timestamp).toDate();
      final endDate = (pollData['endDate'] as Timestamp).toDate();

      final poll = {
        'id': doc.id,
        'title': pollData['title'],
        'description': pollData['description'],
        'startDate': startDate,
        'endDate': endDate,
      };

      // Categorize based on the current date
      if (currentDate.isBefore(startDate)) {
        upcoming.add(poll);
      } else if (currentDate.isAfter(endDate)) {
        previous.add(poll);
      } else {
        active.add(poll);
      }
    }

    if (!mounted) return;

    setState(() {
      _activePolls = active;
      _upcomingPolls = upcoming;
      _previousPolls = previous;
      _isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load polls: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Text(
          'Ballot Box 360',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onSelected: (value) {
              if (value == 'Logout') {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'Logout',
                  child: Text('Logout',
                      style: GoogleFonts.montserrat(fontSize: 16)),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${_user.displayName ?? _user.email}!',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Here are the polls available for you:',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            if (_isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text('Loading polls...',
                  style: GoogleFonts.montserrat(color: Colors.blue.shade700)),
            ] else ...[
              _buildPollsSection('Active Polls', _activePolls),
              const SizedBox(height: 16),
              _buildPollsSection('Upcoming Polls', _upcomingPolls),
              const SizedBox(height: 16),
              _buildPollsSection('Previous Polls', _previousPolls),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-poll');
        },
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPollsSection(String title, List<Map<String, dynamic>> polls) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity, // Ensures full-width alignment
            child: polls.isEmpty
                ? Text(
                    'No $title available',
                    style: GoogleFonts.montserrat(color: Colors.blue.shade700),
                  )
                : Wrap(
                    spacing: 16.0, // Space between cards horizontally
                    runSpacing: 16.0, // Space between cards vertically
                    alignment: WrapAlignment.start, // Align cards to the start
                    children: polls.map((poll) {
                      return PollCard(poll: poll);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
