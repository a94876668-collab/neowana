import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final String serverUrl;

  ChatService({this.serverUrl = 'http://localhost:3000'});

  String get _wsUrl =>
      serverUrl.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://') + '/ws';

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  void connect({
    required Function() onConnected,
    required Function(String) onError,
  }) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final msg = jsonDecode(data) as Map<String, dynamic>;
            if (!_messageController.isClosed) {
              _messageController.add(msg);
            }
          } catch (_) {}
        },
        onError: (e) {
          if (!_messageController.isClosed) {
            _messageController.add({'type': 'error', 'message': e.toString()});
          }
        },
        onDone: () {
          if (!_messageController.isClosed) {
            _messageController.add({'type': 'disconnected'});
          }
        },
      );
      onConnected();
    } catch (e) {
      onError('연결 실패: $e');
    }
  }

  void findMatch() {
    _send({'type': 'find_match'});
  }

  void cancelMatch() {
    _send({'type': 'cancel_match'});
  }

  void sendMessage(String message) {
    _send({'type': 'chat_message', 'message': message});
  }

  void reportUser() {
    _send({'type': 'report'});
  }

  void _send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    if (!_messageController.isClosed) {
      _messageController.close();
    }
  }

  bool get isConnected => _channel != null;
}
