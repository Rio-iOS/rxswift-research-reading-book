# RxSwiftのDriverとSignal

- RxSwiftのDriver：アプリ開発における実際のユースケースに即しており、リアクティブプログラミングをUIレイヤーでも扱うための直感的な方法を提供
    - 特徴
    - エラーを伝達しないことを前提としている（onErrorが通知されない）
        - エラーを伝達しないことを前提としているのは、Observableなストリームは、エラーが起こってしまった場合に購読を辞めてしまうため、そのままでは新しいイベントがUIにバインドできなくなる。
        - そのため、UIにバインドしているイベントはエラーを伝達させないと割り切り、Driverではエラー時にはそれを伝達せず、決められた値としてイベントが変換される
    - イベントはメインスレッドで観測されることを約束する
        - メインスレッドで、イベントが観測されることを約束するメリットは、UIがスレッドセーフではなくメインスレッドで操作しないといけないため
    - 原則Hot Observableである（副作用が共有される）
        - Driverが原則Hot Observableであることは、型を見れば、Observableであるかどうかを判断できる利便性もある。

- ディレクトリ構成
```
# RxExample > Examples > GitHubSignup
- BindingExtensions.swift # extension集
- DefaultImplementations.swift # バリデート実装や通信実装
- GithubSignup2.storyboard # 本章で利用する画面
- Protocols.swift # protocolおよびenum
- UsingDriver # 本章のVCおよびVM
    - GitHubSignupViewController2.swift
    - GitHubSignupViewModel2.swift
```

- ViewControllerとViewModelの役割と内部構成
    - ViewControllerの役割
        - 役割1：StoryboardのUIコンポーネントをつなぐ
        - 役割2：ViewModelを初期化
        - 役割3：ViewModelの出力とUIコンポーネとをバインドする
        - その他の処理の展開
            - 画面上のタップを検知し、入力時のソフトウェアキーボードを閉じる


- IBOutletなプロパティのDriverへの変換
    - ユーザ入力をイベントとして伝えるリアクティブプログラミングのため、IBOutletなUIコンポーネントをObservableにし、ViewModelへ伝えていく必要がある。
    - Driverの特性の1つ：エラーを流さない
    - 結局、Driverとはアプリ開発者のユースケースに合わせて用意されたObservable
```
// Rx/RxCocoa/Traits/Driver/ControlProperty+Driver.swift
extension ControlProperty {
    /// Converts `ControlProperty` to `Driver` trait.
    ///
    /// `ControlProperty` already can't fail, so no special case needs to be handled
    public func asDriver() -> Driver<E> {
        return self.asDriver { (error) -> Driver<E> in
            #if DEBUG
                rxFatalError("Somehow driver received error from a source that shouldn't fail.")
            #else
                return Driver.empty()
            #endif
        }
    }
}

// self.asDriverへ渡しているクロージャでは、デバッグビルド時にfatalErrorとしていて、
// デバッグビルドでなければDriver.emptyを返し何もしないイベントを作成している。
```
```
// Rx/RxCocoa/Traits/Driver/ObservableConvertibleType+Driver.swift
// asDriverメソッドは単純にObservableを作成してそれをDriverとして返しているだけ
// .observableOn(DriverSharingStrategy.scheduler)によってスケジューラを指定しているが、
// このスケジューラはMainScheduler()でありメインスレッドになる
// .catchErrorによって、エラーが発生した場合に、そのエラーをasObservableによってObservableに変換している
// デバッグビルドであれば、fatalError
// デバッグビルドでなければ、Driver.emptyによって何もしないイベントを作成
// Driver(source)によってObsevableを元にDriverを作成
// このイニシャライザ時にshare(replay:1)メソッドが呼ばれており、これがDriverの特性の1つのHot Observableへの変換となる
extension ObservableConvertibleType {
    // ...省略...
    public func asDriver(onErrorRecover: @escaping(_ error: Swift.Error) -> Driver<E>) -> Driver<E> {
        let source = self.asObservable()
                         .observeOn(DriverSharingStrategy.scheduler)
                         .catchError {
                            onErrorRecover(error).asObservable()
                         }
        return Driver(source)
    }
}
```
```
// Rx/RxCocoa/Traits/Driver/Driver.swift
public struct DriverSharingStrategy: SharingStrategyProtocol {
    public static var scheduler: SchedulerType { return SharingScheduler.make() }
    public static func share<E>(_ source: Observable<E>) -> Observable<E> {
        return source.share(replay: 1, scope: .whileConnected)
    }
}
```

- IBOutletなプロパティのSignalへの変換
    - タップイベントをObservableのストリームではなく、Signalというストリームに変換
    - Signalの特性
        - Driverの特性にさらにreplayされないという特性を持っている
            - replayされない：過去のイベントを一切保持せず、その値も保持していない
            - Driverは、購読直後にもし最新のイベントがあれば、そのイベントを流そうとするが、Signalはそのような動作はしない。UIButtonのタップイベントに向いている
            - replayしないという挙動があることを型で表現することは、コードの意図を人へ伝えるという点においてとても意味のあること

- まとめ
    - Driverの特性について
        - エラーを伝達しないことを前提（onErrorが通知されない）
        - イベントはメインスレッドで観測されることを約束する
        - ストリームをHotn変換される（副作用が共有される）
    
    - DriverとSignalの違い
        - Driverは購読直後に過去のイベントを取得できる
            - UITextFieldなどの現在の文字列をイベントとして取得
            - Signalは購読直後にイベントが発生してから出ないと取得できない
