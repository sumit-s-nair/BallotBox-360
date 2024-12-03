import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PollCard extends StatelessWidget {
  final Map<String, dynamic> poll;

  const PollCard({super.key, required this.poll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SizedBox(
          width: 350, // Limit the width to 350
          child: InkWell(
            onTap: () {
              // Pass the pollId dynamically here
              Navigator.pushNamed(
                context,
                '/poll-details',
                arguments: poll['id'], // Send pollId as argument
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder image with rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://via.placeholder.com/350x200',
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Poll title
                  Text(
                    poll['title'],
                    style: GoogleFonts.montserrat(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Poll date
                  Text('Date: ${poll['date']}',
                      style: GoogleFonts.montserrat(fontSize: 14)),
                  const SizedBox(height: 8),
                  // Button to navigate to the poll details screen
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the details page
                      Navigator.pushNamed(
                        context,
                        '/poll-details',
                        arguments: poll['id'], // Pass pollId as argument
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700, // Button color
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
