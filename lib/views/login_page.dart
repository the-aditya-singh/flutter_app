import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_management/viewmodels/auth_viewmodel.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false, // Prevents back button on first screen
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hospital Management System',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: () async {
                // ✅ Capture references before the async gap
                final vm = context.read<AuthViewModel>();
                final messenger = ScaffoldMessenger.of(context);

                try {
                  await vm.signInWithGoogle();

                  // You can check auth status here safely
                  if (vm.isAuthenticated) {
                    // Navigate or rely on wrapper
                  }
                } catch (e) {
                  // ✅ Safe: uses messenger captured before await
                  messenger.showSnackBar(
                    SnackBar(content: Text('Login Failed: $e')),
                  );
                }
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
