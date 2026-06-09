import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env_loader.dart';

/// Gemini API 客户端服务类
class GeminiClient {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/';

  /// 执行内容生成请求
  static Future<String> generate(String prompt, {String? systemInstruction}) async {
    // 从环境变量中读取 API Key
    final apiKey = EnvLoader.get('GEMINI_API_KEY');
    
    // 如果未配置或保留默认占位值，则返回 ApiKeyError
    if (apiKey.isEmpty || apiKey == 'MY_GEMINI_API_KEY') {
      return 'ApiKeyError';
    }

    final url = Uri.parse('${_baseUrl}v1beta/models/gemini-3.5-flash:generateContent?key=$apiKey');

    // 组装 Gemini API 请求报文数据
    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      if (systemInstruction != null)
        'systemInstruction': {
          'parts': [
            {'text': systemInstruction}
          ]
        },
      'generationConfig': {
        'temperature': 0.7,
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates.first['content'] as Map?;
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts.first['text'] as String?;
            if (text != null && text.isNotEmpty) {
              return text;
            }
          }
        }
        return '抱歉，由于模型响应格式不匹配，无法生成艺术作品分析。';
      } else {
        // 请求失败时返回错误码和状态文本
        return 'Error: 服务器返回状态码 ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      // 捕获网络连接或超时异常
      return 'Error: 连接AI服务时发生网络错误，请稍后再试: $e';
    }
  }
}
