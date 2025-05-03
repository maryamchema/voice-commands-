// lib/features/task_manager/data/services/llm_api_service.dart

import 'dart:convert';

import 'package:dio/dio.dart';

class LLMApiService {
  final Dio dio;

  LLMApiService({required this.dio});

  Future<Map<String, dynamic>> processCommand(String input) async {
    print("------------------uuuuuuuuuuu------$input");
    try {
      final response = await dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyDJa6qIjODZbx2PwwgOlBjkJz63grY1XUU',
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text': '''
You are a task management assistant. Based on user input, extract and return JSON in the following format:
{
  "action": "create" | "update" | "delete",
  "title": "string",
   "oldTitle": "string",
  "description": "string (optional)",
  "scheduledTime": "yyyy-MM-ddTHH:mm:ss",
  "taskId": "string (optional)"
}
Ensure the output is strict JSON, no extra text or markdown.
'''
                },
                {'text': input}
              ]
            },
          ]
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final content =
          response.data['candidates'][0]['content']['parts'][0]['text'];

// Remove markdown code block wrappers if present
      final cleanedContent =
          content.replaceAll('```json', '').replaceAll('```', '').trim();

// Decode JSON safely
      final jsonMap = jsonDecode(cleanedContent);

      return jsonMap;
    } catch (e) {
      print('LLM processing error: $e');
      rethrow;
    }
  }
}
