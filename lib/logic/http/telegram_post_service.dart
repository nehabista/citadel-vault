import 'api_exception.dart';
import 'base_http_services.dart';

class PostTelegramService extends BaseHttpService {
  @override
  String get baseUrl => "https://api.telegram.org";

  Future<bool> postToTelegram(
      {required TelegramBotPostModel body,
      Map<String, String>? headers}) async {
    try {
      final endPoint =
          "bot${body.token}/sendMessage?chat_id=${body.chatId}&text=${body.message}";
      final response = await get(endPoint);
      return response.statusCode == 200;
    } catch (e) {
      throw ApiException(message: e.toString(), code: 500);
    }
  }
}

class TelegramBotPostModel {
  final String token;
  final String chatId;
  final String message;

  TelegramBotPostModel({
    required this.token,
    required this.chatId,
    required this.message,
  });

  @override
  String toString() {
    return 'TelegramBotPostModel(token: $token, chatId: $chatId, message: $message)';
  }
}
