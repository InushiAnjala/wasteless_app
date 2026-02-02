import 'package:flutter/material.dart';
import 'chef_home_screen.dart';

class NotInStockScreen extends StatefulWidget {
  const NotInStockScreen({super.key});

  @override
  State<NotInStockScreen> createState() => _NotInStockScreenState();
}

class _NotInStockScreenState extends State<NotInStockScreen> {
  // Controllers for three rows
  final List<TextEditingController> nameControllers = List.generate(
    3,
    (index) => TextEditingController(),
  );

  final List<TextEditingController> amountControllers = List.generate(
    3,
    (index) => TextEditingController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Removes the 3-dot menu
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFA8FBA8), Color(0xFFEFFEF1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
            child: Row(
              children: [
                // Home Button
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChefHomeScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.home, size: 32),
                ),

                const SizedBox(width: 20),

                // Title centered
                Expanded(
                  child: Center(
                    child: Text(
                      "Not in Stocks",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA8FBA8), Color(0xFFEFFEF1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // White box
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _editableRow(1, 0),
                  const SizedBox(height: 25),
                  _editableRow(2, 1),
                  const SizedBox(height: 25),
                  _editableRow(3, 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ROW UI — Name + Amount
  Widget _editableRow(int number, int index) {
    return Row(
      children: [
        Text(
          "$number.",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(width: 20),

        // Name Field
        Expanded(
          flex: 2,
          child: TextField(
            controller: nameControllers[index],
            decoration: const InputDecoration(
              hintText: "Name",
              hintStyle: TextStyle(color: Colors.black45),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(bottom: 5),
            ),
            style: const TextStyle(fontSize: 20),
          ),
        ),

        const SizedBox(width: 10),

        const Text("|", style: TextStyle(fontSize: 22, color: Colors.black45)),

        const SizedBox(width: 10),

        // Amount Field
        Expanded(
          flex: 3,
          child: TextField(
            controller: amountControllers[index],
            decoration: const InputDecoration(
              hintText: "Amount",
              hintStyle: TextStyle(color: Colors.black45),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(bottom: 5),
            ),
            style: const TextStyle(fontSize: 20),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
