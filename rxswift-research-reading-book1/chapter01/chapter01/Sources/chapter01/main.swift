import RxSwift

/*
 -R-Rx-RxS-RxSw-RxSwi-RxSwif-RxSwift
 ※ fileter{ $0.count >= 2}を適用
 ※ ストリームの矢印にあるイベントに対して、オペレータfilterを適用した下のストリームの矢印
 -Rx-RxS-RxSw-RxSwi-RxSwif-RxSwift

 (ex)
 インクリメンタルの検索のために全てを小文字にしておきたい -> RxSwiftでは、mapオペレータを使うことで実現
 
 mapメソッドは、RxSwiftでは以下のようにインタフェースが定義
 
 extention ObservableType {
    public func map(_ transform: @escaping(Self.E)throws -> R) -> RxSwift.Observable<R>
 }
 */
let observable = Observable.of(
    "R",
    "Rx",
    "RxS",
    "RxSw",
    "RxSwi",
    "RxSwif",
    "RxSwift"
)

_ = observable
    .filter({ $0.count >= 2})
    .subscribe(onNext: {
        print("onNext: ",$0)
    })

/*
 -R-Rx-RxS-RxSw-RxSwi-RxSwif-RxSwift
 
 ※ fileter{ $0.count >= 2}を適用
 ※ ストリームの矢印にあるイベントに対して、オペレータfilterを適用した下のストリームの矢印
 -Rx-RxS-RxSw-RxSwi-RxSwif-RxSwift
 
 ※ map{$0.lowercased()}を適用
 ※ ストリームの矢印にあるイベントに対して、オペレータmapを適用
 -rx-rxs-rxsw-rxswi-rxswif-rxswift
 */
_ = observable
    .filter({ $0.count >= 2})
    .map({ $0.lowercased() })
    .subscribe(onNext: { print("onNext: ", $0)})

/*
 メソッドチェインによって処理を繋げることで、比較的宣言的に書けるメリットがある
 メソッドチェインにはそのメリットとは別に「副作用」をなるべく避けるコードになっている
 
 プログラミングにおける副作用：関数などの処理に対する入力以外に外部データを変化させてしまうことであったり、外部から入力以外の処理に対して変化を加えてしまうこと
 (ex)副作用の具体例
    - サーバにリクエストを投げること
    - アプリ内のDBを書き換えること
    - グローバル変数やシングルトンへの代入
 
 関数などのひとまとまりの処理において避けるべき点は、条件が同じでも次回以降は、その処理の出力を変えてしまう性質を持っているところ
 
 プログラミングとしての副作用：主だった処理とは別の作用
 
 RxSwiftはメソッドを組み合わせたメソッドチェインにより、関数型プログラミングの副作用を避ける方法を取り入れたプログラミングをすることで、より読みやすく宣言的なコードにできるわけ
 
 メソッドチェインの関数は、あくまでも「クロージャ」のため、「クロージャ外部から変数を差し込むことは容易」である
 これによって入力が一定にも関わらず出力が変更されるような副作用の発生は免れない
 RxSwiftのメソッドチェインにおいて、クロージャ引数以外の入力を差し込むべきではないということをあらかじめ注意しておく
 
 【用語の整理】
 - ストリーム：データがイベントとして連なった流れ。シーケンスとも呼ばれる
 - Observable：RxSwiftにおけるストリームを生成する概念としてクラスObservable<T>で提供される
 - オペレータ：要素からストリームを作成したり、ストリームに対して処理を行うメソッド、具体的にはストリームを作成するオペレータはofやjust、処理を行うのはmapやfilterが該当する
 - ストリームの購読：ストリームから伝播されてくるイベントを順次処理する仕組み
 - 副作用：主になる作用とは別もしくはそれを原因に外部の値を変更してしまうこと、場合によっては効果的に次回以降の出力を変化させてしまう性質を持つ
 - 関数型プログラミング：複数の処理を関数によって組み合わせていくプログラミングスタイル。そのため、副作用を避け入力と出力だけの純粋関数によってコードを書くことが推奨される
 */


/*
 RxSwiftの特徴として、時間の概念が扱えるというメリットがある
 「時間の概念が扱えること」：時間を軸とした制御が可能になるということ
 
 (ex)
 ユーザが素早く入力している最中
 - ユーザが高速に入力して次の入力に移ることを前提にすると、全ての入力に対する検索は必要ない
 
 -> 入力をし終えてしばらく入力しないなら、文字入力は終わっているためそれだけは必ず検索する必要があるとも仮定できる
 -> 次の入力まで経過時間という条件により制御できれば、より無駄がなくなる
 
 経過時間という条件を考慮したコードを書くために、RxSwiftでは「debounce」というオペレータが用意されている

 extention ObservableType {
    public func debounce(_ dueTime: RxTimeInterval, scheduler: SchedulerType) -> Observable<Element> {
        return Debounce(source: self.asObservable(), dueTime: dueTime, scheduler: scheduler)
    }
 }
 
 // RxTimeIntervalは、DispatchTimeIntervalのエイリアス
 public typealias RxTimeInterval = DispatchTimeInterval
 
 public enum DispatchTimeInterval: Equatable {
    case seconds(Int)
    case milliseconds(Int)
    case microseconds(Int)
    case nanoseconds(Int)
    case never
    public static func == (lhs: DispatchTimeInterval, rhs: DispatchTimeInterval) -> Bool
 }
 */

/*
 ViewModelによるMVVM
 
 RxSwiftの特徴としてViewModelによるMVVMパターンを可能にするメリット
 
 RxSwiftを利用したアプリ開発を行う場合、「UIKitをサポートするRxCocoaライブラリ」が利用できる
 これによりUIKitの様々なコンポーネントにリアクティブプログラミングを活かした拡張を追加することで
 関数型プログラミングとリアクティブプログラミングの良さをフル活用し、ロジックの担当を分類することでコードの見通しが良くなる
 
 具体的には、
 「UIを担当するView」と「ロジックによるデータの変更を担当するModel」として分類をした上で、
 「Modelにより更新されたデータをViewにバインドするための処理を担当するViewModel」とに分類される
 
 「Model」「View」「ViewModel」で構成されるGUIアーキテクチャをMVVM（Model-View-ViewModel）パターンと呼ぶ
 
 RxSwiftでは、RxCocoaを利用することで、MVVMパターンを採用しやすくなっている
 
 (ex)
 ViewController(UIロジック担当) -> Observable -> ViewModel（プレゼンテーションロジック担当） -> Model（ビジネスロジック担当）
 ViewController(UIロジック担当) <- Observable（RxCocoaによるバインド） <- ViewModel（プレゼンテーションロジック担当） <- Model（ビジネスロジック担当）
 
 
 【MVVMまとめ】
 1. ViewおよびViewControllerはUIロジックを担当する
    -> UIロジックはViewの生成や変形、表示非表示などを担当し、タッチ系イベントの設定やフィルタを行う
 
 2. ViewModelは、プレゼンテーションロジックを担当する
    -> プレゼンテーションロジックは、ビジネスロジックの結果をUIに表示するための処理
    -> MVVMパターンは、プレゼンテーションロジックはUIロジックと分離されており、具体的なUIコンポーネントのカタチへの関心が分離されている
 
 3. Modelはビジネスロジックを担当する
    -> MVVMパターンでは、むしろViewとViewModel以外の全てをビジネスロジックとするのが無難
    -> (ex)データ自身をシステムで扱いやすくした型とその処理もしくはデータアクセスレイヤーが該当する
 
 MVVMは、ViewとViewModelのロジックを分担し、それ以外としてModelの担当を分けている。
 Modelの抽象度をさらに細分化して層に分けるかどうかは関心ごとではない
 Model層の細分化を前提といした上でもMVVMにすることはかまわない
 Model層を細分化する特定のレイヤ化アーキテクチャを前提として、混乱を避けるためにMVVMとは区別する呼び方をするのであれば、それでかまわない
 
 最低限MVVMという言葉から感じ取る意味としては、UIロジックとプレゼンテーションロジックの分離とデータバインディングについてのパターンを感じ取ること
 
 【用語のまとめ】
 - UIロジック：Viewの生成や変形、表示非表示などを担当し、さらにタッチ系イベントの設定なども行う
 - プレゼンテーションロジック：ビジネスロジックの結果をUIに表示するための処理を担当する
    - (ex)入力データへのバリデートポイントを呼びだし、UIロジックのための処理を行う
 - ビジネスロジック：MVVMパターンでは、UIロジックとプレゼンテーションロジック以外の全てのロジックとも言えるが、レイヤ化アーキテクチャの層を分類をしたければその定義はさらに細かく分類される。
 */

/*
 はじまりのMVVM（始祖のMVVM）
 MVVMは、2005年にMicrosoftにより.NET FrameworkのWindows Presentation Foudation（WPF）におけるGUIアーキテクチャパターンとして提唱された
 WPFでは、XAMLというXMLベースの言語をViewテンプレートとし、そのViewにModelの値をバインドする仕組みとしてViewModelという考え方が採用された
 このViewModelでは、GoFのコマンドデザインパターンにより、Viewからのユーザ入力とその結果を抽象化してやりとりすることで依存関係をなくしている
    - (ex)
    - ICommandというC#のInterface（抽象メソッドのみを持つ型）によりViewModelを操作し、その結果もICommandとしてViewがバインドする
 
 View（UIロジック担当）<-Notification - ViewModel（プレゼンテーションロジック担当）->Model（ビジネスロジック担当）
 View（UIロジック担当）<-Notification-> Command（WPFによるバインド）ViewModel（プレゼンテーションロジック担当）<- Model（ビジネスロジック担当）
 
 
 RxSwiftに置き換えると、UIコンポーネントのストリームをViewModelに渡すことで、ViewModelからのストリームをUIコンポーネントにバインドする
始祖のMVVMのようにRxSwiftでもprotocolを使ってViewとの依存を減らし、ViewからViewModelにイベントを伝えてもよい
 RxSwiftを使うということは関数型プログラミングとリアクティブプログラミングのパラダイムを活かしたいから
 
 ViewModelへストリームではない外部操作を加えて状態を変えてしまうなら、内部状態の管理を増やしてしまうことにもなりかねない
 そのような処理は、ViewModelの振る舞いを変えてしまう副作用となり得るため、できるだけ避けてしまう
 様々なプラットフォーム上の様々な言語でViewModelが実現されるため、その確実な振る舞いを定義するというのは難しい
 少なくとも、UIロジックとプレゼンテーションロジックが分離していて、データバインディングを行える仕組みを持つことがMVVMと言える
 */

/*
 RxSwiftのリアクティブプログラミングはデータの流れと変化についてコーディングを行えるようになる
 関数型プログラミングの特性を活かして、副作用に避けつつ比較的宣言的なコードを書けることも大きな特徴
 RxSwiftに付随するライブラリであるRxCocoaはリアクティブプログラミングを利用したMVVMパターンを実現できる
 
 MVVMパターンは、UIロジックとしてプレゼンテーションロジックを分離しており、実際のUIとプレゼンテーションロジックの依存性を引き離してくれることで、
 プレゼンテーションロジックのテストを容易にしてくれる。
 Modelという層に関しては、どのように作るかはMVVMパターンでは指定していない
 */

/*
 リアクティブプログラミングはRxSwiftとは関係がない
 リアクティブシステムという抽象的な概念が存在している
 
 リアクティブシステムとは、次の4点の条件を全て、もしくはほとんどを備えたシステム
 
 1. 即応性（Responsibility）
    - ユーザの要求に対して素早くレスポンスを返す
 
 2. スケーラビリティや弾力性（Scalability/Elastic）
    - 処理の分散およびシステムリソースの状況に応じた増減を可能にする
 
 3. 耐障害性（Resilient）
    - エラーハンドリングやリトライなどで障害からの復帰を可能にする
 
 4. メッセージドリブン（Message Driven）
    - スケーラビリティや弾力性のためのコンポーネント同士を疎結合にする
 */
