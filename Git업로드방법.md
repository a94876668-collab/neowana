# GitHub 업로드 방법

## ❌ 웹 드래그 업로드가 안 될 때

"Yowza, that's a lot of files. Try uploading fewer than 100 at a time." 오류가 나면  
**Git 명령어**로 올리세요.

---

## 📌 방법: Git으로 업로드

### 1단계: GitHub 저장소 만들기

1. [github.com/new](https://github.com/new) 접속
2. **Repository name**: `neowana`
3. **Create repository** 클릭
4. 나온 주소 복사 (예: `https://github.com/내아이디/neowana.git`)

---

### 2단계: 터미널에서 명령 실행

```bash
cd C:\Users\USER-PC\Desktop\랜챗
git init
git add .
git commit -m "너와나 앱 첫 업로드"
git remote add origin https://github.com/내아이디/neowana.git
git branch -M main
git push -u origin main
```

**내아이디**를 본인 GitHub 아이디로 바꾸세요.

---

### 3단계: git push 할 때 로그인

`git push` 할 때 GitHub 인증이 필요합니다.

| 입력하는 것 | 설명 |
|-------------|------|
| **Username** | GitHub 아이디 |
| **Password** | **비밀번호 아님!** → Personal Access Token 입력 |

---

### Personal Access Token 만들기

1. GitHub 로그인
2. 우측 상단 **프로필 아이콘** → **Settings**
3. 왼쪽 맨 아래 **Developer settings**
4. **Personal access tokens** → **Tokens (classic)**
5. **Generate new token (classic)**
6. **Note**: `neowana-upload` (아무 이름)
7. **Expiration**: 90 days 또는 No expiration
8. **권한**: `repo` 체크
9. **Generate token** 클릭
10. **생성된 토큰 복사** (한 번만 보임! 저장해두기)

---

### 4단계: push 할 때

```
Username for 'https://github.com': 본인아이디
Password for 'https://본인아이디@github.com': [복사한 토큰 붙여넣기]
```

- Password 칸에 **비밀번호 대신 토큰** 입력
- 토큰은 한 번 저장해두면 다음에도 사용 가능

---

## ✅ 이미 한 번 push 했다면?

- Git이 로그인 정보를 저장했을 수 있어서, `git push`가 자동으로 될 수 있습니다.
- 나중에 다시 push 할 때 토큰/로그인을 물어보면, 위 방법대로 진행하면 됩니다.

---

## 📋 요약

1. GitHub에서 저장소 생성
2. 터미널에서 `git init` ~ `git push` 실행
3. Username: GitHub 아이디 / Password: Personal Access Token
