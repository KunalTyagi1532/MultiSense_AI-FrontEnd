import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../models/api_models.dart';

class ApiService {
  static const String baseUrl =
      "https://kunaltyagi1532-multisense-ai.hf.space";

  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  Future<TextAnalysisResponse> analyzeText(
      String text,
      ) async {
    try {
      final response = await dio.post(
        "$baseUrl/analyze-text",
        queryParameters: {
          "text": text,
        },
      );

      return TextAnalysisResponse.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        _handleDioError(e),
      );
    }
  }

  Future<ImageAnalysisResponse> analyzeImage(
      XFile image,
      ) async {
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          image.path,
        ),
      });

      final response = await dio.post(
        "$baseUrl/analyze-image",
        data: formData,
      );

      return ImageAnalysisResponse.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        _handleDioError(e),
      );
    }
  }

  String _handleDioError(
      DioException e,
      ) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timeout";

      case DioExceptionType.receiveTimeout:
        return "Server took too long to respond";

      case DioExceptionType.sendTimeout:
        return "Request timeout";

      case DioExceptionType.connectionError:
        return "Cannot connect to backend server";

      case DioExceptionType.badResponse:
        return e.response?.data["detail"]
            ?.toString() ??
            "Server error";

      default:
        return "Something went wrong";
    }
  }
}