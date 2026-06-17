import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/api_models.dart';
import '../models/history_item.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final ApiService api = ApiService();
  final HistoryService historyService = HistoryService();

  XFile? selectedImage;
  ImageAnalysisResponse? imageResult;
  String? errorMessage;
  bool loading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = image;
        imageResult = null;
        errorMessage = null;
      });
    }
  }

  Future<void> analyzeImage() async {
    if (selectedImage == null) {
      setState(() {
        errorMessage = "Please select an image";
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
      imageResult = null;
    });

    try {
      final result = await api.analyzeImage(selectedImage!);

      await historyService.saveHistory(
        HistoryItem(
          type: "image",
          input: selectedImage!.name,
          result: result.visualLabel,
          confidence: result.visualConfidence,
          timestamp: DateTime.now(),
        ),
      );

      setState(() {
        imageResult = result;
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
            // 1. Image Preview & Drop Zone Placeholder
            GestureDetector(
              onTap: loading ? null : pickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 240,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedImage != null
                        ? Colors.transparent
                        : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: selectedImage != null
                      ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(selectedImage!.path),
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay to make change-button readable
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black54, Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white24,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: loading ? null : pickImage,
                          icon: const Icon(Icons.photo_library_rounded, size: 18),
                          label: const Text("Change"),
                        ),
                      ),
                    ],
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_rounded,
                        size: 48,
                        color: theme.colorScheme.primary.withOpacity(0.8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Tap to upload an image",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Supports JPG, PNG",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[600] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Action Trigger Button / Loading indicator
            if (selectedImage != null && imageResult == null)
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
                onPressed: analyzeImage,
                icon: const Icon(Icons.analytics_rounded),
                label: const Text("Analyze Image", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),

            // 3. Error Alert Design
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

            // 4. Detailed Beautiful Analytics Cards
            if (imageResult != null) ...[
              const SizedBox(height: 24),
              Text(
                "Analysis Results",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Overview Section
              _buildMetricCard(
                context: context,
                title: "Content & Context",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            imageResult!.contentType.toUpperCase(),
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          "${imageResult!.contentConfidence.toStringAsFixed(1)}% Match",
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: imageResult!.contentConfidence / 100,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Visual Labeling Card
              _buildMetricCard(
                context: context,
                title: "Primary Visual Subject",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      imageResult!.visualLabel,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: imageResult!.visualConfidence / 100,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Confidence: ${imageResult!.visualConfidence.toStringAsFixed(1)}%",
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Text Extraction Card
              _buildMetricCard(
                context: context,
                title: "Extracted Overlay Text",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        imageResult!.extractedText.isEmpty ? "No readable text detected" : imageResult!.extractedText,
                        style: TextStyle(
                          fontStyle: imageResult!.extractedText.isEmpty ? FontStyle.italic : FontStyle.normal,
                          color: imageResult!.extractedText.isEmpty ? Colors.grey : null,
                        ),
                      ),
                    ),
                    if (imageResult!.extractedText.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.emoji_emotions_rounded, size: 18, color: theme.colorScheme.secondary),
                              const SizedBox(width: 6),
                              Text("Sentiment: ${imageResult!.textSentiment}"),
                            ],
                          ),
                          Text("${imageResult!.textConfidence.toStringAsFixed(1)}% certainty"),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Related Tags Card
              _buildMetricCard(
                context: context,
                title: "Detected Tags & Features",
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: imageResult!.visualLabels.map((label) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                      ),
                      child: Text(
                        "${label.label} • ${label.confidence.toStringAsFixed(0)}%",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ]
          ],
        ),
      ),
    );
  }

  // Reusable card structure utility to clean up nested block hierarchies
  Widget _buildMetricCard({required BuildContext context, required String title, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}