import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  String selectedRole = "Student";

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final doc =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .get();

      final data =
          doc.data() as Map<String, dynamic>;

      _nameController.text =
          data["name"] ?? "";

      selectedRole =
          data["role"] ?? "Student";

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        saving = true;
      });

      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) return;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({
        "name": _nameController.text.trim(),
        "role": selectedRole,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Profile updated successfully",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Failed: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                child: Text(
                  _nameController.text.isEmpty
                      ? "U"
                      : _nameController.text[0]
                          .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon:
                      Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Enter name";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration:
                    const InputDecoration(
                  labelText: "Role",
                  prefixIcon:
                      Icon(Icons.badge),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Student",
                    child: Text("Student"),
                  ),
                  DropdownMenuItem(
                    value: "Staff",
                    child: Text("Staff"),
                  ),
                  DropdownMenuItem(
                    value: "Volunteer",
                    child: Text("Volunteer"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed:
                    saving ? null : saveProfile,
                icon: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  saving
                      ? "Saving..."
                      : "Save Changes",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}