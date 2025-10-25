import 'package:flutter/material.dart';
import 'package:hospital_management/models/patient.dart';
import 'package:hospital_management/viewmodels/patient_viewmodel.dart';
import 'package:provider/provider.dart';

class AddEditPatientPage extends StatefulWidget {
  final Patient? patient;

  const AddEditPatientPage({super.key, this.patient, required PatientViewModel vm});

  @override
  State<AddEditPatientPage> createState() => _AddEditPatientPageState();
}

class _AddEditPatientPageState extends State<AddEditPatientPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedGender;
  String? _selectedComplaint;
  String? _selectedDuration;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _complaints = [
    'Fever',
    'Cold',
    'Headache',
    'Cough',
    'Body Pain',
    'Other'
  ];
  final List<String> _durations = [
    '1 Day',
    '2 Days',
    '1 Week',
    '2 Weeks',
    '1 Month',
    'Other'
  ];

  String? _customComplaint;
  String? _customDuration;

  @override
  void initState() {
    super.initState();

    // Pre-fill in edit mode
    if (widget.patient != null) {
      _nameController.text = widget.patient!.name;
      _ageController.text = widget.patient!.age.toString();
      _phoneController.text = widget.patient!.phone;
      _notesController.text = widget.patient!.notes;
      _selectedGender = widget.patient!.gender;
      _selectedComplaint = widget.patient!.mainComplaint;
      _selectedDuration = widget.patient!.symptomDuration;

      // If previous value isn't in list, add temporarily
      if (_selectedComplaint != null &&
          !_complaints.contains(_selectedComplaint!)) {
        _complaints.add(_selectedComplaint!);
      }
      if (_selectedDuration != null &&
          !_durations.contains(_selectedDuration!)) {
        _durations.add(_selectedDuration!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = Provider.of<PatientViewModel>(context, listen: false);

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    final phone = _phoneController.text.trim();
    final gender = _selectedGender ?? '';
    final complaint = _selectedComplaint == 'Other'
        ? _customComplaint ?? ''
        : _selectedComplaint ?? '';
    final duration = _selectedDuration == 'Other'
        ? _customDuration ?? ''
        : _selectedDuration ?? '';
    final notes = _notesController.text.trim();

    if (widget.patient == null) {
      await viewModel.addPatient(
        name: name,
        age: age,
        phone: phone,
        gender: gender,
        mainComplaint: complaint,
        symptomDuration: duration,
        notes: notes,
      );
    } else {
      await viewModel.updatePatient(
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
    if(!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient == null ? 'Add Patient' : 'Edit Patient'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NAME
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter patient name' : null,
              ),
              const SizedBox(height: 12),

              // AGE
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter age';
                  final val = int.tryParse(v);
                  if (val == null || val <= 0) return 'Enter valid age';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // PHONE
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter phone number';
                  if (v.length < 10) return 'Enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // GENDER
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: _genders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedGender = val),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Select gender' : null,
              ),
              const SizedBox(height: 12),

              // MAIN COMPLAINT
              DropdownButtonFormField<String>(
                initialValue: _selectedComplaint,
                decoration: const InputDecoration(labelText: 'Main Complaint'),
                items: _complaints
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() {
                  _selectedComplaint = val;
                  _customComplaint = null;
                }),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Select complaint' : null,
              ),
              if (_selectedComplaint == 'Other')
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Enter Custom Complaint'),
                  onChanged: (val) => _customComplaint = val,
                  validator: (v) {
                    if (_selectedComplaint == 'Other' &&
                        (v == null || v.isEmpty)) {
                      return 'Enter custom complaint';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 12),

              // SYMPTOM DURATION
              DropdownButtonFormField<String>(
                initialValue: _selectedDuration,
                decoration:
                    const InputDecoration(labelText: 'Duration of Symptoms'),
                items: _durations
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) => setState(() {
                  _selectedDuration = val;
                  _customDuration = null;
                }),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Select duration' : null,
              ),
              if (_selectedDuration == 'Other')
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Enter Custom Duration'),
                  onChanged: (val) => _customDuration = val,
                  validator: (v) {
                    if (_selectedDuration == 'Other' &&
                        (v == null || v.isEmpty)) {
                      return 'Enter custom duration';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 12),

              // NOTES
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Additional Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePatient,
                  child: Text(widget.patient == null ? 'Add Patient' : 'Update'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
