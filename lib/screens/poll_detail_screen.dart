import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PollDetailScreen extends StatefulWidget {
  const PollDetailScreen({super.key});

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen> {
  bool _hasVoted = false;
  final List<Map<String, dynamic>> _candidates = [
    {'name': 'Candidate A', 'votes': 0},
    {'name': 'Candidate B', 'votes': 0},
    {'name': 'Candidate C', 'votes': 0},
  ];

  // Calculate the total votes
  num _getTotalVotes() {
    return _candidates.fold(0, (sum, item) => sum + item['votes']);
  }

  @override
  Widget build(BuildContext context) {
    final String pollId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Poll Details: $pollId',
          style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
                  'Vote for your preferred candidate:',
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select a candidate to cast your vote and view the results!',
                  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 24),
                
                // Candidates List
                ListView.builder(
                  shrinkWrap: true, // Makes the list take only the needed space
                  itemCount: _candidates.length,
                  itemBuilder: (context, index) {
                    final candidate = _candidates[index];
                    final totalVotes = _getTotalVotes();
                    // ignore: unused_local_variable
                    final votePercentage = totalVotes > 0
                        ? (candidate['votes'] / totalVotes)
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
                                candidate['name'],
                                style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ),
                            // Vote Button
                            ElevatedButton(
                              onPressed: _hasVoted
                                  ? null
                                  : () {
                                      setState(() {
                                        candidate['votes']++;
                                        _hasVoted = true;
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _hasVoted ? Colors.grey : Colors.blue.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _hasVoted ? 'Voted' : 'Vote',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // Voting Results
                if (_hasVoted) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Voting Results:',
                    style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Display progress bars for all candidates
                  ..._candidates.map((candidate) {
                    final totalVotes = _getTotalVotes();
                    final votePercentage = totalVotes > 0
                        ? (candidate['votes'] / totalVotes)
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${candidate['name']} - ${(votePercentage * 100).toStringAsFixed(2)}%',
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
                  }).toList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
