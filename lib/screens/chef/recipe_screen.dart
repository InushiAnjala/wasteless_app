import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/colors.dart';

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
  bool _isSaving = false;
  bool _isSaved = false;

  Future<void> _saveRecipe(String recipeContent) async {
    if (_isSaved || _isSaving || recipeContent.isEmpty) return;
    
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      String title = widget.recipeText;
      // Clean up the title if it's the raw prompt
      if (title.startsWith("Please provide a detailed food recipe for ")) {
        title = title.replaceAll("Please provide a detailed food recipe for ", "").replaceAll(". Make it well-structured and easy to follow.", "").trim();
      }

      await FirebaseFirestore.instance.collection('saved_recipes').add({
        'userId': user.uid,
        'title': title,
        'content': recipeContent,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => _isSaved = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe saved successfully!'),
            backgroundColor: Color(0xFF1E9E5A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save recipe: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract the latest assistant message for display
    final String recipeContent =
        conversation.isEmpty
            ? ""
            : conversation.last.parts.whereType<TextPart>().map((p) => p.text).join('\n');

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.15),
              colorScheme.background,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _Header(
                  onBack: () => Navigator.pop(context),
                  onSave: () => _saveRecipe(recipeContent),
                  isSaving: _isSaving,
                  isSaved: _isSaved,
                  showSave: conversation.length > 1,
                ),

                const SizedBox(height: 24),

                // Main card
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.05),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black.withOpacity(0.05),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.menu_book_rounded, color: colorScheme.primary),
                                const SizedBox(width: 12),
                                Text(
                                  "Recipe Instructions",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Recipe content area
                          Expanded(
                            child: _isLoading && conversation.length <= 1
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: colorScheme.primary,
                                    ),
                                  )
                                : SingleChildScrollView(
                                    padding: const EdgeInsets.all(24),
                                    physics: const BouncingScrollPhysics(),
                                    child: Text(
                                      recipeContent,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        height: 1.6,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 8),

                          // Q&A bar
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.05),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: TextField(
                                      controller: _questionController,
                                      enabled: !_isLoading,
                                      decoration: InputDecoration(
                                        hintText: "Ask about this recipe...",
                                        border: InputBorder.none,
                                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.black38,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      onSubmitted: (_) => sendUserQuestion(),
                                    ),
                                  ),
                                  _isLoading
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colorScheme.primary,
                                          ),
                                        )
                                      : IconButton(
                                          icon: const Icon(Icons.send_rounded),
                                          color: colorScheme.primary,
                                          onPressed: sendUserQuestion,
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onSave;
  final bool isSaving;
  final bool isSaved;
  final bool showSave;

  const _Header({
    required this.onBack,
    this.onSave,
    this.isSaving = false,
    this.isSaved = false,
    this.showSave = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chef AI Assistant',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Professional cooking advice',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightText,
                ),
              ),
            ],
          ),
        ),
        if (showSave)
          IconButton.filledTonal(
            onPressed: isSaving || isSaved ? null : onSave,
            icon: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isSaved ? theme.colorScheme.primary : null,
                  ),
          )
        else
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
          ),
      ],
    );
  }
}
