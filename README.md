# README

**尚未處理的問題:**

- 還不會用 phantomJS或Selenium等方式解決動態加載的問題
- 建立簡單的網頁
  - 聽取錄音: 整首, 前30秒, 隨機30秒
  - 新增自己的tags，並且會寫入本機檔案。
- 關閉特定的chrome 分頁
  - 利用開啟 chrome 的分頁，省去登入google的問題
  - 無法在呼叫完成之後，關閉 chrome 特定分頁，只能用 taskkill 殺死所有 chrome 的 process
- 利用 batch 指令指定 chrome 下載的位置。

## 緣由

- [音效庫 - YouTube](https://www.youtube.com/audiolibrary/music?nv=1)

有天女友在找要上片的背景音樂時，  
我發現雖然介面上很友善，有各種分類(例如: 類型、樂器、情境)，  
但是這些tags都太過於general，  
所以我就建議這種東西應該要有額外自己的tags，  
好處就是，這樣未來有新的影片要配樂時，不會就又要一首一首重找，  
可以有更多的選項做 filter。

well, 那就動手做吧XDD~  

## 目標

不確定這個資料更新的頻率，所以目前全部抓取下來，  
未來可以再比對vid，排除重複的音樂。
(但這個方法可能不太好XD，畢竟必須全部掃過一遍)

- [www-audiolibrary.js](https://www.youtube.com/yts/jsbin/www-audiolibrary-vflhVwl_P/www-audiolibrary.js)
- [音效庫 - YouTube](https://www.youtube.com/audiolibrary/music?nv=1)
- query方式01 https://www.youtube.com/audioswap_ajax?action_get_tracks=1&dl=true&s=music&mr=25&si=0&qid=0&sh=true
- query方式02 https://www.youtube.com/audioswap_ajax?action_get_tracks=1&dl=true&s=music&mr=25&si=25&qid=5&sh=true

- 抓取音效庫中，免費音樂music 和 音效soundeffects
  - music.csv
  - soundeffect.csv
  - renew_datetime.txt: YYYY-MM-DD
- 抓取音樂和音效，檔案名稱為 title_vid_vid.mp4，因為直接下載會預設為title.mp4，但是title會重複，所以加上vid。
  - music/
  - soundeffect/

## 資料觀察

**1.參數:**

因為一開始不是很懂網址的參數，所以花了很多時間做查詢。  
以下是透過 www-audiolibrary.js，和query方式，一起整理出的結果，有將比較重要的 function 一起列出來。

- format:"JSON",method:"GET"
- action_get_tracks = 1
- q: query <!-- 搜尋關鍵字 -->
- kw: keyword
- rkw: reserved_keyword
- t: title
- ar: artist
- al: album
- g: genre <!-- 類型 -->
- it: instrument <!-- 樂器 -->
- mo: mood <!-- 情境 -->
- dl: downloadable <!-- 可否下載 -->
- minl: min_length <!-- 音樂長度，單位 sec -->
- maxl: max_length
- s: section <!-- 免費音樂music or 音效soundeffect -->
- cat: category <!-- 音效類別 -->
- arev: audio_revshare
- minlt: min_license_type <!-- 0~2 不須註明出處。3~6 必須註明出處 -->
- maxlt: max_license_type
- ct: continuation_token <!-- 以後可能做成API，但是現在都為NULL -->
- mr: <!-- 回傳筆數 -->
- si: <!-- 查詢筆數的起始index -->
- qid: <!-- query次數，也就是網頁往下拉後重新再查詢的次數 -->
- sh: true <!-- 未知 -->

function aq(a,b,c,d,e,f,g,h,k){
    function m(r,t){r in b&&(n[t]=b[r])}
    var n={};
    b=b||{};
    m("query","q");
    m("keyword","kw");
    m("reserved_keyword","rkw");
    m("title","t");
    m("artist","ar");
    m("album","al");
    m("genre","g");
    m("instrument","it");
    m("mood","mo");
    m("downloadable","dl");
    m("min_length","minl");
    m("max_length","maxl");
    m("section","s");
    m("category","cat");
    m("audio_revshare","arev");
    m("min_license_type","minlt");
    m("max_license_type","maxlt");
    m("continuation_token","ct");
    n.mr=c?c:20;
    n.si=d||0;
    n.qid=a;
    n.sh=!!e;
    a={format:"JSON",method:"GET",context:k,cb:n};
    f&&(a.onSuccess=f);
    g&&(a.ia=g);
    h&&(a.onError=h);
    Nm("/audioswap_ajax?action_get_tracks=1",a)
}

function cq(a){
    a.l++;
    aq(a = a.l, b = a.i, c = a.B, d = a.g.length, e = a.J,
       f = a.H, g = a.v, h = a.j, k = a)
}

**2.資料格式:**

網頁上面是 ajax 動態加載，可以透過 html 節點的方式，把動態加載的資訊從一個一個位置抓取出來，  
但是我覺得這樣很慢，也很複雜。

後來透過 F12(開發人員工具) + Network + XHR + Headers和Preview，找到query網址，  
但是輸入 query 網址，會直接下載一個json檔案，所以不是很方便。

::exclamation: 必須先登入Google帳號，可以用無痕試試看，會發現無法取得資料。

## 步驟

一種做法是透過 phantomJS 或 Selenium，模擬真實瀏覽器，解決動態加載問題。  
但這還有登入google帳號的問題，  
所以我決定用 cmd 去呼叫 chrome.exe，  
然後輸入query網址，  
設定好下載的位置，再對該下載好的 json 檔案做處理。

- 用 R 操作 cmd 呼叫 query 網址
  - 下載後，移動json檔案到設定的資料夾
  - 移動檔案需要時間，所以要做 file.exist()檢查，停頓一下時間。
- 讀取 json 下載結果
- 整理資料
  - 刪除json檔案
- 是否還有更多資料。has_more: TRUE/FALSE
- 是的話更改 query 網址，再跑一遍。

## 技術學習

- 認識動態加載網頁，以及查詢資料路徑
  - 如何取得想要的 query 網址: F12(開發人員選項) + Network + XHR + Headers和Preview
- R 操作 cmd
- cmd 呼叫 chrome 進行操作
  - 輸入 url，等待query後，下載完成
- R 移動檔案以及刪除
- 解析 json 檔案
- 特殊文字(例如法國 latin 編碼)轉換

**cmd + chrome 指令:**

> start chrome

- start: 啟動，類似按下 windows 開始鍵。
- chrome, chrom.exe: 搜尋 chrome 程式。
- --incognito: 開啟無痕模式。
- --new-window: 開啟新視窗，預設是會在原本的chrome開一個新tab分頁。
- --app: app模式，簡單俐落的介面。
- --profile-directory="Default": will make the window open as the default chrome user。以默認的chrome用戶啟動。
- url, "url": 輸入想去的網址

> taskkill /f /im chrome.exe /f  
> 最後沒有使用

- /f: forcefully terminate the process
- /im: Image Name of the process to be terminated. '*' wildcard can be sure to specify all the tasks or image names
- /t: Terminate all child of the image or process
