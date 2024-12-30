import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/material.dart';
import 'package:notes/screens/log_in.dart'; // Import Login screen

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logOut() async {
    try {
      // Log out the current user
      await _auth.signOut();
      // Navigate to the Login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: ${e.toString()}")),
      );
    }
  }

  Future<void> _deleteAccount() async {
    try {
      User? user = _auth.currentUser; // Get the current user
      if (user != null) {
        await user.delete(); // Delete the user's account
        // Navigate to the Login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (Route<dynamic> route) => false, // Remove all previous routes
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account successfully deleted.")),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please log in again to confirm account deletion.",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting account: ${e.message}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting account: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser; // Get the logged-in user
    final String? email =
        user?.email ?? "Anonymous User"; // Fetch user email or default value

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Icon (Rounded)
              CircleAvatar(
                radius: 50.0,
                backgroundColor: Colors.grey[300],
                child: const Icon(
                  Icons.person,
                  size: 60.0,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20.0),

              // Display logged-in email
              Text(
                'Logged in as: $email',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40.0),

              // Log Out Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _logOut, // Log out the user
                  child: const Text("Log Out"),
                ),
              ),
              const SizedBox(height: 20.0),

              // Delete Account Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _deleteAccount, // Delete the user's account
                  child: const Text("Delete Account"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
