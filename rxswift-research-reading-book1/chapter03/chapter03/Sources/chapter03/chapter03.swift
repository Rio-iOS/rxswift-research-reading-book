import RxSwift

@main
public struct chapter03 {
    public static func main() {
        /*
         Sunject
         RxSwiftで頻繁に利用されるPublishSubjectに代表されるSubjectは、
         ObservableとObserver両方の機能を有していると表現される。
         Observableクラスを継承し、ObserverTypeプロトコルを採用しているから
         
         Subjectの重要なこと2つ
         ・Subjectは購読される
            -> SubjectがObservableクラスに準拠している
         ・Subjectのインスタンスはイベントを任意のタイミングで発火できる
            -> Subjectは、「ObservableとObserverの両方の機能を有している」というだけでは、説明しきれない
            -> そもそもObservableはofやjustメソッドなどでイベントを作成できる
            -> 任意のタイミングでイベントを発火できることについて、Observerの機能も有していることの理由になるそうである。
         */
        
        /*
         オブザーバーパターンにより任意のタイミングでイベントを発火できること
         オブザーバーパターンでは、「状態変化の観測対象」と「観測者」を「Observer」と「Subject」というインタフェース型として抽象化する。
         
         オブザーバパターンのSubjectはRxSwiftのSubjectとは別物
         オブザーバパターンでは「観測対象」を「Subject」とし、RxSwiftのような「Observable」とは表現しない
         そもそもObservableという表記がObserverと見分けが付きづらい
         
         重要なのは、オブザーバパターンのSubjectは状態変化をObserverに伝える際、
         Observerのupdateメソッドを呼び出すことで、状態が変わったことを伝達する。
         
         【用語】
         ・オブザーバパターンのSubject
            -> RxSwiftなどで、Observable。観測対象者の操作をインタフェース型としたもの
         ・オブザーバパターンのObserver
            -> 観測者をインタフェース型としたもの。観測時のメソッドをupdateとして定義している
         
         GoFのオブザーバパターンにおけるObserverのupdateメソッドは、
         「状態変化が通知される際に呼び出されるメソッド」として定義されている。
         しかし、RxSwiftにおけるSubjectは「ObservableとObserver両方の機能を有している」ことで、Observerのupdateを「状態変化を通知する際のメソッド」として柔軟に呼び出されるようにしたと解釈できる
         
         RxSwiftのObserverであるObserverTypeプロトコルが、on(_ event: Event<E>)メソッドを持つこともそれを示している。
         他にも、on(_ event: Event<E>)メソッドのラッパーであるonNext(_ element: E),
         onCompleted(), onError(_ error: Swift.Error)メソッドがあり、
         Subjectはこれらのメソッドを使って柔軟にイベントを発火できる
         */
        
        /*
         // Rx/RxSwift/ObserverType.swift
         
         public protocol ObserverType {
            associatedtype E
            func on(_ event: Event<E>)
         }
         
         extension ObserverType {
            public func onNext(_ element: E) {
                on(.next(element))
            }
         
            public func onCompleted() {
                on(.completed)
            }
         
            public func onError(_ error: Swift.Error) {
                on(.error(error))
            }
         }
         */
        
        let subject = PublishSubject<String>()
        
        let _ = subject.subscribe(
            onNext: {print("onNext: ", $0)},
            onCompleted: {print("onCompleted:")}
        )
        
        subject.onNext("A")
        subject.onNext("B")
        subject.onNext("C")
        subject.onNext("D")
        subject.onCompleted()
        
        
        /*
         ControlProperty
         RxCocoaのControlProperty構造体が準拠するControlPropertyTypeプロトコルは、
         SubjectTypeプロトコルと類似しており、ObservableTypeプロトコルおよび
         ObservarTypeプロトコルを採用しているのが特徴
         
         ControlPropertyはRxSwiftでのプログラミングで頻繁に使われる、
         UIコンポーネントからのイベントストリームとして取得するための型
         
         (ex1)
         usernameOutler.rx.text.orEmpty.asObservable()
         
         usernameOutlet // UITextField
            .rx         // Reactive<UITextField>
            .text       // ControlProperty<String?>
            .orEmpty    // ControlProperty<String>
            .asObservable // Observable<String>
         
         usernameOutlet: UITextField!が呼び出している「rxプロパティ」とは、
         RxSwiftではReactiveCompatibleプロトコルに準拠している型で使えるプロパティとして
         定義されている。
         
         // Rx/RxSwift/Reactive.swift
         public protocol ReactiveCompatible {
            // Extended type
            associatedtype CompativleType
         
            // Reactive extentions
            public static var rx: RxSwift.Reactive<Self.CompatibleType>.Type {get set}
         
            // Reactive extentions
            public var rx: RxSwift.Reactive<Self.CompatibleType> {get set}
         }
         
         (ex1)のUITextFieldによるReactiveCompatibleプロトコルの採用については、
         実はUITextFieldの親クラスを辿った先のNSObjectについて、
         RxSwiftのエクステンションによって、ReactiveCompatibleを採用するようになっている
         
         // Rx/RxSwift/Reactive.swift
         // Extend NSObject with rx proxy
         extention NSObject: ReactiveCompatible {}
         
         これにより、UIコンポーネントはNSObjectを継承していることで、
         ReactiveCompatibleに準拠もしていることとなる
         
         rxプロパティは、Reactive<CompatibleType>なインスタンスを返すが、
         実装はプロトコルエクステンションにより決められている
         
         // Rx/RxSwift/Reactive.swift
         extention ReactiveCompatible {
            // Reactive extentions
            public static var rx: RxSwift.Reactive<Self>.Type
         
            // Reactive extentions
            public var rx: RxSwift.Reactive<Self>
         }
         
         rxプロパティにより手に入れたReactive構造体は、RxSwiftにより次のように定義される
         // Rx/RxSwift/Reactive.swift
         public struct Reactive<Base> {
            // Base object to extennd
            public let base: Base
            // creates extensions with base object
            // - parameter base: Base object
            public init(_ base: Base)
         }
         
         Reacttive<Base>にてBaseがジェネリクスとなっていることから、
         (ex1)では、rxメソッドでReactive<UITextField>のインスタンスを返す際、
         baseプロパティがUITextFieldを保持される
         
         (ex1)のrx.textのようにtextプロパティを呼び出していた
         rx.textを実現しているのはextension Reactiveであり、
         RxCocoaで次のように実装されている。
         
         // Rx/RxCocoa/UITextField+Rx.swift
         extention Reactive where Baes: UITextField {
            // Reactive wrapeer for text property
            public var text: ControlProperty<String?> {
                return value
            }
         }
         
         rx.textはControlProperty<String?>を返していたということがわかる
         ControlPropertyについてRxCocoaのコードを見ると、asObservableメソッドにより
         Observable<String?>が手に入る
         
         // Rx/RxCocoa/Traits/ControlProperty.swift
         public struct ControlPropety<PropetryType>: ControlPropertyType {
            public typealias E = PropetyType
            
            // ...省略...
         
            public func asObservable() -> Observable<E> // ...省略...
         }
         
         (ex1)でControlProperty<String?>のようにStringがオプショナルになっているのは、
         UITextFieldの持つ文字列がもともとオプショナルだから
         
         rx.text.orEmpty.asObservable()のように、orEmptyプロパティを使っていた
         ControlPropertyTypeのorEmptyプロパティは、Stirngがnilの場合に
         空文字のStringとして変換し、ControlProperty<String>を返す。
         オプショナルの必要がなくなることで、ControlProperty<String?>から
         オプショナルではないControlProperty<String>に変換していた
         
         最後にasObsrevable()メソッドによってControlProperty<String>を
         Observable<String>に変換すれば、UITextFieldからストリームの取得が完了
         */
    }
}
