# APK 만들기 — GitHub Actions 클라우드 빌드

이 컴퓨터에 Flutter/Android SDK를 설치하지 않고도, GitHub에 올리면 자동으로 설치용 APK가 만들어집니다.

## 준비 (한 번만)

1. GitHub 계정으로 로그인 → **New repository** 로 빈 저장소 생성 (예: `atomy-receiver-admin-app`). Private 권장. README/.gitignore 는 추가하지 마세요(이미 있음).
2. 이 폴더(`atomy_receiver_admin_app`)가 저장소 루트가 되도록 push 합니다. 아래 명령을 이 폴더에서 실행하세요:

```bash
git remote add origin https://github.com/<내계정>/atomy-receiver-admin-app.git
git branch -M main
git push -u origin main
```

> 이 폴더는 이미 `git init` + 최초 커밋이 되어 있습니다. 위 3줄만 실행하면 됩니다.

## 빌드 & 다운로드

- push 하면 **Actions** 탭에서 `Build Android APK` 워크플로가 자동 실행됩니다. (수동 실행: Actions → 워크플로 선택 → **Run workflow**)
- 완료(약 5~10분)되면 실행 상세 페이지 하단 **Artifacts → `atomy-receiver-admin-apk`** 를 내려받으면 `app-release.apk` 가 들어 있습니다.

## APK 설치 (스태프 휴대폰)

1. APK 파일을 휴대폰으로 전송.
2. "출처를 알 수 없는 앱 설치" 허용 후 설치.
3. 앱 첫 실행 시 입력:
   - **Netlify site URL**: `https://<사이트>.netlify.app`
   - **Event code**: Supabase 에 만든 행사 코드 (비우면 최신 활성 행사)
   - **Staff name**: 현장 직원 이름
   - **Staff PIN**: Netlify 환경변수 `STAFF_PIN` 과 동일

## 참고

- 현재 릴리스 APK 는 **debug 서명**을 사용합니다. 내부 행사 사이드로드 설치용으로는 문제없지만, Google Play 정식 배포에는 별도 keystore 서명이 필요합니다.
- 빌드는 Flutter `3.24.5` (stable) 기준입니다. `.github/workflows/build-apk.yml` 에서 버전 변경 가능.
- Gradle wrapper 파일이 저장소에 없어도 워크플로가 빌드 시 자동 생성합니다.
