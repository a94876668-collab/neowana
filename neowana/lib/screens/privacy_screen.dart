import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보처리방침'),
        backgroundColor: Colors.deepPurple.shade400,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. 수집하는 정보',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              '본 서비스는 회원가입을 요구하지 않으며, 채팅 내용은 서버에 저장되지 않습니다. '
              '연결 식별을 위한 기술적 정보만 일시적으로 처리됩니다.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              '2. 정보 이용 목적',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              '수집된 정보는 서비스 제공, 신고 처리, 서비스 개선 목적으로만 활용됩니다.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              '3. 정보 보관',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              '채팅 메시지는 실시간으로만 전달되며 저장하지 않습니다. '
              '신고 시 필요한 최소 정보만 검토 목적으로 기록될 수 있습니다.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              '4. 제3자 제공',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              '이용자의 동의 없이 개인정보를 제3자에게 제공하지 않습니다. '
              '단, 법령에 따른 요청이 있는 경우는 예외입니다.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
