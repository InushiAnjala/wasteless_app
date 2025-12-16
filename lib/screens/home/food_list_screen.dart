import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  String selectedCategory = "Veges";

  final List<String> categories = ["Veges", "Meat", "Fruits", "Others"];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA0F5A0), Color(0xFFF2FFF2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ---------------- TOP BAR ----------------
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.home, size: 30),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const Center(
                      child: Text(
                        "Food List",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // ---------------- CATEGORY BUTTONS ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: categories.map(categoryButton).toList(),
                ),

                const SizedBox(height: 15),

                // ---------------- FIRESTORE LIST ----------------
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("foods")
                        .where("userId", isEqualTo: uid)
                        .where("section", isEqualTo: selectedCategory)
                        .orderBy("expiryDate", descending: false) // ✅ IMPORTANT
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No food items"));
                      }

                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          final DateTime expiry =
                              (data["expiryDate"] as Timestamp).toDate();

                          // -------- FIXED DATE LOGIC --------
                          final DateTime today = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                          );

                          final DateTime expiryOnly = DateTime(
                            expiry.year,
                            expiry.month,
                            expiry.day,
                          );

                          final int daysLeft = expiryOnly
                              .difference(today)
                              .inDays;

                          String expiryText;
                          if (daysLeft < 0) {
                            expiryText = "Expired";
                          } else if (daysLeft == 0) {
                            expiryText = "Expires today";
                          } else if (daysLeft == 1) {
                            expiryText = "Expires tomorrow";
                          } else {
                            expiryText = "Expires in $daysLeft days";
                          }

                          return buildFoodBox(
                            name: data["name"],
                            expiry: expiryText,
                            amount: "${data["amount"]} ${data["unit"]}",
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- CATEGORY BUTTON ----------------
  Widget categoryButton(String category) {
    final active = selectedCategory == category;

    return InkWell(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Text(
          category,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ---------------- FOOD CARD (UI UNCHANGED) ----------------
  Widget buildFoodBox({
    required String name,
    required String expiry,
    required String amount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(expiry),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
