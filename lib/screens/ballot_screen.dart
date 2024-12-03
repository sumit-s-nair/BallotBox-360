import 'package:flutter/material.dart';

class BallotScreen extends StatelessWidget {
  const BallotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ballot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your candidate:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Candidate 1'),
              leading: Radio(
                value: 1,
                groupValue: null,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Candidate 2'),
              leading: Radio(
                value: 2,
                groupValue: null,
                onChanged: (value) {},
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Submit vote logic here
                  Navigator.pop(context);
                },
                child: const Text('Submit Vote'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
