# Color.do 프로젝트

Microsoft To-Do 앱을 참고하여 만든 Flutter 기반 할 일 관리 앱입니다.

## 프로젝트 구조

```
lib/
├── main.dart                    # 앱 시작점
├── bloc/                        # 상태 관리 (BLoC 패턴)
│   ├── task_bloc.dart          # 할 일 BLoC
│   ├── task_event.dart          # 할 일 이벤트
│   ├── task_state.dart         # 할 일 상태
│   ├── task_list_bloc.dart    # 할 일 목록 BLoC
│   ├── task_list_event.dart  # 할 일 목록 이벤트
│   ├── task_list_state.dart  # 할 일 목록 상태
│   └── bloc.dart             # BLoC exports
├── models/                     # 데이터 모델
│   ├── task.dart             # 할 일 모델
│   ├── task.g.dart          # 할 일 JSON 직렬화
│   ├── task_list.dart        # 할 일 목록 모델
│   ├── task_list.g.dart     # 할 일 목록 JSON 직렬화
│   └── models.dart          # Models exports
├── repositories/               # 데이터 접근 계층
│   ├── task_repository.dart   # 할 일 저장소
│   ├── task_list_repository.dart  # 할 일 목록 저장소
│   └── repositories.dart   # Repositories exports
├── screens/                   # 화면
│   ├── home_screen.dart    # 메인 화면 (할 일 목록, 중요함, 계획됨)
│   ├── add_task_screen.dart  # 할 일 추가 화면
│   ├── task_detail_screen.dart  # 할 일 상세 화면
│   ├── task_list_management_screen.dart  # 할 일 목록 관리 화면
│   └── screens.dart        # Screens exports
├── widgets/                   # 재사용 가능한 위젯
│   ├── task_tile.dart      # 할 일 타일 위젯
│   ├── task_list_tile.dart  # 할 일 목록 타일 위젯
│   └── widgets.dart       # Widgets exports
└── theme/                    # 테마
    └── app_theme.dart      # 앱 테마
```

## 주요 기능

1. **할 일 관리**
   - 할 일 추가/수정/삭제
   - 중요함 표시
   - 완료 표시
   - 계획된 날짜 설정

2. **할 일 목록**
   - 여러 목록 생성 가능
   - 색상 및 아이콘 지정
   - 좌측 사이드바에서 목록 선택

3. **뷰 유형**
   - 내 할 일: 선택된 목록의 할 일
   - 중요함: 중요 표시된 할 일
   - 계획됨: 날짜가 설정된 할 일

## 기술 스택

- Flutter 3.11.0
- flutter_bloc (상태 관리)
- sqflite (로컬 데이터베이스)
- equatable (이벤트/상태 비교)

## 빌드 및 실행

```bash
# 웹 빌드
flutter build web

# 개발 서버 실행
flutter run
```

## 히스토리

| 커밋 | 설명 |
|------|------|
| aba7770 | 초기 커밋: Color.do 앱 |
| de3f3e6 | SDK 버전 3.11.0으로 업데이트 |
| 78266b3 | BlocBuilder에서冗長한 할 일 로딩 제거 |
| 78772f1 | 할 일 목록 네비게이션용 사이드 드로워 추가 |