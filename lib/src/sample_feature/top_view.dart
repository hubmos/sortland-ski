import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ski/src/sample_feature/form_view.dart';
import 'package:ski/src/sample_feature/qr_scan_view.dart';
import 'package:ski/src/settings/settings_controller.dart';
import 'package:ski/src/settings/settings_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TopView extends StatelessWidget {
  const TopView({super.key});
  static const routeName = "top";

  // Define admin credentials
  static String adminUsername = dotenv.env['ADMINUSER']!;
  static String adminPassword = dotenv.env['ADMINPASS']!;

  @override
  Widget build(BuildContext context) {
    final settingsController = Provider.of<SettingsController>(context);
    final ThemeMode themeMode = settingsController.themeMode;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => showAdminLoginDialog(context),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/skis.png"), fit: BoxFit.cover),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                foregroundImage:
                    const AssetImage('assets/images/flutter_logo.png'),
                backgroundColor: Colors.purple.shade100,
              ),
              const SizedBox(
                height: 100,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 40),
                      backgroundColor: themeMode == ThemeMode.dark
                          ? const Color.fromARGB(255, 48, 122, 82)
                          : const Color.fromARGB(255, 84, 209, 132)),
                  child: const Text(
                    'Lei ut',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.restorablePushNamed(context, FormView.routeName);
                  }),
              const SizedBox(height: 20),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 40),
                      backgroundColor: themeMode == ThemeMode.dark
                          ? const Color.fromARGB(255, 138, 54, 54)
                          : const Color.fromARGB(255, 223, 98, 98)),
                  child: const Text(
                    'Lever inn',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          const QRScanPage(items: [], "", "", null),
                    ));
                  })
            ],
          ),
        ),
      ),
    );
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        // Show admin login popup
        showAdminLoginDialog(context);
        break;
      case 1:
        Navigator.restorablePushNamed(context, SettingsView.routeName);
    }
  }

  void showAdminLoginDialog(BuildContext context) {
    // Controllers to capture input
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    // Show dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Brukernavn'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Passord'),
              obscureText: true, // Hide password
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Avbryt'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Logg inn'),
            onPressed: () {
              // Check credentials
              if (usernameController.text == adminUsername &&
                  passwordController.text == adminPassword) {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushNamed(context, SettingsView.routeName);
              } else {
                // Show error message or handle invalid login
                Navigator.of(context).pop(); // Close the dialog
                // Optionally show an error message
              }
            },
          ),
        ],
      ),
    );
  }
}
