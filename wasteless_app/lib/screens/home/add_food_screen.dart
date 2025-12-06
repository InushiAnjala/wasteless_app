import 'package:flutter/material.dart';
import '../../widgets/green_button.dart';
import '../../widgets/text_field.dart';

class AddFoodScreen extends StatelessWidget {
  const AddFoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Food"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CustomTextField(hint: "Food Name"),
            const SizedBox(height: 14),
            const CustomTextField(hint: "Quantity"),
            const SizedBox(height: 14),
            const CustomTextField(hint: "Expiry Date"),
            const SizedBox(height: 40),
            GreenButton(
              text: "Add",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
