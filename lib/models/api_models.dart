class SentenceResult {
  final String sentence;
  final String sentiment;
  final double confidence;

  SentenceResult({
    required this.sentence,
    required this.sentiment,
    required this.confidence,
  });

  factory SentenceResult.fromJson(
      Map<String, dynamic> json,
      ) {
    return SentenceResult(
      sentence: json["sentence"] ?? "",
      sentiment: json["sentiment"] ?? "",
      confidence:
      (json["confidence"] ?? 0)
          .toDouble(),
    );
  }
}

class TextAnalysisResponse {
  final String text;
  final String overallSentiment;
  final List<SentenceResult>
  results;

  TextAnalysisResponse({
    required this.text,
    required this.overallSentiment,
    required this.results,
  });

  factory TextAnalysisResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return TextAnalysisResponse(
      text: json["text"] ?? "",

      overallSentiment:
      json[
      "overall_sentiment"] ??
          "",

      results:
      (json["results"] as List?)
          ?.map(
            (e) =>
            SentenceResult
                .fromJson(e),
      )
          .toList() ??
          [],
    );
  }
}

class VisualLabel {
  final String label;
  final double confidence;

  VisualLabel({
    required this.label,
    required this.confidence,
  });

  factory VisualLabel.fromJson(
      Map<String, dynamic> json,
      ) {
    return VisualLabel(
      label: json["label"] ?? "",
      confidence:
      (json["confidence"] ?? 0)
          .toDouble(),
    );
  }
}

class ImageAnalysisResponse {
  final String extractedText;

  final String textSentiment;

  final double textConfidence;

  final String contentType;

  final double contentConfidence;

  final String visualLabel;

  final double visualConfidence;

  final List<VisualLabel>
  visualLabels;

  ImageAnalysisResponse({
    required this.extractedText,
    required this.textSentiment,
    required this.textConfidence,
    required this.contentType,
    required this.contentConfidence,
    required this.visualLabel,
    required this.visualConfidence,
    required this.visualLabels,
  });

  factory ImageAnalysisResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return ImageAnalysisResponse(
      extractedText:
      json["extracted_text"] ?? "",

      textSentiment:
      json["text_sentiment"] ?? "",

      textConfidence:
      (json["text_confidence"] ??
          0)
          .toDouble(),

      contentType:
      json["content_type"] ?? "",

      contentConfidence:
      (json[
      "content_confidence"] ??
          0)
          .toDouble(),

      visualLabel:
      json["visual_label"] ?? "",

      visualConfidence:
      (json[
      "visual_confidence"] ??
          0)
          .toDouble(),

      visualLabels:
      (json["visual_labels"]
      as List?)
          ?.map(
            (e) =>
            VisualLabel
                .fromJson(e),
      )
          .toList() ??
          [],
    );
  }
}