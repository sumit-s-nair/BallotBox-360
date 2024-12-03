import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PollDetailScreen extends StatefulWidget {
  const PollDetailScreen({Key? key}) : super(key: key);

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
    // Retrieve pollId from route arguments
    final String pollId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('Poll Details: $pollId', style: GoogleFonts.montserrat(fontSize: 22)),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Poll: $pollId',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text('Vote for your preferred candidate:', style: GoogleFonts.montserrat(fontSize: 16)),
            const SizedBox(height: 16),
            Column(
              children: _candidates.map((candidate) {
                return ListTile(
                  title: Text(candidate['name'], style: GoogleFonts.montserrat(fontSize: 16)),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (!_hasVoted) {
                          candidate['votes']++;
                          _hasVoted = true;
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                    ),
                    child: Text(_hasVoted ? 'Voted' : 'Vote'),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            if (_hasVoted) ...[
              Text('Voting Results:', style: GoogleFonts.montserrat(fontSize: 18)),
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
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
