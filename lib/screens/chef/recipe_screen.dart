import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class RecipeScreen extends StatefulWidget {
  final String recipeText;
  const RecipeScreen({super.key, required this.recipeText});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  // TODO: Add your Gemini API key here
  static const String apiKey = "AIzaSyDCNY1jlSMYFaXmHdpabTms4w6ga0ef8lY";
  final List<Content> conversation = [];
  late final GenerativeModel model;
  late final ChatSession chat;
  final TextEditingController _questionController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(
        "You are a professional chef. You provide clear, well-structured, and easy to follow food recipes using readily available ingredients. Format your responses in Markdown.",
      ),
    );
    chat = model.startChat(history: conversation);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialRecipe();
    });
  }

  Future<void> _fetchInitialRecipe() async {
    final prompt =
        "Please provide a detailed food recipe for ${widget.recipeText}. Make it well-structured and easy to follow.";

    try {
      if (apiKey == "YOUR_API_KEY_HERE") {
        throw Exception("You must replace YOUR_API_KEY_HERE with your actual Gemini API key in recipe_screen.dart");
      }
      final response = await chat.sendMessage(Content.text(prompt));
      conversation.add(Content.model([TextPart(response.text ?? "")]));
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate recipe: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> sendUserQuestion() async {
    final userQuestion = _questionController.text.trim();
    if (userQuestion.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final response = await chat.sendMessage(Content.text(userQuestion));
      conversation.add(Content.model([TextPart(response.text ?? "")]));
      _questionController.clear();
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get AI reply: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract the latest assistant message for display
    final String recipeContent =
        conversation.isEmpty
            ? ""
            : conversation.last.parts.whereType<TextPart>().map((p) => p.text).join('\n');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9DE8B4), Color(0xFFF4FFF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card with back
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.16),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25C06D),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.22),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "AI Food Recipes",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Generated ideas from your items",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Main card
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE7F1EA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 18),
                        // Title row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Text(
                            "AI Recipe",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Recipe content area
                        Expanded(
                          child: _isLoading && conversation.length <= 1
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF25C06D),
                                  ),
                                )
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 6,
                                  ),
                                  child: Text(
                                    recipeContent,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                        ),

                        const SizedBox(height: 8),

                        // Search inside recipe bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE0E9E3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  size: 20,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _questionController,
                                    enabled: !_isLoading,
                                    decoration: const InputDecoration(
                                      hintText: "Search inside recipe...",
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (_) => sendUserQuestion(),
                                  ),
                                ),
                                IconButton(
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.send,
                                          color: Color(0xFF25C06D),
                                        ),
                                  onPressed: _isLoading
                                      ? null
                                      : sendUserQuestion,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Unused widget declarations removed

// Unused widget declarations removed
