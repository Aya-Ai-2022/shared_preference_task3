import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:.[a-zA-Z0-9-]+)*$",
  );
  final String passwordRequirementsMessage =
      "Password should contain upper, lower, digit, and special character";

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      navigateToHome();
    }
  }

  Future<void> saveLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  void navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  void handleLogin() {
    String enteredEmail = _emailController.text.trim();
    String enteredPassword = _passwordController.text.trim();

    if (!emailRegex.hasMatch(enteredEmail)) {
      showErrorDialog('Invalid Email', 'Please enter a valid email address.');
      return;
    }

    String? passwordValidationMessage = validatePassword(enteredPassword);
    if (passwordValidationMessage != null) {
      showErrorDialog('Invalid Password', passwordValidationMessage);
      return;
    }

    if (emailRegex.hasMatch(enteredEmail) &&
        validatePassword(enteredPassword) == null) {
      saveLoginStatus();
      navigateToHome();
    } else {
      showErrorDialog('Login Failed', 'Invalid email or password. Please try again.');
    }
  }

  String? validatePassword(String password) {
    RegExp regex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

    if (password.isEmpty) {
      return "Password is required";
    } else if (password.length < 6) {
      return "Password must be more than 5 characters";
    } else if (!regex.hasMatch(password)) {
      return passwordRequirementsMessage;
    }
    return null;
  }

  void showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: buildLoginForm(),
    );
  }

  Widget buildLoginForm() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
       
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              buildEmailField(),
              const SizedBox(height: 20),
              buildPasswordField(),
              const SizedBox(height: 20),
              buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmailField() {
    return TextFormField(
      cursorColor: Colors.indigo,
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          borderSide: BorderSide(
            color: Colors.indigo,
          ),
        ),
        labelText: 'Email',
        prefixIcon: Icon(
          Icons.email,
          color: Colors.indigo,
        ),
        hintText: 'Enter your email',
        hintStyle: TextStyle(color: Colors.grey),
      ),

    );
  }

  Widget buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
          borderSide: BorderSide(
            color: Colors.indigo,
            style: BorderStyle.solid,
          ),
        ),
        labelText: 'Password',
        prefixIcon: const Icon(
          Icons.lock,
          color: Colors.indigo,
        ),
        hintText: 'Enter your password',
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            _showPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
        ),
      ),
      obscureText: !_showPassword,
    );
  }

  Widget buildLoginButton() {
    return ElevatedButton(
      onPressed: handleLogin,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
      ),
      child: const Text('Login'),
    );
  }
}
