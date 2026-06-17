import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../models/history_item.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';

class TextScreen extends StatefulWidget {
  const TextScreen({super.key});

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  final ApiService api = ApiService();
  final HistoryService historyService = HistoryService();
  final TextEditingController controller = TextEditingController();

  bool loading = false;
  String? errorMessage;
  TextAnalysisResponse? textResult;

  @override
  void initState() {
    super.initState();
    // Triggers a rebuild when typing to dynamically show/hide the clear button
    controller.addListener(() => setState(() {}));
  }

  Future<void> analyzeText() async {
    if (controller.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Please enter some text";
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
      textResult = null;
    });

    try {
      final result = await api.analyzeText(controller.text);

      await historyService.saveHistory(
        HistoryItem(
          type: "text",
          input: controller.text,
          result: result.overallSentiment,
          confidence: 100,
          timestamp: DateTime.now(),
        ),
      );

      setState(() {
        textResult = result;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  // Helper method to get color themes based on the sentiment type
  Color _getSentimentColor(String sentiment, BuildContext context) {
    final s = sentiment.toLowerCase();
    if (s.contains('pos') || s.contains('good') || s.contains('happy')) return Colors.green;
    if (s.contains('neg') || s.contains('bad') || s.contains('sad')) return Colors.red;
    return Theme.of(context).colorScheme.outline;
  }

  // Helper method to get descriptive context icons for sentiments
  IconData _getSentimentIcon(String sentiment) {
    final s = sentiment.toLowerCase();
    if (s.contains('pos') || s.contains('good')) return Icons.sentiment_very_satisfied_rounded;
    if (s.contains('neg') || s.contains('bad')) return Icons.sentiment_very_dissatisfied_rounded;
    return Icons.sentiment_neutral_rounded;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // AppBar removed since HomeScreen provides it globally

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Text Sentiment Analysis",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // 1. Premium Input Field
            TextField(
              controller: controller,
              maxLines: 5,
              maxLength: 500,
              style: const TextStyle(fontSize: 15, height: 1.4),
              decoration: InputDecoration(
                hintText: "Paste or type your social media copy here...",
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
                counterStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500]),
                suffixIcon: controller.text.isNotEmpty
                    ? Padding(
                  padding: const EdgeInsets.only(bottom: 60), // Aligns cross button to top right corner
                  child: IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () => controller.clear(),
                  ),
                )
                    : null,
              ),
            ),
            const SizedBox(height: 12),

            // 2. Action Trigger Button
            if (textResult == null)
              loading
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
                  : FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: analyzeText,
                icon: const Icon(Icons.analytics_rounded),
                label: const Text("Analyze Text", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),

            // 3. Error Alert UI
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 4. Beautiful Analytical Breakdown Panel
            if (textResult != null) ...[
              const SizedBox(height: 20),

              // Overall Score Highlight Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.blueGrey[900]!, Colors.grey[900]!]
                        : [theme.colorScheme.primaryContainer.withOpacity(0.4), theme.colorScheme.primaryContainer.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.primaryContainer.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getSentimentColor(textResult!.overallSentiment, context).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getSentimentIcon(textResult!.overallSentiment),
                        color: _getSentimentColor(textResult!.overallSentiment, context),
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "OVERALL SENTIMENT",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            textResult!.overallSentiment,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: _getSentimentColor(textResult!.overallSentiment, context),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Segmented Sentence Analysis List
              Text(
                "Sentence Breakdown",
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: textResult!.results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = textResult!.results[index];
                  final sentimentColor = _getSentimentColor(item.sentiment, context);

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"${item.sentence}"',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(_getSentimentIcon(item.sentiment), size: 16, color: sentimentColor),
                                const SizedBox(width: 6),
                                Text(
                                  item.sentiment,
                                  style: TextStyle(color: sentimentColor, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            Text(
                              "${item.confidence.toStringAsFixed(1)}% Sure",
                              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: item.confidence / 100,
                            backgroundColor: sentimentColor.withOpacity(0.1),
                            color: sentimentColor,
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}