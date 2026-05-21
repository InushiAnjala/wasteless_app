import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../constants/colors.dart';

class RecipeScreen extends StatefulWidget {
  final String recipeText;
  const RecipeScreen({super.key, required this.recipeText});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  // Read the Gemini API key from --dart-define=GEMINI_API_KEY=...
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');
  final List<Content> conversation = [];
  GenerativeModel? _model;
  ChatSession? _chat;
  final TextEditingController _questionController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSaved = false;
  String? _errorMessage;
  String? _firestoreError;

  String? _resolvedApiKey;
  bool _useCloudFunction = false;

  Future<void> _saveRecipe(String recipeContent) async {
    if (_isSaved || _isSaving || recipeContent.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      String title = widget.recipeText;
      // Clean up the title if it's the raw prompt
      if (title.startsWith("Please provide a detailed food recipe for ")) {
        title = title
            .replaceAll("Please provide a detailed food recipe for ", "")
            .replaceAll(". Make it well-structured and easy to follow.", "")
            .trim();
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save recipe: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialRecipe();
    });
  }

  Future<void> _initializeAi() async {
    _firestoreError = null;

    // 0. Try fetching from .env file (preferred/secure local dev setup)
    try {
      final dotenvKey = dotenv.env['GEMINI_API_KEY'];
      if (dotenvKey != null && dotenvKey.trim().isNotEmpty) {
        _resolvedApiKey = dotenvKey.trim();
        _initializeLocalChat(_resolvedApiKey!);
        return;
      }
    } catch (e) {
      debugPrint("Error reading GEMINI_API_KEY from .env file: $e");
    }

    // 1. Check if environment variable is set
    if (apiKey.isNotEmpty) {
      _resolvedApiKey = apiKey;
      _initializeLocalChat(_resolvedApiKey!);
      return;
    }

    // 2. Try fetching from Firestore
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('gemini')
          .get();
      if (doc.exists && doc.data() != null) {
        final key = doc.data()!['apiKey'] as String?;
        if (key != null && key.trim().isNotEmpty) {
          _resolvedApiKey = key.trim();
          _initializeLocalChat(_resolvedApiKey!);
          return;
        } else {
          _firestoreError = "Document exists, but 'apiKey' field is empty or missing.";
        }
      } else {
        _firestoreError = "Document 'app_settings/gemini' does not exist in Firestore.";
      }
    } catch (e) {
      _firestoreError = "Error fetching API key from Firestore: $e";
      debugPrint("Error fetching API key from Firestore: $e");
    }

    // 3. Fallback to Cloud Function
    _useCloudFunction = true;
  }

  void _initializeLocalChat(String key) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: key,
      systemInstruction: Content.system(
        "You are a professional chef. You provide clear, well-structured, and easy to follow food recipes using readily available ingredients. Format your responses in Markdown.",
      ),
    );
    _chat = _model!.startChat(history: conversation);
  }

  Future<void> _fetchInitialRecipe() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final prompt =
        "Please provide a detailed food recipe for ${widget.recipeText}. Make it well-structured and easy to follow.";

    try {
      // Resolve API key or Cloud Function setting
      if (_resolvedApiKey == null && !_useCloudFunction) {
        await _initializeAi();
      }

      String replyText;

      if (_useCloudFunction) {
        // Call Firebase Cloud Function
        final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('generateRecipe');
        
        // Map conversation list to the format expected by the Cloud Function
        final List<Map<String, String>> historyList = conversation.map((c) {
          final role = c.role == 'model' ? 'assistant' : 'user';
          final content = c.parts.whereType<TextPart>().map((p) => p.text).join('\n');
          return {
            'role': role,
            'content': content,
          };
        }).toList();

        final results = await callable.call(<String, dynamic>{
          'prompt': prompt,
          'conversation': historyList,
        });

        final data = results.data;
        if (data != null && data['reply'] != null) {
          replyText = data['reply'] as String;
        } else {
          throw Exception("Invalid response from recipe generator function.");
        }

        // Update local conversation history
        conversation.add(Content.text(prompt));
        conversation.add(Content.model([TextPart(replyText)]));
      } else {
        // Use local client SDK
        if (_chat == null) {
          throw Exception("API key not configured.");
        }
        final response = await _chat!.sendMessage(Content.text(prompt));
        replyText = response.text ?? "";
        if (!conversation.any((c) => c.parts.any((p) => p is TextPart && p.text == replyText))) {
          conversation.add(Content.model([TextPart(replyText)]));
        }
      }

      if (mounted) setState(() {});
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      debugPrint("FirebaseFunctionsException caught: [${e.code}] ${e.message}");
      String friendlyMessage;
      if (e.code == 'not-found' || e.code == 'unimplemented') {
        friendlyMessage = 'No Gemini API key or Cloud Function is configured.';
      } else {
        friendlyMessage = 'Cloud Function error: [${e.code}] ${e.message ?? e.toString()}';
      }
      setState(() => _errorMessage = friendlyMessage);
    } on PlatformException catch (e) {
      if (!mounted) return;
      debugPrint("PlatformException caught: $e");
      final errStr = e.toString().toLowerCase();
      String friendlyMessage;
      if (errStr.contains('not-found') ||
          errStr.contains('not_found') ||
          errStr.contains('firebase_functions') ||
          errStr.contains('unimplemented')) {
        friendlyMessage = 'No Gemini API key or Cloud Function is configured.';
      } else {
        friendlyMessage = 'Platform error: ${e.message ?? e.toString()}';
      }
      setState(() => _errorMessage = friendlyMessage);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      debugPrint("FirebaseException caught: [${e.code}] ${e.message}");
      setState(() => _errorMessage = 'Firebase error: [${e.code}] ${e.message ?? e.toString()}');
    } catch (e) {
      if (!mounted) return;
      debugPrint("Generic Exception caught: $e");
      final errStr = e.toString().toLowerCase();
      String friendlyMessage;
      
      if (errStr.contains('503') ||
          errStr.contains('unavailable') ||
          errStr.contains('high demand')) {
        friendlyMessage =
            'The AI is currently experiencing high demand. Please try again in a moment.';
      } else if (errStr.contains('network') ||
          errStr.contains('socketexception')) {
        friendlyMessage =
            'No internet connection. Please check your network and try again.';
      } else if (errStr.contains('api key') ||
          errStr.contains('not configured') ||
          errStr.contains('api_key') ||
          errStr.contains('not-found') ||
          errStr.contains('not_found') ||
          errStr.contains('firebase_functions') ||
          errStr.contains('unimplemented')) {
        friendlyMessage = 'No Gemini API key or Cloud Function is configured.';
      } else {
        friendlyMessage = 'Something went wrong: $e';
      }
      setState(() => _errorMessage = friendlyMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  bool get _isConfigError {
    if (_errorMessage == null) return false;
    final msg = _errorMessage!.toLowerCase();
    return msg.contains('no gemini api key') ||
        msg.contains('api key not configured') ||
        msg.contains('not-found') ||
        msg.contains('not_found') ||
        msg.contains('firebase_functions');
  }

  Widget _buildSetupGuide(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber.shade200, width: 2),
              ),
              child: Icon(
                Icons.settings_suggest_rounded,
                size: 48,
                color: Colors.amber.shade700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "AI Configuration Required",
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "To use the Chef AI Assistant, please set up a Gemini API Key using one of the three options below:",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          if (_firestoreError != null || _errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Diagnostics / Error Details:",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_firestoreError != null)
                    Text(
                      "• Firestore: $_firestoreError",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  if (_errorMessage != null)
                    Text(
                      "• Fallback: $_errorMessage",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade700,
                        fontFamily: 'monospace',
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildSetupOptionCard(
            theme: theme,
            colorScheme: colorScheme,
            icon: Icons.storage_rounded,
            title: "Option 1: Firestore Collection (Recommended)",
            subtitle: "Easiest for local development. App reads key dynamically.",
            content: "Create a Firestore document:\n"
                "• Collection: app_settings\n"
                "• Document ID: gemini\n"
                "• Field: apiKey (String value)",
            isCode: false,
          ),
          const SizedBox(height: 16),
          _buildSetupOptionCard(
            theme: theme,
            colorScheme: colorScheme,
            icon: Icons.terminal_rounded,
            title: "Option 2: Dart Define Flag",
            subtitle: "Pass key directly during build/run command:",
            content: "flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY",
            isCode: true,
          ),
          const SizedBox(height: 16),
          _buildSetupOptionCard(
            theme: theme,
            colorScheme: colorScheme,
            icon: Icons.cloud_done_rounded,
            title: "Option 3: Firebase Cloud Function",
            subtitle: "Deploy the secure Cloud Function with your key:",
            content: "firebase functions:secrets:set GEMINI_API_KEY=\"YOUR_KEY\"\n"
                "firebase deploy --only functions",
            isCode: true,
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _fetchInitialRecipe,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Recheck Configuration'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSetupOptionCard({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required String subtitle,
    required String content,
    required bool isCode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          if (isCode)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                content,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> sendUserQuestion() async {
    final userQuestion = _questionController.text.trim();
    if (userQuestion.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      String replyText;
      if (_useCloudFunction) {
        final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('generateRecipe');
        
        // Map conversation list to the format expected by the Cloud Function
        final List<Map<String, String>> historyList = conversation.map((c) {
          final role = c.role == 'model' ? 'assistant' : 'user';
          final content = c.parts.whereType<TextPart>().map((p) => p.text).join('\n');
          return {
            'role': role,
            'content': content,
          };
        }).toList();

        final results = await callable.call(<String, dynamic>{
          'prompt': userQuestion,
          'conversation': historyList,
        });

        final data = results.data;
        if (data != null && data['reply'] != null) {
          replyText = data['reply'] as String;
        } else {
          throw Exception("Invalid response from recipe generator function.");
        }

        // Update local conversation history
        conversation.add(Content.text(userQuestion));
        conversation.add(Content.model([TextPart(replyText)]));
      } else {
        if (_chat == null) {
          throw Exception("API key not configured.");
        }
        final response = await _chat!.sendMessage(Content.text(userQuestion));
        replyText = response.text ?? "";
        if (!conversation.any((c) => c.parts.any((p) => p is TextPart && p.text == replyText))) {
          conversation.add(Content.model([TextPart(replyText)]));
        }
      }

      _questionController.clear();
      if (mounted) setState(() {});
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      String friendlyMessage = (e.code == 'not-found' || e.code == 'unimplemented')
          ? 'Cloud Function generateRecipe is not deployed/found.'
          : 'Cloud Function error: [${e.code}] ${e.message ?? e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get AI reply: $friendlyMessage')),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      final errStr = e.toString().toLowerCase();
      String friendlyMessage;
      if (errStr.contains('not-found') ||
          errStr.contains('not_found') ||
          errStr.contains('firebase_functions')) {
        friendlyMessage = 'Cloud Function generateRecipe is not deployed/found.';
      } else {
        friendlyMessage = 'Platform error: ${e.message ?? e.toString()}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get AI reply: $friendlyMessage')),
      );
    } catch (e) {
      if (!mounted) return;
      final errStr = e.toString().toLowerCase();
      String friendlyMessage;
      if (errStr.contains('not-found') ||
          errStr.contains('not_found') ||
          errStr.contains('firebase_functions')) {
        friendlyMessage = 'Cloud Function generateRecipe is not deployed/found.';
      } else {
        friendlyMessage = '$e';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get AI reply: $friendlyMessage')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract the latest assistant message for display
    final String recipeContent = conversation.isEmpty
        ? ""
        : conversation.last.parts
              .whereType<TextPart>()
              .map((p) => p.text)
              .join('\n');

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
                                Icon(
                                  Icons.menu_book_rounded,
                                  color: colorScheme.primary,
                                ),
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
                                : _errorMessage != null
                                    ? (_isConfigError
                                        ? _buildSetupGuide(context, theme, colorScheme)
                                        : SingleChildScrollView(
                                            padding: const EdgeInsets.all(24),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                const SizedBox(height: 32),
                                                Icon(
                                                  Icons.wifi_tethering_error_rounded,
                                                  size: 56,
                                                  color: Colors.orange.shade400,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  _errorMessage!,
                                                  textAlign: TextAlign.center,
                                                  style: theme.textTheme.bodyLarge?.copyWith(
                                                    color: Colors.black54,
                                                    height: 1.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                Center(
                                                  child: ElevatedButton.icon(
                                                    onPressed: _fetchInitialRecipe,
                                                    icon: const Icon(
                                                      Icons.refresh_rounded,
                                                    ),
                                                    label: const Text('Try Again'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          colorScheme.primary,
                                                      foregroundColor: Colors.white,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 24,
                                                            vertical: 12,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(16),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 32),
                                              ],
                                            ),
                                          ))
                                : SingleChildScrollView(
                                    padding: const EdgeInsets.all(24),
                                    physics: const BouncingScrollPhysics(),
                                    child: Text(
                                      recipeContent,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
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
                                        hintStyle: theme.textTheme.bodyMedium
                                            ?.copyWith(color: Colors.black38),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
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
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isSaved ? theme.colorScheme.primary : null,
                  ),
          )
        else
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
      ],
    );
  }
}
