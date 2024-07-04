import 'package:flutter/material.dart';
import 'package:ski/src/sample_feature/rental_form.dart';

class FormView extends StatelessWidget {
  const FormView({super.key});
  static const routeName = "form";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text('Utleie av'),
        ),
        body: Container(
          height: MediaQuery.sizeOf(context).height,
          child: const DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                    opacity: 0.4,
                    image: AssetImage("assets/images/skis.png"),
                    fit: BoxFit.cover),
              ),
              child: RentalForm()),
        ));
  }
}
