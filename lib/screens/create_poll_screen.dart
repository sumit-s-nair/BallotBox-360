import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({super.key});

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pollTitleController = TextEditingController();
  final TextEditingController _pollDescriptionController =
      TextEditingController();
  final List<TextEditingController> _candidateControllers = [];
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _pollTitleController.dispose();
    _pollDescriptionController.dispose();
    for (var controller in _candidateControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCandidateField() {
    setState(() {
      _candidateControllers.add(TextEditingController());
    });
  }

  void _removeCandidateField(int index) {
    setState(() {
      _candidateControllers.removeAt(index);
    });
  }

  Future<void> _submitPoll() async {
    if (_formKey.currentState!.validate()) {
      final pollTitle = _pollTitleController.text;
      final pollDescription = _pollDescriptionController.text;
      final candidates =
          _candidateControllers.map((controller) => controller.text).toList();

      try {
        // Create poll document in Firestore
        final pollRef = FirebaseFirestore.instance.collection('polls').doc();
        final pollId = pollRef.id;

        final pollData = {
          'title': pollTitle,
          'description': pollDescription,
          'candidates': candidates,
          'startDate': _startDate,
          'endDate': _endDate,
          'createdAt': Timestamp.now(),
          'createdBy': FirebaseAuth.instance.currentUser!.uid,
          'votes': {for (var candidate in candidates) candidate: 0},
        };

        // Create the poll
        await pollRef.set(pollData);

        // Create a corresponding document in the votes collection
        final votesData = {
          'pollId': pollId,
          'votes': {for (var candidate in candidates) candidate: 0},
        };
        await FirebaseFirestore.instance
            .collection('votes')
            .doc(pollId)
            .set(votesData);

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Poll "$pollTitle" created successfully!')),
          );

          // Navigate to home page
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating poll: $e')),
          );
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue.shade700,
            colorScheme: ColorScheme.light(primary: Colors.blue.shade700),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final adjustedDate =
          DateTime(picked.year, picked.month, picked.day, 12, 0, 0);
      setState(() {
        if (isStartDate) {
          _startDate = adjustedDate;
        } else {
          _endDate = adjustedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Poll',
          style: GoogleFonts.montserrat(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Poll Title
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: TextFormField(
                      controller: _pollTitleController,
                      decoration: InputDecoration(
                        labelText: 'Poll Title',
                        labelStyle:
                            GoogleFonts.montserrat(color: Colors.blue.shade700),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a poll title';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Poll Description
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: TextFormField(
                      controller: _pollDescriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Poll Description',
                        labelStyle:
                            GoogleFonts.montserrat(color: Colors.blue.shade700),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a poll description';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Candidate Fields
                Text(
                  'Candidates:',
                  style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700),
                ),
                const SizedBox(height: 8),
                Center(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _candidateControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 600),
                                    child: TextFormField(
                                      controller: _candidateControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Candidate ${index + 1}',
                                        labelStyle: GoogleFonts.montserrat(
                                            color: Colors.blue.shade700),
                                        border: const OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a candidate name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () => _removeCandidateField(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addCandidateField,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    maximumSize: const Size(300, 60),
                  ),
                  child: const Text('Add Candidate',
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 16),

                // Voting Duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Voting Start Date: ',
                      style:
                          GoogleFonts.montserrat(color: Colors.blue.shade700),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context, true),
                      child: Text(
                        _startDate != null
                            ? '${_startDate!.toLocal()}'.split(' ')[0]
                            : 'Select Date',
                        style:
                            GoogleFonts.montserrat(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Voting End Date: ',
                      style:
                          GoogleFonts.montserrat(color: Colors.blue.shade700),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context, false),
                      child: Text(
                        _endDate != null
                            ? '${_endDate!.toLocal()}'.split(' ')[0]
                            : 'Select Date',
                        style:
                            GoogleFonts.montserrat(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitPoll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      minimumSize: const Size(200, 50),
                      maximumSize: const Size(300, 60),
                    ),
                    child: const Text('Create Poll',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
