import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_management/models/patient.dart';
import 'package:hospital_management/viewmodels/patient_viewmodel.dart';
import 'package:hospital_management/viewmodels/auth_viewmodel.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final patientVm = context.read<PatientViewModel>();
    final authVm = context.read<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Management - Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authVm.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Patient>>(
        stream: patientVm.watchPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final patients = snapshot.data ?? [];
          if (patients.isEmpty) {
            return const Center(child: Text('No patients yet. Add one!'));
          }

          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final p = patients[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(p.name),
                  subtitle: Text('Age: ${p.age} • Phone: ${p.phone}\n${p.notes}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showPatientForm(context, patientVm, patient: p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            _confirmDelete(context, patientVm, p.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPatientForm(context, patientVm),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PatientViewModel vm, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete patient?'),
        content: const Text('This will remove the patient permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await vm.deletePatient(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPatientForm(BuildContext context, PatientViewModel vm,
      {Patient? patient}) {
    // [Form logic remains the same]
    final nameCtrl = TextEditingController(text: patient?.name ?? '');
    final ageCtrl = TextEditingController(text: patient?.age.toString() ?? '');
    final phoneCtrl = TextEditingController(text: patient?.phone ?? '');
    final notesCtrl = TextEditingController(text: patient?.notes ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(patient == null ? 'Add Patient' : 'Edit Patient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: ageCtrl,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final age = int.tryParse(ageCtrl.text.trim()) ?? 0;
              final phone = phoneCtrl.text.trim();
              final notes = notesCtrl.text.trim();

              if (name.isEmpty) {
                // Using a temporary ScaffoldMessenger to show SnackBar in dialog context
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name required')));
                return;
              }

              Navigator.pop(context);

              if (patient == null) {
                await vm.addPatient(
                    name: name, age: age, phone: phone, notes: notes);
              } else {
                await vm.updatePatient(
                    id: patient.id,
                    name: name,
                    age: age,
                    phone: phone,
                    notes: notes);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}