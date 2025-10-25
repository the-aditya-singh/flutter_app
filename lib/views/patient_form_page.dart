import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_management/models/patient.dart';
import 'package:hospital_management/viewmodels/patient_viewmodel.dart';

class AddEditPatientPage extends StatefulWidget {
  final Patient? patient;

  const AddEditPatientPage({
    super.key,
    this.patient,
    required PatientViewModel vm,
  });

  @override
  State<AddEditPatientPage> createState() => _AddEditPatientPageState();
}

class _AddEditPatientPageState extends State<AddEditPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedGender;
  String? _selectedComplaint;
  String? _selectedDuration;
  String? _customComplaint;
  String? _customDuration;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _baseComplaints = [
    'Fever',
    'Cold',
    'Headache',
    'Cough',
    'Body Pain',
  ];
  final List<String> _baseDurations = [
    '1 Day',
    '2 Days',
    '1 Week',
    '2 Weeks',
    '1 Month',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.patient != null) {
      _nameController.text = widget.patient!.name;
      _ageController.text = widget.patient!.age.toString();
      _phoneController.text = widget.patient!.phone;
      _notesController.text = widget.patient!.notes;
      _selectedGender = widget.patient!.gender;
      _selectedComplaint = widget.patient!.mainComplaint;
      _selectedDuration = widget.patient!.symptomDuration;

      // Handle custom entries
      if (!_baseComplaints.contains(_selectedComplaint)) {
        _customComplaint = _selectedComplaint;
        _selectedComplaint = 'Other';
      }
      if (!_baseDurations.contains(_selectedDuration)) {
        _customDuration = _selectedDuration;
        _selectedDuration = 'Other';
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep < 6) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        _savePatient();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _savePatient() async {
    final vm = Provider.of<PatientViewModel>(context, listen: false);
    final navigator = Navigator.of(context);

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    final phone = _phoneController.text.trim();
    final gender = _selectedGender ?? '';
    final complaint = _selectedComplaint == 'Other'
        ? (_customComplaint?.trim() ?? '')
        : (_selectedComplaint ?? '');
    final duration = _selectedDuration == 'Other'
        ? (_customDuration?.trim() ?? '')
        : (_selectedDuration ?? '');
    final notesText = _notesController.text.trim();
    final notes = notesText.isEmpty ? 'No notes' : notesText;

    if (widget.patient == null) {
      await vm.addPatient(
        name: name,
        age: age,
        phone: phone,
        gender: gender,
        mainComplaint: complaint,
        symptomDuration: duration,
        notes: notes,
      );
    } else {
      await vm.updatePatient(
        id: widget.patient!.id,
        name: name,
        age: age,
        phone: phone,
        gender: gender,
        mainComplaint: complaint,
        symptomDuration: duration,
        notes: notes,
      );
    }

    navigator.pop();
  }

  Widget _buildStep(String question, Widget field) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              field,
            ],
          ),
        ),
      ),
    );
  }

  List<String> _complaintsList() {
    return [..._baseComplaints, 'Other'];
  }

  List<String> _durationsList() {
    return [..._baseDurations, 'Other'];
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _buildStep(
        "What is the patient's full name?",
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
          validator: (v) =>
              v == null || v.isEmpty ? 'Please enter the name' : null,
        ),
      ),
      _buildStep(
        'How old is the patient?',
        TextFormField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Age'),
          validator: (v) {
            final val = int.tryParse(v ?? '');
            if (val == null || val <= 0) return 'Enter valid age';
            return null;
          },
        ),
      ),
      _buildStep(
        "What is the patient's phone number?",
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Phone Number'),
          validator: (v) =>
              v == null || v.length < 10 ? 'Enter valid phone number' : null,
        ),
      ),
      _buildStep(
        "Select the patient's gender",
        DropdownButtonFormField<String>(
          initialValue: _selectedGender,
          items: _genders
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (val) => setState(() => _selectedGender = val),
          validator: (v) =>
              v == null || v.isEmpty ? 'Select gender' : null,
        ),
      ),
      _buildStep(
        'What is the main complaint?',
        Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedComplaint,
              items: _complaintsList()
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() {
                _selectedComplaint = val;
                if (val != 'Other') _customComplaint = null;
              }),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Select complaint' : null,
            ),
            if (_selectedComplaint == 'Other')
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Enter custom complaint'),
                  controller: TextEditingController(text: _customComplaint)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: _customComplaint?.length ?? 0),
                    ),
                  onChanged: (val) => _customComplaint = val,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter complaint' : null,
                ),
              ),
          ],
        ),
      ),
      _buildStep(
        'How long has the patient had these symptoms?',
        Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedDuration,
              items: _durationsList()
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) => setState(() {
                _selectedDuration = val;
                if (val != 'Other') _customDuration = null;
              }),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Select duration' : null,
            ),
            if (_selectedDuration == 'Other')
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Enter custom duration'),
                  controller: TextEditingController(text: _customDuration)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: _customDuration?.length ?? 0),
                    ),
                  onChanged: (val) => _customDuration = val,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter duration' : null,
                ),
              ),
          ],
        ),
      ),
      _buildStep(
        'Any additional notes about the patient?',
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes (Optional)',
            hintText: 'Enter any additional information...',
          ),
          maxLines: 5,
          textInputAction: TextInputAction.done,
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient == null ? 'Add Patient' : 'Edit Patient'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentStep + 1) / steps.length,
              backgroundColor: Colors.grey.shade200,
              color: Theme.of(context).colorScheme.primary,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: steps,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    ElevatedButton(
                      onPressed: _previousStep,
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 80),
                  ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(_currentStep == steps.length - 1
                        ? 'Finish'
                        : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}