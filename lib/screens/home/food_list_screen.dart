import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';
import 'add_food_screen.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  String selectedCategory = "Veges";
  String searchText = "";

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
                // TOP BAR
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

                // SEARCH BAR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: "Search food",
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() => searchText = value.toLowerCase());
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // CATEGORY BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: categories.map(categoryButton).toList(),
                ),

                const SizedBox(height: 15),

                // FOOD LIST
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("foods")
                        .where("userId", isEqualTo: uid)
                        .where("section", isEqualTo: selectedCategory)
                        .orderBy("expiryDate")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No food items found"));
                      }

                      final docs = snapshot.data!.docs.where((doc) {
                        final name = (doc["name"] as String).toLowerCase();
                        return name.contains(searchText);
                      }).toList();

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;

                          final DateTime expiry =
                              (data["expiryDate"] as Timestamp).toDate();

                          final int daysLeft = expiry
                              .difference(DateTime.now())
                              .inDays;

                          String expiryText;
                          if (daysLeft == 0) {
                            expiryText = "Expires today";
                          } else if (daysLeft == 1) {
                            expiryText = "Expires tomorrow";
                          } else if (daysLeft < 0) {
                            expiryText = "Expired";
                          } else {
                            expiryText = "Expires in $daysLeft days";
                          }

                          return buildFoodBox(
                            docId: doc.id,
                            data: data,
                            expiry: expiryText,
                          );
                        },
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

  Widget categoryButton(String category) {
    final bool active = selectedCategory == category;

    return InkWell(
      onTap: () {
        setState(() => selectedCategory = category);
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

  Widget buildFoodBox({
    required String docId,
    required Map<String, dynamic> data,
    required String expiry,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["name"],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(expiry),
              ],
            ),
          ),

          Text(
            "${data["amount"]} ${data["unit"]}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          IconButton(
            icon: const Icon(Icons.edit, color: Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddFoodScreen(foodId: docId, foodData: data),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("foods")
                  .doc(docId)
                  .delete();
            },
          ),
        ],
      ),
    );
  }
}
