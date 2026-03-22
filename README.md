# 너와나 - 랜덤 채팅 앱

## 프로젝트 구조

```
랜챗/
├── neowana/          # Flutter 앱
├── server/           # Node.js 백엔드 서버
└── README.md
```

## 실행 방법

### 1. 서버 실행 (필수!)

```bash
cd server
npm start
```

서버가 `http://localhost:3000`에서 실행됩니다.

### 2. 앱 실행

**웹 (Chrome):**
```bash
cd neowana
flutter run -d chrome
```

**Android 에뮬레이터:**
```bash
cd neowana
flutter run -d android
```

## 테스트 방법

1. 서버 실행
2. **Chrome 창 2개**를 열고 각각 `flutter run -d chrome` 실행 (또는 하나는 웹에서 직접 접속)
3. 두 창 모두에서 "매칭 시작" 클릭
4. 자동으로 매칭되면 채팅 가능!

## 서버 URL 변경

실제 Android 기기에서 테스트할 때는 `neowana/lib/config.dart`에서 서버 URL을 PC의 IP 주소로 변경하세요.

예: `http://192.168.0.10:3000`
