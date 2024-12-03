import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  void _submitPoll() {
    if (_formKey.currentState!.validate()) {
      final pollTitle = _pollTitleController.text;
      final pollDescription = _pollDescriptionController.text;
      final candidates =
          _candidateControllers.map((controller) => controller.text).toList();

      // Logic to create the poll in the database (Firebase, etc.)

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Poll "$pollTitle" created successfully!')),
      );

      // Optionally, navigate to the Poll Details page
      // Navigator.pushNamed(context, '/poll-detail', arguments: pollId);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
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
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
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
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center the elements
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

                // Poll Description (Increased height)
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: TextFormField(
                      controller: _pollDescriptionController,
                      maxLines:
                          4, // Increased height by allowing multiple lines
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
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Centers the Row content
                            children: [
                              // Wrap the input in a Flexible widget to allow it to adapt to the screen size
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth: 600), // Set max width
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
                    maximumSize: const Size(300, 60), // Added max width
                  ),
                  child: const Text('Add Candidate',
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 16),

                // Voting Duration
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the text and button
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
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the text and button
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
                      maximumSize: const Size(300, 60), // Added max width
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
