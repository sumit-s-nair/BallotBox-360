import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PollCard extends StatelessWidget {
  final Map<String, dynamic> poll;

  const PollCard({super.key, required this.poll});

  @override
  Widget build(BuildContext context) {
    // Format dates for better readability
    final DateFormat dateFormatter = DateFormat('MMM dd, yyyy');
    final String startDate =
        dateFormatter.format(poll['startDate']);
    final String endDate =
        dateFormatter.format(poll['endDate']);

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
                    child: Image.asset(
                      'assets/images/poll.jpg',
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
                  // Display both start and end dates
                  Text(
                    'Start: $startDate | End: $endDate',
                    style: GoogleFonts.montserrat(fontSize: 14),
                  ),
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
