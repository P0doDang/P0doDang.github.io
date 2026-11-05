# P0doDang.github.io

테마 없이 직접 만든 Jekyll 블로그예요. https://p0dodang.github.io

## 폴더 구조

| 위치 | 역할 |
|---|---|
| `_config.yml` | 사이트 제목, 소개 문구(`tagline`), 주소 설정 |
| `_data/profile.yml` | 홈의 이름, "지금 하는 일", 소개 요약 |
| `_data/categories.yml` | 항상 보이는 상위 카테고리 6개와 설명 |
| `_posts/` | 글 (`YYYY-MM-DD-제목.md`) |
| `about.md` | 소개 페이지 |
| `_layouts/`, `_includes/` | 화면 틀 (홈, 글, 카테고리, 태그 등) |
| `assets/css/main.css` | 색, 글꼴, 간격 (맨 위 변수만 바꿔도 전체가 바뀜) |
| `assets/css/syntax.css` | 코드 블록 색 |
| `assets/img/` | 이미지, 파비콘 |

## 새 글 쓰기

`_posts/2026-11-05-my-post.md` 파일을 만들고 맨 위에 아래 형식을 적어요.

```markdown
---
title: 글 제목
date: 2026-11-05 12:00:00 +0900
categories: ["CTF/Wargame"]
tags: [pwn, bof]
---

본문
```

- `categories`는 `_data/categories.yml`의 이름과 똑같이 써요. 하위 카테고리는 `["블로그/기술문서", 리서치]`처럼 뒤에 붙여요 (2단계까지).
- 목록에 없는 상위 카테고리를 쓰면 자동으로 뒤에 추가돼요.
- `|` 문자는 표로 해석되니 `\|`로 써요.

## 로컬에서 미리보기

```bash
bundle install
bundle exec jekyll serve
```

http://127.0.0.1:4000 에서 확인해요.

## 배포

`main` 브랜치에 push하면 GitHub Actions가 빌드하고 링크를 검사한 뒤 배포해요.
