import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이용약관'),
        backgroundColor: Colors.deepPurple.shade400,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '제1조 (목적)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              '본 약관은 너와나 서비스(이하 "서비스")의 이용 조건 및 절차에 관한 사항을 규정합니다.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              '제2조 (서비스 이용)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              '① 본 서비스는 만 14세 이상만 이용 가능합니다.\n'
              '② 이용자는 건전한 대화를 위해 노력하여야 합니다.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              '제3조 (금지 행위)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              '다음 행위는 금지됩니다.\n'
              '• 욕설, 비방, 괴롭힘\n'
              '• 음란물, 성희롱 관련 콘텐츠\n'
              '• 사기, 사생활 침해\n'
              '• 불법 정보 유포\n'
              '• 기타 타인에게 불쾌감을 주는 행위\n\n'
              '위반 시 서비스 이용이 제한될 수 있습니다.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              '제4조 (신고 및 차단)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              '① 이용자는 금지 행위를 발견 시 신고 기능을 이용할 수 있습니다.\n'
              '② 신고된 내용은 검토 후 필요한 조치가 이루어질 수 있습니다.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              '제5조 (면책)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              '① 이용자 간 발생한 분쟁에 대해 서비스 제공자는 책임을 지지 않습니다.\n'
              '② 금지 행위로 인한 법적 책임은 해당 이용자에게 있습니다.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
