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
  bool _isLoading = false;
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
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _previousPolls = [
        {'title': 'Best Movie of 2024', 'date': '2024-01-01', 'id': 'poll_1'},
        {'title': 'Favorite Song of the Year', 'date': '2023-12-31', 'id': 'poll_2'},
      ];
      _upcomingPolls = [
        {'title': 'Next President Election', 'date': '2025-01-01', 'id': 'poll_3'},
        {'title': 'Best Mobile App of 2024', 'date': '2024-12-25', 'id': 'poll_4'},
      ];
      _activePolls = [
        {'title': 'Campus Cleanliness Survey', 'date': '2024-12-03', 'id': 'poll_5'},
        {'title': 'Holiday Party Vote', 'date': '2024-12-03', 'id': 'poll_6'},
      ];
      _isLoading = false;
    });
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
                  value: 'Profile',
                  child: Text('Profile', style: GoogleFonts.montserrat(fontSize: 16)),
                ),
                PopupMenuItem<String>(
                  value: 'Logout',
                  child: Text('Logout', style: GoogleFonts.montserrat(fontSize: 16)),
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
              Text('Loading polls...', style: GoogleFonts.montserrat(color: Colors.blue.shade700)),
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
        child: const Icon(Icons.add,
        color : Color.fromARGB(255, 255, 255, 255)),
      ),
    );
  }

  Widget _buildPollsSection(String title, List<Map<String, dynamic>> polls) {
    if (polls.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
            ),
            const SizedBox(height: 8),
            Text('No $title available', style: GoogleFonts.montserrat(color: Colors.blue.shade700)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
          ),
          SizedBox(width: MediaQuery.of(context).size.width - 32,height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              
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
