# Atomy Receiver Admin App

행사 스태프가 Android 휴대폰에서 회원 QR을 스캔하고 통역기 대여·반납을 처리하는 Flutter 관리자 앱입니다.

## 포함 기능

- 회원 QR 스캔
- 회원번호 직접 검색
- 통역기 번호 연결 및 대여
- 중복 대여 오류 표시
- 통역기 번호 조회 및 반납
- 정상 반납 / 파손 / 분실 / 점검 필요 처리
- 10초 자동 갱신 실시간 Dashboard
- Netlify URL, 행사 코드, Staff PIN, Staff Name 저장
- 짙은 남색 + 흰색 + Atomy Blue 디자인

## 중요한 구조

앱은 Supabase 서비스 키를 포함하지 않습니다.

Android App → Netlify Functions → Supabase

따라서 기존 Netlify 사이트와 API가 먼저 정상 배포되어 있어야 합니다.

## 앱에서 처음 입력할 값

- Netlify site URL: `https://YOUR-SITE.netlify.app`
- Event code: Supabase events 테이블에 만든 행사 코드. 비워두면 가장 최근 활성 행사를 사용합니다.
- Staff name: 현장 직원 이름
- Staff PIN: Netlify 환경변수 `STAFF_PIN`과 같은 값

## APK 만드는 방법

### 준비

1. Flutter SDK 설치
2. Android Studio 설치
3. Android SDK 설치
4. USB 디버깅이 켜진 Android 휴대폰 연결

### 명령

프로젝트 폴더에서:

```bash
flutter pub get
flutter build apk --release
```

APK 위치:

```text
build/app/outputs/flutter-apk/app-release.apk
```

현재 프로젝트의 release signing은 테스트 편의를 위해 debug signing을 사용합니다. 내부 행사용 설치에는 사용할 수 있지만, 정식 배포 전에는 별도 keystore로 바꾸는 것이 좋습니다.

## 실행 테스트

```bash
flutter run
```

## 주의

- Android 6.0(API 23) 이상
- QR 스캔을 위해 카메라 권한 필요
- HTTPS Netlify 주소 사용
- 서비스 역할 키를 앱 코드에 넣지 마세요
