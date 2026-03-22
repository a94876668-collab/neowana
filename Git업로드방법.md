# GitHub 업로드 방법 (파일 많을 때)

웹에서 드래그 업로드가 안 되면 **Git 명령어**로 올리세요.

---

## 1. GitHub 저장소 만들기

1. [github.com](https://github.com) 로그인
2. **+** → **New repository**
3. Repository name: `neowana`
4. **Create repository** (빈 저장소)
5. 생성된 페이지의 **URL 복사** (예: `https://github.com/내아이디/neowana.git`)

---

## 2. 터미널에서 업로드

**Cursor**에서 터미널 열기 (또는 명령 프롬프트)

### 2-1. 랜챗 폴더로 이동

```bash
cd C:\Users\USER-PC\Desktop\랜챗
```

### 2-2. Git 초기화

```bash
git init
```

### 2-3. 파일 추가 (필요한 것만 - node_modules, build 등 제외됨)

```bash
git add .
```

### 2-4. 커밋

```bash
git commit -m "너와나 앱 첫 업로드"
```

### 2-5. GitHub 연결

```bash
git remote add origin https://github.com/내아이디/neowana.git
```
↑ **내아이디**를 본인 GitHub 아이디로 바꾸기

### 2-6. 업로드

```bash
git branch -M main
git push -u origin main
```

---

## 3. GitHub 로그인

`git push` 할 때 GitHub 아이디/비밀번호 묻습니다.

- **비밀번호**: GitHub에서 비밀번호 대신 **Personal Access Token** 사용
- 생성: GitHub → Settings → Developer settings → Personal access tokens → Generate new token
- 권한: `repo` 체크

---

## 4. 완료

저장소 페이지 새로고침하면 `server`, `neowana` 폴더가 보입니다.
