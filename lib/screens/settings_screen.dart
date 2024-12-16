// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_marketplace/services/auth.service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Example preference: Currency
  String selectedCurrency = 'USD';
  final List<String> currencies = ['USD', 'EUR', 'GBP', 'JPY', 'AUD'];

  @override
  void initState() {
    super.initState();
    // Fetch current user's preferences from Firestore if available
    // For simplicity, we'll set default values
  }

  Future<void> _updateCurrency(String? newCurrency) async {
    if (newCurrency == null) return;
    setState(() {
      selectedCurrency = newCurrency;
    });
    // Update user's currency preference in Firestore
    final AuthService = Provider.of<AuthService>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Update Firestore user document
      // Assuming FirestoreService has a method to update user preferences
      // Implement FirestoreService.updateUserPreferences as needed
      // Example:
      // await firestoreService.updateUserPreferences(currentUser.uid, {'currency': newCurrency});
    }
  }

  Future<void> _signOut() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // final firestoreService = Provider.of<FirestoreService>(context);
    // Fetch user preferences if needed

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Account Information
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Account'),
              subtitle: const Text('Manage your account settings'),
              onTap: () {
                // Navigate to Account Management Screen
                // Implement Account Management as needed
              },
            ),
            const Divider(),
            // Currency Preferences
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text('Currency'),
              subtitle: Text(selectedCurrency),
              trailing: DropdownButton<String>(
                value: selectedCurrency,
                items: currencies.map((currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: _updateCurrency,
              ),
            ),
            const Divider(),
            // Additional Preferences
            // Add more settings options as needed
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              subtitle: const Text('Manage notification preferences'),
              trailing: Switch(
                value: true, // Replace with actual preference value
                onChanged: (val) {
                  // Handle toggle
                },
              ),
            ),
            const Divider(),
            // Sign Out Button
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }
}