import 'package:flutter/material.dart';
import 'login_page.dart';
import '../../navigation/presentation/navigation.dart';
import '../service/auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController reenterPasswordController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureReenterPassword = true;

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      String email = emailController.text.trim();
      String fullName =
          "${firstNameController.text} ${lastNameController.text}";
      String password = passwordController.text.trim();
      String reenterPassword = reenterPasswordController.text.trim();

      if (password != reenterPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Passwords do not match",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        );
        return;
      }

      bool success = await AuthMethods().registerUser(
        context,
        email,
        fullName,
        password,
      );

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Navigation()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "HIRAM",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(emailController, "Email"),
                  const SizedBox(height: 10),
                  _buildTextField(firstNameController, "First Name"),
                  const SizedBox(height: 10),
                  _buildTextField(lastNameController, "Last Name"),
                  const SizedBox(height: 10),
                  _buildPasswordField(
                      passwordController, "Password", _obscurePassword, () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  }),
                  const SizedBox(height: 10),
                  _buildPasswordField(reenterPasswordController,
                      "Re-enter Password", _obscureReenterPassword, () {
                    setState(() =>
                        _obscureReenterPassword = !_obscureReenterPassword);
                  }),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Register',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('Sign In',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Please enter your $label' : null,
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      bool obscureText, VoidCallback toggleVisibility) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your $label';
        if (label == "Password" && value.length < 6)
          return 'Password must be at least 6 characters long';
        return null;
      },
    );
  }
}
