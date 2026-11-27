---
title: "[Review] 보안 사고 분석 ②: Notepad++ 업데이트 하이재킹 (Chrysalis 백도어)"
date: 2026-11-24 14:00:00 +0900
categories: ["기술문서/리서치"]
tags: [사고 분석, Review, Supply Chain, Notepad++, APT]
---

# <toc>들어가며</toc>

Notepad++는 2003년부터 Don Ho가 개발·관리해 온 윈도우용 무료 소스코드 편집기다. 개발자라면 한 번쯤 써 봤을 만큼 널리 쓰이는 프로그램인데, 2025년 6월부터 12월까지 이 프로그램의 **업데이트 경로가 공격자에게 장악**되어 있었다.

흥미로운 점은 Notepad++ 코드에는 문제가 없었다는 것이다. 뚫린 곳은 웹사이트와 업데이트 서버를 맡고 있던 <mark>**공유 호스팅 업체의 서버**</mark>였고, 업데이터가 서버의 응답을 그대로 믿는 구조였기 때문에 공격이 성공했다. 이 글에서는 업데이트가 어떻게 하이재킹됐는지, 그리고 왜 막지 못했는지를 정리한다.

---
# <toc>사고 한눈에 보기</toc>

| 항목 | 내용 |
|---|---|
| 대상 | Notepad++. 윈도우용 무료 소스코드 편집기 |
| 공격 기간 | 2025년 6월 ~ 12월 2일 (실제 악성 업데이트 배포는 2025년 7~10월에 관찰됨) |
| 공개 | 2025년 12월 v8.8.9 보안 공지 → 2026년 2월 2일 조사 결과 공개 |
| 침해 지점 | Notepad++ 코드가 아니라, 웹사이트와 업데이트 서버를 맡고 있던 **공유 호스팅 업체의 서버** |
| 공격 방식 | 업데이터(WinGUp)의 요청을 공격자 서버로 돌려, **선택한 사용자에게만** 악성 업데이트 파일을 내려보냄 |
| 피해 | 약 12대 내외의 PC. 베트남·엘살바도르·호주의 개인, 필리핀 정부기관, 엘살바도르 금융기관, 베트남 IT 서비스 업체 (카스퍼스키 관측 기준) |
| 악성코드 | 새로운 백도어 Chrysalis, Cobalt Strike Beacon, Metasploit 다운로더 등 |
| 배후 (추정) | 중국 연계 APT 그룹 Lotus Blossom (Rapid7, 중간 수준 신뢰도) |

---
# <toc>용어 정리</toc>

뒤에서 계속 나오는 용어들이다. 필요할 때 펼쳐서 확인하면 된다.

<details markdown="1">
<summary>공급망과 업데이트 관련 용어</summary>

| 용어 | 설명 |
|---|---|
| 공급망 공격 (Supply Chain Attack) | 목표를 직접 공격하는 대신, 목표가 믿고 쓰는 소프트웨어·업데이트·외부 업체를 먼저 장악해 그 경로로 공격하는 방식 |
| 업데이터 (Updater) | 프로그램의 새 버전이 있는지 확인하고 내려받아 설치해 주는 작은 프로그램. Notepad++의 업데이터는 WinGUp(실행 파일 이름은 GUP.exe)이다 |
| 업데이트 매니페스트 | 업데이터가 서버에 물어봤을 때 돌아오는 "새 버전이 있고, 설치 파일은 이 주소에 있다"는 내용의 안내 파일. Notepad++는 XML 형식을 쓴다 |
| 공유 호스팅 (Shared Hosting) | 한 대의 서버를 여러 고객이 나눠 쓰는 웹 호스팅 방식. 저렴하지만 서버 관리는 호스팅 업체가 한다 |
| HTTPS | 웹 통신을 암호화하는 방식. 통신 중간에서 내용을 엿보거나 바꾸는 것은 막지만, **서버 자체가 장악되면** 그 서버가 보내는 내용은 그대로 믿게 된다 |
| 디지털 서명 / 코드 서명 | 파일을 만든 사람이 자신의 개인키로 파일에 서명해, 받는 사람이 "이 파일은 원래 개발자가 만들었고 중간에 바뀌지 않았다"는 것을 확인할 수 있게 하는 기술. 실행 파일에 하는 서명을 코드 서명이라고 한다 |
| 인증서 | 서명에 쓰인 키가 누구의 것인지 증명하는 전자 문서. 서명만 확인하고 인증서를 확인하지 않으면, 공격자가 자기 키로 서명한 파일도 통과할 수 있다 |
| XMLDSig | XML 문서에 디지털 서명을 붙이는 표준. 업데이트 매니페스트가 위조되지 않았는지 확인하는 데 쓴다 |

</details>

<details markdown="1">
<summary>악성코드 관련 용어</summary>

| 용어 | 설명 |
|---|---|
| APT | 지능형 지속 위협(Advanced Persistent Threat). 주로 국가 배후 조직이 특정 목표를 오랫동안 은밀하게 공격하는 것 |
| NSIS | 윈도우용 설치 파일을 만드는 오픈소스 도구. 정상 프로그램 설치에도 쓰이지만, 악성 파일을 한꺼번에 풀어 놓는 데도 자주 악용된다 |
| DLL 사이드로딩 | 정상 프로그램이 DLL(여러 프로그램이 공유하는 기능 모음 파일)을 불러올 때, 같은 이름의 악성 DLL을 옆에 두어 대신 불러오게 하는 기법. 실행 주체가 정상 프로그램이라 탐지를 피하기 쉽다 |
| 셸코드 (Shellcode) | 메모리에 올려 바로 실행할 수 있게 만든 작은 기계어 코드 |
| 백도어 (Backdoor) | 정상 인증 없이 시스템에 다시 들어올 수 있게 몰래 심어 둔 통로 |
| C2 서버 | Command and Control. 감염된 PC에 명령을 내리고 결과를 받는 공격자 서버 |
| 지속성 (Persistence) | 재부팅해도 악성코드가 다시 실행되도록 서비스나 시작 프로그램에 등록해 두는 것 |
| 리버스 셸 | 감염된 PC가 공격자 쪽으로 먼저 접속해, 공격자가 그 PC의 명령 창을 원격으로 쓰게 하는 것 |
| Cobalt Strike / Beacon | 원래 모의해킹용 상용 도구지만 공격자들이 많이 악용한다. Beacon은 감염 PC에 심어 원격 조종하는 에이전트다 |
| Metasploit | 공개된 침투 테스트 프레임워크. 취약점 공격과 추가 악성코드 다운로드 기능을 제공한다 |
| 난독화 / API 해싱 | 분석을 어렵게 하려고 코드나 문자열을 알아보기 어렵게 바꾸는 것. API 해싱은 사용할 윈도우 함수 이름을 그대로 두지 않고 해시값으로 바꿔 숨기는 기법이다 |
| IoC | 침해지표(Indicator of Compromise). 공격에 쓰인 IP, 도메인, 파일 해시처럼 감염 여부를 확인하는 단서 |

</details>

---
# <toc>사고 경과</toc>

```text
2025. 6.        Notepad++ 웹사이트가 있던 공유 호스팅 서버 침해 시작
2025. 7.~10.    선택된 사용자에게 악성 업데이트 배포
                → 약 한 달마다 C2 주소, 다운로더, 최종 악성코드를 바꿈 (카스퍼스키)
2025. 9. 2.     호스팅 업체의 정기 커널·펌웨어 업데이트로 공격자가 서버 접근 권한을 잃음
                → 그러나 호스팅 업체 내부 서비스의 자격 증명은 계속 보유
2025. 11.       외부 보안 전문가 분석상 공격은 11월 10일경 멈춤
                카스퍼스키도 11월 이후로는 악성코드 배포를 관측하지 못함
2025. 11. 18.   v8.8.8 배포: 업데이트 파일을 GitHub에서만 받도록 강제
2025. 12. 2.    호스팅 업체가 공격자의 내부 자격 증명 접근을 끊고 복구 완료
2025. 12. 9.    v8.8.9 배포: 설치 파일의 서명과 인증서를 검증하고, 실패하면 업데이트 중단
2026. 2. 2.     Notepad++ 조사 결과 공개, 새 호스팅 업체로 이전
                Rapid7, Chrysalis 백도어 분석과 Lotus Blossom 배후 추정 발표
2026. 2. 3.~    카스퍼스키, 서로 다른 감염 체인 3개와 추가 IoC 공개
2026. 2. 5.     이전 호스팅 업체가 제공한 IoC 공개
2026. 2. 중순   v8.9.2 배포: 서명된 매니페스트와 설치 파일 검증을 강제
```

### <toc2>처음 드러난 이상 징후</toc2>

처음 이상이 드러난 것은 Notepad++ 커뮤니티 포럼이었다. 한 사용자가 업데이터인 GUP.exe가 `%Temp%\AutoUpdater.exe`라는 알 수 없는 파일을 실행했고, 이 파일이 PC 정보를 수집하는 명령을 실행했다고 보고했다. 보안 연구자 Kevin Beaumont도 Notepad++를 업데이트한 뒤 침해를 당한 조직이 있다고 알렸다.

Bitdefender는 정상적인 WinGUp은 내부적으로 libcurl 라이브러리만 쓰고, curl.exe를 따로 실행하거나 PC 정보를 수집하지 않는다는 점을 짚었다. <mark>업데이터가 평소에 하지 않는 행동을 한 것</mark>이 감염의 단서가 된 셈이다.

---
# <toc>공격은 어떻게 이루어졌나</toc>

### <toc2>1. 정상 업데이트 흐름</toc2>

```text
[Notepad++] → [GUP.exe (WinGUp)]
                 │ ① 새 버전이 있나?
                 ▼
     notepad-plus-plus.org/update/getDownloadUrl.php?version=현재버전
                 │ ② XML 매니페스트 응답 (설치 파일 주소 포함)
                 ▼
     [설치 파일 다운로드] → ③ 서명 확인 → ④ 설치 실행
```

### <toc2>2. 하이재킹된 업데이트 흐름</toc2>

```text
[Notepad++] → [GUP.exe]
                 │ ① 새 버전이 있나?
                 ▼
     [장악된 공유 호스팅 서버] ── 표적이 아니면 ──> 정상 응답
                 │
                 │ 표적이면 공격자 서버로 전달
                 ▼
     [공격자 서버] → ② 위조된 XML (악성 설치 파일 주소)
                 ▼
     [악성 update.exe 다운로드]
       → ③ 서명된 매니페스트도, 설치 파일 인증서도 확인하지 않음 (구버전)
       → ④ 그대로 실행 → 감염
```

호스팅 업체에 따르면 공격자는 호스팅 업체 내부 서비스의 자격 증명을 이용해 `getDownloadUrl.php`로 가는 요청을 자신의 서버로 돌렸고, 그 서버가 악성 업데이트 주소를 돌려주었다. 공격자는 같은 서버의 다른 고객에게는 관심을 보이지 않고 Notepad++ 도메인만 노렸다.

모든 사용자가 아니라 <mark>**선택된 사용자만** 악성 업데이트를 받았다.</mark> 덕분에 공격은 소수의 고가치 표적에 집중됐고, 대부분의 사용자에게는 아무 일도 일어나지 않아 오랫동안 들키지 않았다.

### <toc2>3. 감염 체인 ①: Chrysalis 백도어 (Rapid7 분석)</toc2>

```text
notepad++.exe → GUP.exe → update.exe 다운로드 (실제로는 NSIS 설치 파일)
   │
   ▼ %AppData%\Bluetooth 폴더 생성 (숨김 처리) 후 파일 풀기
   ├─ BluetoothService.exe : 이름을 바꾼 정상 Bitdefender 프로그램
   ├─ log.dll              : 악성 DLL
   └─ BluetoothService     : 암호화된 셸코드 (Chrysalis 본체)
   │
   ▼ BluetoothService.exe 실행 → log.dll 사이드로딩
   ▼ log.dll이 셸코드를 메모리에 올리고 복호화해 실행
   ▼ Chrysalis 백도어 동작
      - 윈도우 서비스(실패 시 Run 레지스트리)로 지속성 확보
      - PC 정보 수집 후 C2로 전송 (RC4로 암호화)
      - C2: api.skycloudcenter.com (DeepSeek 채팅 API 경로를 흉내 냄)
```

정상 보안 프로그램(Bitdefender)의 이름을 바꿔 악성 DLL을 불러오게 했다는 점이 눈에 띈다. 실행하는 주체가 서명된 정상 프로그램이기 때문에 탐지를 피하기 쉽다.

Chrysalis가 C2 명령으로 할 수 있는 일은 다음과 같다.

| 기능 | 설명 |
|---|---|
| 리버스 셸 | cmd.exe를 원격으로 조작 |
| 프로세스 실행 | 원하는 프로그램 실행 |
| 파일 읽기·쓰기 | 파일을 내려받아 저장하거나, PC의 파일을 C2로 전송 |
| 드라이브·파일 목록 조회 | 저장 장치와 파일 목록, 크기, 시간 정보 수집 |
| 자기 삭제 | 악성 파일과 지속성 설정을 지우고 배치 파일로 실행 파일까지 삭제 |

분석을 어렵게 하는 기법도 여럿 쓰였다. 사용할 윈도우 함수 이름을 해시값으로 숨기고(API 해싱), DLL과 함수 이름을 실행 중에 조립하며, 표준 암호 API 대신 직접 만든 복호화 루틴을 썼다.

같은 침해 PC에서는 다른 흔적도 나왔다. 이름을 svchost.exe로 바꾼 Tiny C Compiler(작은 C 컴파일러)가 `conf.c`라는 소스코드를 즉석에서 컴파일·실행했고, 이 코드가 Metasploit 셸코드로 Cobalt Strike Beacon을 내려받았다. Rapid7은 또 다른 로더에서 Microsoft가 서명한 정상 DLL 안에서만 동작하는 윈도우 내부 기능(Warbird)을 악용해 셸코드를 실행하는 기법도 확인했다.

### <toc2>4. 감염 체인 ②·③: 카스퍼스키가 찾은 다른 경로</toc2>

카스퍼스키는 2025년 7월부터 10월까지 공격자가 약 한 달마다 악성코드, C2 서버, 배포 방식을 완전히 바꾸며 <mark>**최소 3개의 서로 다른 감염 체인**</mark>을 운영했다고 밝혔다. 그중 2개는 Rapid7 보고서에 없던 것이었다.

- **7월 말~8월 초 체인**: 악성 update.exe가 `whoami`와 `tasklist` 명령으로 PC 정보를 모은 뒤 curl.exe로 파일 공유 서비스에 올리고, 그 주소를 공격자 서버로 보냈다. 이어 취약한 구버전 정상 프로그램(ProShow)을 떨어뜨려 다음 단계 악성코드를 실행했다.
- **또 다른 체인**: Lua 스크립트로 Metasploit 다운로더를 실행해 Cobalt Strike Beacon을 받았다.

카스퍼스키는 공개된 10월 IoC만으로 점검한 조직은 그 이전의 감염을 놓쳤을 수 있다고 경고했다.

### <toc2>5. 배후</toc2>

Rapid7은 이 공격을 2009년부터 활동한 중국 연계 APT 그룹 **Lotus Blossom**(Billbug, Lotus Panda, Raspberry Typhoon, Spring Dragon, Thrip으로도 불림)의 소행으로 **중간 수준의 신뢰도**로 추정했다. 이 그룹은 주로 동남아시아, 최근에는 중앙아메리카의 정부, 통신, 항공, 핵심 기반시설, 언론 분야를 노려 왔다. 근거는 다음과 같다.

1. 이름을 바꾼 Bitdefender 프로그램으로 `log.dll`을 사이드로딩하는 방식이 2025년 시만텍이 보고한 이 그룹의 수법과 같다.
2. `conf.c` 체인과 다른 로더들의 실행 흐름이 비슷하다.
3. 서로 다른 경로로 배포된 Cobalt Strike Beacon에 같은 공개키가 쓰였다.

---
# <toc>근본 원인</toc>

### <toc2>1. 업데이트를 "서버를 믿는 구조"로 만들었다</toc2>

가장 근본적인 원인은 업데이트 과정이 <mark>**서버가 보내 주는 내용을 그대로 믿는 구조**</mark>였다는 점이다.

| 버전 | 업데이트 매니페스트(XML) | 설치 파일 |
|---|---|---|
| v8.8.8 이전 | 서명 없음. 아무 도메인의 주소나 받아들임 | 서명·인증서 검증 없음 |
| v8.8.8 (2025. 11. 18.) | 다운로드 주소를 GitHub로 강제 | 서명·인증서 검증 없음 |
| v8.8.9 (2025. 12. 9.) | 검증 없음 (서버가 돌려주는 XML의 XMLDSig 서명은 2026년 2월 공지 시점에 적용된 것으로 안내됨) | 서명과 인증서 검증, 실패 시 중단 |
| v8.9.2 (2026. 2.) | 서명된 XML 검증 강제 | 검증 강제 |

HTTPS는 통신 중간의 변조는 막지만, 서버가 장악되면 소용이 없다. 공격자가 서버 응답을 바꿀 수 있는 순간, 업데이터는 공격자가 지정한 파일을 정상 업데이트로 믿고 실행했다.

업데이트의 신뢰를 서버가 아니라 **개발자의 서명**에 두었다면, 서버가 장악되더라도 <mark>개발자의 개인키 없이는 악성 파일을 실행시킬 수 없었다.</mark>

### <toc2>2. 직접 관리하지 않는 공유 호스팅</toc2>

Notepad++의 웹사이트와 업데이트 스크립트는 여러 고객이 함께 쓰는 공유 호스팅 서버에 있었다. 서버 관리는 호스팅 업체의 몫이었고, 그 업체가 뚫리자 Notepad++도 함께 뚫렸다. 호스팅 업체는 최초 침입 경로를 밝히지 않았다.

전 세계 수많은 사용자가 쓰는 프로그램의 업데이트 경로가, **개발자가 직접 통제하거나 들여다볼 수 없는 인프라**에 맡겨져 있었던 것이다.

### <toc2>3. 서버를 고쳐도 자격 증명은 남아 있었다</toc2>

2025년 9월 2일 정기 점검으로 공격자는 서버 접근 권한을 잃었다. 하지만 호스팅 업체 내부 서비스의 자격 증명은 12월 2일까지 계속 쓸 수 있었다.

<mark>서버를 정리하는 것과 공격자가 가져간 비밀번호·키를 모두 폐기하는 것은 별개의 일이다.</mark> 자격 증명을 함께 교체하지 않아 공격이 약 3개월 더 이어질 수 있었다.

### <toc2>4. 선택적 표적화로 탐지가 어려웠다</toc2>

공격자는 약 12대의 PC만 골라 감염시켰고, 그 외 사용자에게는 정상 업데이트를 내려보냈다. 피해가 넓게 퍼지지 않으니 백신 업체나 커뮤니티에서 이상 징후가 쌓이기 어려웠다. 여기에 매달 악성코드와 인프라를 바꾸어, 한 번 찾은 IoC로 다른 감염을 찾기도 어려웠다.

---
# <toc>대응</toc>

### <toc2>1. Notepad++ 프로젝트</toc2>

| 시점 | 조치 |
|---|---|
| v8.8.8 (2025. 11. 18.) | 업데이트 파일을 github.com에서만 받도록 강제 |
| v8.8.9 (2025. 12. 9.) | 설치 파일의 서명과 인증서 검증, 실패 시 업데이트 중단 |
| 2026. 2. 2. | 조사 결과 공개, 보안이 더 강한 새 호스팅 업체로 이전, 업데이트 서버가 돌려주는 XML에 XMLDSig 서명 적용, 사용자에게 v8.9.1을 공식 사이트에서 직접 내려받아 수동 설치하도록 권고 |
| v8.9.2 (2026. 2.) | 서명된 XML과 설치 파일 검증을 강제. libcurl.dll 의존성을 없애 DLL 사이드로딩 위험 제거, 안전하지 않은 cURL SSL 옵션 2개 비활성화, 플러그인 관리 기능은 WinGUp과 같은 인증서로 서명된 프로그램만 실행하도록 제한 |

수동 설치를 권고한 이유는, <mark>이미 설치된 구버전 업데이터 자체가 검증 기능이 없어</mark> 업데이트 경로를 믿을 수 없었기 때문이다.

### <toc2>2. 호스팅 업체</toc2>

- 서버 커널·펌웨어 업데이트 후 같은 패턴의 로그가 사라진 것을 확인했다.
- Notepad++를 공격하는 데 쓰였을 수 있는 취약점을 고쳤다. 로그상 고친 취약점 하나에 대해 재시도가 있었지만 실패했다.
- 공격자가 9월 2일 이전에 얻었을 수 있는 모든 자격 증명을 교체했다.
- 같은 서버의 다른 고객이나 다른 공유 서버에서 비슷한 패턴은 찾지 못했다.
- 고객들에게 SSH, FTP/SFTP, MySQL 비밀번호 교체와 WordPress 관리자 계정·플러그인 점검을 권고했다.

### <toc2>3. 보안 업체</toc2>

- Rapid7이 Chrysalis 백도어 분석과 IoC를 공개했다.
- 카스퍼스키가 7~10월에 걸친 3개 감염 체인과 추가 IoC를 공개했다.

---
# <toc>보완이 미흡했던 부분</toc>

### <toc2>1. 6개월 가까이 아무도 몰랐다</toc2>

침해는 2025년 6월에 시작됐지만, 문제가 드러난 것은 사용자가 포럼에 이상 행동을 보고하고 피해 조직이 나온 뒤였다. <mark>호스팅 업체도, 프로젝트도 스스로 침해를 발견하지 못했다.</mark> 공격자가 업데이트 트래픽을 돌리는 동안 이를 감지할 장치가 없었다.

### <toc2>2. 원인을 모른 채 대응을 시작했다</toc2>

v8.8.8과 v8.8.9는 업데이터를 강화하는 올바른 조치였지만, 이때는 침해가 어디서 일어났는지 아직 모르는 상태였다. 전체 경위는 v8.8.9 배포 후 약 두 달이 지난 2026년 2월에야 공개됐다. 그 사이 업데이트 하이재킹이 실제로 있었다는 사실을 모르는 사용자는 구버전을 계속 쓸 수 있었다.

### <toc2>3. 프로젝트가 가진 증거가 거의 없었다</toc2>

사고 대응팀이 약 400GB의 로그를 분석했지만, 침입 흔적만 확인했을 뿐 파일 해시, 도메인, IP 같은 구체적인 IoC는 찾지 못했다. 최초 침입 경로도 여전히 밝혀지지 않았고, 공격 종료 시점도 호스팅 업체(12월 2일)와 외부 전문가(11월 10일)의 설명이 다르다.

결국 사용자가 감염 여부를 확인할 수 있는 정보는 Rapid7, 카스퍼스키, 호스팅 업체가 따로 내놓은 자료에 의존해야 했다.

### <toc2>4. 처음 공개된 IoC는 일부에 불과했다</toc2>

처음 널리 알려진 분석은 10월에 관측된 감염 체인에 집중됐다. 카스퍼스키가 지적했듯 공격자는 매달 도구와 인프라를 바꿨기 때문에, <mark>10월 IoC로만 점검하고 "깨끗하다"고 판단한 조직은 7~9월의 감염을 놓쳤을 수 있다.</mark>

### <toc2>5. 검증 기능은 있었지만 강제는 늦었다</toc2>

v8.8.9부터 서명 검증이 들어갔지만, 서명된 매니페스트까지 포함한 검증이 강제된 것은 v8.9.2였다. 사고 공개(2026년 2월 2일) 이후에도 강제 적용까지 약 2주가 더 걸렸다. 또한 자동 업데이트를 켜 두지 않았거나 업데이트를 미룬 사용자는 여전히 검증 기능이 없는 구버전을 쓰고 있을 수 있다.

---
# <toc>내 의견</toc>

[TODO: 직접 작성]

<!--
작성할 때 참고할 질문:
- 이 사고의 가장 큰 책임은 호스팅 업체에 있다고 보는가, 아니면 서명 검증 없이 업데이터를 만든 프로젝트 쪽에 있다고 보는가?
- 개인이 무료로 관리하는 오픈소스 프로젝트가 기업 수준의 업데이트 보안(코드 서명 인증서 구매, 전용 인프라 운영)을 갖추는 것이 현실적으로 가능하다고 보는가? 그렇지 않다면 누가 그 비용을 나눠 져야 할까?
- 공격자는 소수의 표적만 골라 감염시켰다. 이런 선택적 공급망 공격을 기업 입장에서는 어떻게 탐지할 수 있을까? (예: 업데이터가 평소와 다른 프로세스를 실행하는지 감시)
- 기업 보안 담당자라면 이 사고 이후 사내에서 Notepad++ 사용을 금지하겠는가, 아니면 버전 관리와 배포 방식을 바꾸겠는가?
- 내가 만드는 프로그램에 자동 업데이트 기능을 넣는다면, 이 사고에서 무엇을 가져와 적용하겠는가?
-->

---
# <toc>정리</toc>

| 구분 | 내용 |
|---|---|
| 무엇이 | 2025년 6~12월, Notepad++ 웹사이트가 있던 **공유 호스팅 서버가 장악**되어 업데이터 요청이 공격자 서버로 돌려짐 |
| 누구에게 | 필리핀 정부기관, 엘살바도르 금융기관, 베트남 IT 업체 등 **선택된 소수의 표적** (약 12대) |
| 어떻게 | 위조된 XML 매니페스트로 악성 설치 파일을 내려보내 Chrysalis 백도어, Cobalt Strike 등 설치 |
| 배후 | 중국 연계 APT 그룹 Lotus Blossom (추정) |
| 왜 | 매니페스트와 설치 파일을 **서명으로 검증하지 않고 서버를 그대로 믿는 구조**, 통제할 수 없는 공유 호스팅, 남아 있던 자격 증명 |
| 아쉬운 점 | 6개월 가까이 침해를 모름, 프로젝트 자체 IoC 부재, 처음 공개된 IoC가 일부 기간에만 해당 |
| 이후 | GitHub 다운로드 강제(v8.8.8), 서명·인증서 검증(v8.8.9), 서명된 XML 검증 강제(v8.9.2), 호스팅 이전 |

HTTPS로 통신을 암호화하는 것만으로는 충분하지 않았다. 업데이트처럼 <mark>**코드를 실행하는 경로의 신뢰는 서버가 아니라 서명에 두어야 한다**</mark>는 것이 이 사고가 남긴 가장 큰 교훈이다.

---
# <toc>참고 자료</toc>

**공식 발표**
- [Notepad++, Hijacked Incident Info Update (2026. 2. 2.)](https://notepad-plus-plus.org/news/hijacked-incident-info-update/)
- [Notepad++, v8.8.9 release: Vulnerability-fix](https://notepad-plus-plus.org/news/v889-released)

**기술 분석**
- [Rapid7, The Chrysalis Backdoor: A Deep Dive into Lotus Blossom's toolkit](https://www.rapid7.com/blog/post/tr-chrysalis-backdoor-dive-into-lotus-blossoms-toolkit/)
- [Kaspersky Securelist, The Notepad++ supply chain attack — unnoticed execution chains and new IoCs](https://securelist.com/notepad-supply-chain-attack/118708/)
- [Kaspersky, Kaspersky GReAT uncovers hidden attack chains in Notepad++ supply chain compromise](https://www.kaspersky.com/about/press-releases/kaspersky-great-uncovers-hidden-attack-chains-in-notepad-supply-chain-compromise)
- [Advanced Installer, How the Notepad++ Updater Attack Worked](https://www.advancedinstaller.com/the-notepad-plus-plus-attack-explained.html)

**기사**
- [TechCrunch, Notepad++ says Chinese government hackers hijacked its software updates for months](https://techcrunch.com/2026/02/02/notepad-says-chinese-government-hackers-hijacked-its-software-updates-for-months/)
- [SecurityWeek, Notepad++ Supply Chain Hack Conducted by China via Hosting Provider](https://www.securityweek.com/notepad-supply-chain-hack-conducted-by-china-via-hosting-provider/)
- [The Hacker News, Notepad++ hosting breach attributed to Lotus Blossom](https://thehackernews.com/2026/02/notepad-hosting-breach-attributed-to.html)
- [BleepingComputer, Notepad++ fixes flaw that let attackers push malicious update files](https://www.bleepingcomputer.com/news/security/notepad-plus-plus-fixes-flaw-that-let-attackers-push-malicious-update-files/)
- [Bitdefender, Notepad++ tightens update security after suspected hijack attempts](https://www.bitdefender.com/en-gb/blog/hotforsecurity/notepad-tightens-update-security-after-suspected-hijack-attempts)
- [heise, Notepad++ updater installed malware](https://heise.de/-11109726)
- [Help Net Security, Notepad++ secures update channel in wake of supply chain compromise](https://helpnetsecurity.com/2026/02/18/notepad-secure-update-download)
- [Help Net Security, Notepad++ supply chain attack: Researchers reveal details, IoCs, targets](https://www.helpnetsecurity.com/2026/02/03/notepad-supply-chain-attack-iocs-targets/)
- [eSecurity Planet, Notepad++ Update Servers Hijacked in Targeted Supply Chain Attack](https://www.esecurityplanet.com/ja/threats/notepad-update-servers-hijacked-in-targeted-supply-chain-attack/)
