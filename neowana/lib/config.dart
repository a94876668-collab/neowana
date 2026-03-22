import 'package:flutter/foundation.dart';

/// 서버 URL 설정
/// - 웹(Chrome): localhost
/// - Android 에뮬레이터: 10.0.2.2 (호스트 PC)
/// - 실제 기기: PC의 IP 주소로 변경 필요 (예: 192.168.0.10)
String get serverUrl {
  if (kIsWeb) {
    return 'http://localhost:3000';
  }
  // Android 에뮬레이터는 10.0.2.2로 호스트 PC 접근
  return 'http://10.0.2.2:3000';
}
