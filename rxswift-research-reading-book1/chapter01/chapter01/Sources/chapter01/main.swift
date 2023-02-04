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
