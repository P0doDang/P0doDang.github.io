---
title: "[Knights Frontier] 블로그 디자인 수정 방법"
date: 2026-11-09 12:00:00 +0900
categories: ["기술문서/리서치"]
tags: [Knights Frontier, 블로그, 디자인, CSS, Jekyll]
---

## 🎨 CSS 적용 방법

> 글마다 CSS를 고칠 필요 없이, `assets/css/main.css`에 **한 번만** 추가하면 모든 글에서 쓸 수 있다.
{: .callout .pink}

1. `assets/css/main.css`를 연다.
2. `/* 본문 서식 */` 블록 안, 아래 `blockquote` 규칙 **바로 아래**에 새 스타일을 붙여 넣는다. 같은 선택자는 나중에 쓴 규칙이 이기므로 위치가 중요하다.

   ```css
   .prose blockquote { margin: 20px 0; padding: 2px 18px; border-left: 4px solid var(--ink); color: var(--mute); }
   ```

3. 저장하고 `tools/run.sh`로 로컬에서 확인한다.
4. 커밋하고 푸시하면 사이트에 반영된다.

---

## 🧩 추가한 스타일

| 요소 | 쓰는 법 | 용도 |
|---|---|---|
| 인용문 | `> 문장` | 핵심 문장 강조 (핑크 선) |
| 콜아웃 | 문단 아래 `{: .callout}` | 박스로 묶기 |
| 콜아웃 변형 | `{: .callout .pink}` / `{: .callout .hot}` | 핑크 테두리 / 검은 강조 카드 |
| 형광펜 | `<mark>구절</mark>` | 핵심 구절 표시 |
| 접기 | `<details markdown="1">` | 긴 내용 숨기기 |

### 콜아웃

```markdown
> **보안 분야의 방향 정하기**: 포렌식에 관심이 가장 많다.
>
> **사람 얻기**: 3기 동료들과 가까워지고 싶다.
{: .callout .pink}
```

여러 문단을 한 박스로 묶을 때는 `>` 인용문 아래에, 한 문단일 때는 문단 바로 아래 줄에 붙인다.

### 접기

```markdown
<details markdown="1">
<summary>제목</summary>

내용…

</details>
```

`markdown="1"`을 빼면 안쪽 마크다운이 적용되지 않는다. `<summary>` 아래와 `</details>` 위에는 빈 줄을 둔다.

---

## 🛠️ 자주 하는 수정

- **색 바꾸기**: `main.css` 맨 위 `:root` 변수(`--accent` 등)만 바꾸면 전체에 적용되고, 다크 모드는 `[data-theme="dark"]` 쪽 변수를 바꾼다.
- **글꼴 바꾸기**: `--font-body`, `--font-mono` 변수를 바꾼다.
- **본문 너비 / 글자 크기**: `.prose`의 `max-width`, `font-size`를 바꾼다.

<details markdown="1">
<summary>스타일이 안 먹을 때 확인할 것</summary>

- `{: .callout}`이 **문단/인용문 바로 다음 줄**에 붙어 있는지 (사이에 빈 줄이 있으면 안 된다)
- CSS를 기존 `blockquote` 규칙보다 **아래**에 넣었는지
- 브라우저 캐시 때문에 그대로일 수 있으니 강력 새로고침(Ctrl+Shift+R)

</details>
