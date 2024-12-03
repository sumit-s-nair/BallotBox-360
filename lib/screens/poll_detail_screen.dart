// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PollDetailScreen extends StatefulWidget {
  const PollDetailScreen({super.key});

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen> {
  bool _hasVoted = false;
  bool _isLoading = true;
  bool _isPollActive = false;
  bool _isPollUpcoming = false;
  bool _isPollCompleted = false;

  Map<String, dynamic> _pollData = {};
  List<String> _candidates = [];
  String? _selectedCandidate;
  bool _voteConfirmed = false;

  // Function to fetch poll data
  Future<void> _fetchPollData(String pollId) async {
    try {
      final pollDoc = await FirebaseFirestore.instance
          .collection('polls')
          .doc(pollId)
          .get();

      if (pollDoc.exists) {
        setState(() {
          _pollData = pollDoc.data()!;
          _candidates = List<String>.from(_pollData['candidates']);
          DateTime now = DateTime.now();
          DateTime startDate = _pollData['startDate'].toDate();
          DateTime endDate = _pollData['endDate'].toDate();

          if (now.isBefore(startDate)) {
            _isPollUpcoming = true;
          } else if (now.isAfter(endDate)) {
            _isPollCompleted = true;
          } else {
            _isPollActive = true;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to confirm the vote
  Future<void> _confirmVote(String pollId) async {
    if (_selectedCandidate != null) {
      setState(() {
        _voteConfirmed = true;
        _hasVoted = true;
      });

      try {
        // Transaction to update vote count
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final pollDocRef =
              FirebaseFirestore.instance.collection('polls').doc(pollId);

          final pollSnapshot = await transaction.get(pollDocRef);

          if (pollSnapshot.exists) {
            final votes = Map<String, dynamic>.from(pollSnapshot['votes']);

            if (votes.containsKey(_selectedCandidate!)) {
              votes[_selectedCandidate!] =
                  (votes[_selectedCandidate!] as int) + 1;
              transaction.update(pollDocRef, {'votes': votes});
            } else {
              const SnackBar(content: Text('Candidate doesnt exist'));
            }
          }
        });

        // Save user's vote
        await FirebaseFirestore.instance.collection('votes').doc(pollId).set({
          'votes': {FirebaseAuth.instance.currentUser!.uid: _selectedCandidate}
        }, SetOptions(merge: true));
      } catch (e) {
        SnackBar(content: Text('Error "$e" has occured while updating votes'));
      }
    }
  }

  // Function to fetch user's vote status
  Future<void> _fetchUserVoteStatus(String pollId) async {
    try {
      final votesDoc = await FirebaseFirestore.instance
          .collection('votes')
          .doc(pollId)
          .get();

      if (votesDoc.exists) {
        final userVotes = Map<String, dynamic>.from(votesDoc['votes']);
        final userVote = userVotes[FirebaseAuth.instance.currentUser!.uid];

        if (userVote != null) {
          setState(() {
            _hasVoted = true;
            _selectedCandidate = userVote;
          });
        }
      }
    } catch (e) {
      SnackBar(content: Text('Error "$e" has occured'));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String pollId =
          ModalRoute.of(context)!.settings.arguments as String;
      _fetchPollData(pollId);
      _fetchUserVoteStatus(pollId);
    });
  }

  // Get total votes for all candidates
  num _getTotalVotes() {
    return _pollData['votes']?.values.fold(0, (votes, item) => votes + item) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final String pollId = ModalRoute.of(context)!.settings.arguments as String;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Poll Details: $pollId',
            style: GoogleFonts.montserrat(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.blue.shade700,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If the poll is completed, show results immediately
    if (_isPollCompleted) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Poll Results: $pollId',
            style: GoogleFonts.montserrat(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.blue.shade700,
          elevation: 0,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poll Title and Description
                  Text(
                    _pollData['title'] ?? 'Loading...',
                    style: GoogleFonts.montserrat(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _pollData['description'] ?? 'No description available',
                    style: GoogleFonts.montserrat(
                        fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 24),

                  // Candidates List
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = _candidates[index];
                      final totalVotes = _getTotalVotes();
                      final votePercentage = totalVotes > 0
                          ? (_pollData['votes'][candidate] / totalVotes)
                          : 0.0;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Candidate Name
                              Expanded(
                                child: Text(
                                  candidate,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              // Show the percentage of votes
                              Text(
                                '${(votePercentage * 100).toStringAsFixed(2)}%',
                                style: GoogleFonts.montserrat(
                                    fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Poll is upcoming or active, show vote buttons if applicable
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Poll Details: ${_pollData['title']}',
          style: GoogleFonts.montserrat(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poll Title and Description
                Text(
                  _pollData['title'] ?? 'Loading...',
                  style: GoogleFonts.montserrat(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  _pollData['description'] ?? 'No description available',
                  style: GoogleFonts.montserrat(
                      fontSize: 16, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 24),

                // Candidates List
                // Candidates List
                if (_hasVoted || _isPollCompleted) ...[
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = _candidates[index];
                      final isSelected = candidate == _selectedCandidate;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Candidate Name
                              Expanded(
                                child: Text(
                                  candidate,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              // Show a checkmark or highlight for the user's choice
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Colors.green)
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  // If results are available, show them
                  if (_isPollCompleted) ...[
                    Text(
                      'Voting Results:',
                      style: GoogleFonts.montserrat(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ..._candidates.map((candidate) {
                      final totalVotes = _getTotalVotes();
                      final votePercentage = totalVotes > 0
                          ? (_pollData['votes'][candidate] / totalVotes)
                          : 0.0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$candidate - ${(votePercentage * 100).toStringAsFixed(2)}%',
                              style: GoogleFonts.montserrat(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: votePercentage,
                              backgroundColor: Colors.grey.shade300,
                              color: Colors.blue.shade700,
                              minHeight: 8,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ] else if (_isPollActive) ...[
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = _candidates[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Candidate Name
                              Expanded(
                                child: Text(
                                  candidate,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              // Select Button
                              Radio<String>(
                                value: candidate,
                                groupValue: _selectedCandidate,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCandidate = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Confirm Vote Button
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _selectedCandidate != null
                        ? () => _confirmVote(pollId)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Confirm Vote'),
                  ),
                ],

                // Show Results if Poll is Completed or if the user has already voted
                if (_hasVoted || _isPollCompleted) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Voting Results:',
                    style: GoogleFonts.montserrat(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Display progress bars for all candidates
                  ..._candidates.map((candidate) {
                    final totalVotes = _getTotalVotes();
                    final votePercentage = totalVotes > 0
                        ? (_pollData['votes'][candidate] / totalVotes)
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$candidate - ${(votePercentage * 100).toStringAsFixed(2)}%',
                            style: GoogleFonts.montserrat(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: votePercentage,
                            backgroundColor: Colors.grey.shade300,
                            color: Colors.blue.shade700,
                            minHeight: 8,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
