import 'package:flutter/material.dart';
import 'package:ski/src/sample_feature/create_form.dart';
import 'package:ski/src/sample_feature/qr_del_view.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text('Settings'),
        ),
        body: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  opacity: 0.4,
                  image: AssetImage("assets/images/skis.png"),
                  fit: BoxFit.cover),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const Text('Fargetema'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<ThemeMode>(
                      // Read the selected themeMode from the controller
                      value: controller.themeMode,
                      // Call the updateThemeMode method any time the user selects a theme.
                      onChanged: controller.updateThemeMode,
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System Tema'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light mode'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark mode'),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      initialValue: controller.apiBaseUrl,
                      decoration:
                          const InputDecoration(labelText: 'API Base URL'),
                      onChanged: controller.updateApiBaseUrl,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FilledButton(
                            child: const Text("Legg til utstyr"),
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => const CreateForm()))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FilledButton(
                            child: const Text("Slett utstyr"),
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => const QRDelPage()))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
