class HistoryItem {
  final String type;
  final String input;
  final String result;
  final double confidence;
  final DateTime timestamp;

  HistoryItem({
    required this.type,
    required this.input,
    required this.result,
    required this.confidence,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "input": input,
      "result": result,
      "confidence": confidence,
      "timestamp": timestamp.toIso8601String(),
    };
  }

  factory HistoryItem.fromJson(
      Map<String, dynamic> json) {
    return HistoryItem(
      type: json["type"],
      input: json["input"],
      result: json["result"],
      confidence: json["confidence"],
      timestamp: DateTime.parse(
        json["timestamp"],
      ),
    );
  }
}