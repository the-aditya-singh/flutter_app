import 'package:flutter/material.dart';
import 'package:hospital_management/models/patient.dart';
import 'package:hospital_management/viewmodels/patient_viewmodel.dart';

class PatientFormPage extends StatefulWidget {
  final PatientViewModel vm;
  final Patient? patient;

  const PatientFormPage({super.key, required this.vm, this.patient});

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _notesCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.patient?.name ?? '');
    _ageCtrl = TextEditingController(text: widget.patient?.age.toString() ?? '');
    _phoneCtrl = TextEditingController(text: widget.patient?.phone ?? '');
    _notesCtrl = TextEditingController(text: widget.patient?.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final name = _nameCtrl.text.trim();
    final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;
    final phone = _phoneCtrl.text.trim();
    final notes = _notesCtrl.text.trim();

    try {
      if (widget.patient == null) {
        await widget.vm.addPatient(name: name, age: age, phone: phone, notes: notes);
      } else {
        await widget.vm.updatePatient(
          id: widget.patient!.id,
          name: name,
          age: age,
          phone: phone,
          notes: notes,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving patient: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.patient != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Patient' : 'Add Patient'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Name required' : null,
                ),
                TextFormField(
                  controller: _ageCtrl,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? 'Update' : 'Add'),
                  onPressed: _isSaving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
