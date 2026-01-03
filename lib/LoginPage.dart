import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'signupPage.dart';
import 'teacher/TeacherDashBoard.dart';
import 'Student/StudentHome.dart';
import 'admin/adminpage.dart';
import 'objects/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool hidePassword = true;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  static const Color primary = Color(0xFF16A34A);

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  InputDecoration input(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }


  Future<void> login() async {

    final url = Uri.parse("http://abohmed.atwebpages.com/login_user.php");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailCtrl.text.trim(),
          "password": passwordCtrl.text.trim(),
        }),
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);

        if (data.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'])),
          );
          return;
        }

        User user = User.fromJson(data);


        if (user.role == "student") {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => StudentHome(user: user),
          ));
        }
        else if (user.role == "teacher") {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TeacherDashboard(user: user),
          ));
        }
        else if (user.role == "admin") {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => adminPage(user: user),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Failed: ${res.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error connecting to server")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 60, color: primary),
                  const SizedBox(height: 12),
                  const Text(
                    "Classroom Connect",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),


                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next, // Moves focus to password
                    decoration: input("Email", Icons.mail),
                  ),

                  const SizedBox(height: 12),


                  TextField(
                    controller: passwordCtrl,
                    obscureText: hidePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) => login(),
                    decoration: input("Password", Icons.lock).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => hidePassword = !hidePassword),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),


                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: login,
                      child: const Text("Log In"),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ));
                        },
                        child: const Text(
                          "Sign up",
                          style: TextStyle(fontWeight: FontWeight.bold, color: primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}