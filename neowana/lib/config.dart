/// 점검 모드 (true: 점검중 화면 표시, false: 정상 이용)
const bool isMaintenance = true;

/// 서버 URL 설정
/// - 웹(Chrome): localhost
/// - Android 에뮬레이터: 10.0.2.2 (호스트 PC)
/// - 실제 기기: PC의 IP 주소로 변경 필요 (예: 192.168.0.10)
String get serverUrl {
  // Railway 배포 서버
  return 'https://neowana-production.up.railway.app';
}
