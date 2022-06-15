# 원티드 프리온보딩 iOS 코스

## 필수 구현 사항
### 애플리케이션 설명
- Open Weather의 API를 활용하여 다음의 조건을 충족하는 iOS 앱을 구현합니다.
### 첫 번째 화면

---

- 아래 각 도시의 현재 날씨를 화면에 표시합니다.
    - 필수로 포함해야 하는 정보
        - 도시이름, 날씨 아이콘, 현재기온, 현재습도
            
            > 공주, 광주(전라남도), 구미, 군산, 대구, 대전, 목포, 부산, 서산, 서울, 속초, 수원, 순천, 울산, 익산, 전주, 제주시, 천안, 청주, 춘천
            > 
        - 날씨 아이콘의 경우 API에서 제공하는 아이콘을 활용합니다.
- 첫 번째 화면의 각 도시 정보를 선택하면 두 번째 화면으로 이동합니다

### 두 번째 화면

---

- 첫 번째 화면에서 선택한 도시의 현재 날씨 상세 정보를 표현합니다
    - 필수로 포함해야 하는 정보
        - 도시이름, 날씨 아이콘, 현재기온, 체감기온, 헌재습도, 최저기온, 최고기온, 기압, 풍속, 날씨설명
- 날씨 아이콘 이미지를 불러올땐 캐시를 활용합니다.
    - 캐시된 정보가 있다면 캐시된 이미지를 활용합니다.
    - 캐시된 정보가 없다면 API로부터 이미지를 받아옵니다.
## 프로젝트 설명 
실 디바이스 사용시 국내 현재 유저의 위치를 확인하고 위치의 날씨를 확인할 수있으며 주요 20개의 도시의 현재 날씨를 확인할수 있습니다. 

또한 내가 마지막으로 조회한 시간을 확인할수 있고 재조회를 통해 모든 정보를 최신화 할수 있습니다.

## 디자인 패턴

MVVM 패턴

## 위치정보 및 날씨 정보 가져오기

Open Weather의 API를 사용하여 20개의 주요 도시의 날씨정보를 가져오도록 하고 모든 정보를 불러온 이후 Icon값에 따라 이미지를 다운로드 받도록 하였습니다.

또한 실 디바이스로 테스트시 국내 현 주소를 Naver Rever Segeocode API를 통해 확인하여 현 사용자 주소 정보를 가저오도록 하였고 
Open Weather의 API를 사용하여 사용자의 날시 정보 또한 가져올수 있도록 처리하였습니다.

이를 순서대로 하기 위하여 escaping closure를 사용하여 Call back 받은 이후 차례대로 작업을 수행하도록 하였습니다. 

## 모달을 사용한 페이지 이동

NavgationController보다는 페이지가 2개뿐이기 때문에 사용자가 모달형식으로 빠르게 확인하고 다시 메인 화면으로 돌아올수 있도록 하기 위해 모달을 사용하여 페이지 이동을 하였습니다.

## MVC에서 MVVM으로 변경

프로젝트를 완성한 이후 Swfit에서 MVVM패턴으로 바꾸고 싶었습니다. 그래서 다른 교육자료를 참조하여 부족하지만 MVVM패턴을 사용하여 코드를 리펙토링 해보았습니다.

## 아쉬운점

CollectionView의 Scroll 방식을 페이징 방식으로 하고 싶었지만 UI관련된 세부 지식이 부족하여 구현해내지 못하였습니다. 하지만 이를 외부 라이브러리 없이 적용하고 싶습니다.

