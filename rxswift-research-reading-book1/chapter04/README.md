# RxExampleのディレクトリ構成とファイル内容
```
RxExample > Examples > GitHubSignup
- BindingExtensions.swift # extension集
- DefaultImplementations.swift # バリデート処理実装や通信実装
- GitHubSignup1.storyboard # 本章で利用する画面
- GitHubSignup2.storyboard # 本章で利用しない
- Protocols.swift # protocolおよびenum
- UsingDriver # 本章では利用しない
    - GitHubSignupViewController2.swift
    - GitHubSignupViewModel.swift
- UsingVanillaObservables # 本章のVCおよびVM
    - GitHubSignupViewController1.swift
    - GitHubSignupViewModel.swift
```

## ViewControllerの役割
- 役割1：StoryboardのUIコンポーネントをつなぐ
- 役割2：ViewModelを初期化する
- 役割3：ViewModelの出力とUIコンポーネントをバインドする
- 役割4：その他の処理
    - 画面上のタップを検知し、入力時のソフトウェアキーボードを閉じる

## ViewModelの役割
- 役割1：API用のロジックなどをイニシャライザで外部から用意できるようにする
- 役割2：イニシャライザで受け取ったObservableを処理して出力に変換
※ ViewModelのイニシャライザで入力されたストリームは、出力のストリームに変換されるだけのシンプルな構成をしており、出力ストリームとして読み取られるようになっている。  

## ViewControllerの実装
- disposeBagについて
- IBOutletをObservableに変換しViewModelへ渡す詳細
- ViewModelの出力をバインドする詳細
- ViewModelの入力から出力を変換する処理

## ViewModel
- Observableを変換するmapオペレータ
- Hot変換
- Observableを合成するcombineLatestオペレータ
- 最新の値を取得するwithLatestFromオペレータ

## 概要
ViewControllerにはそれぞれのIBOutletがあり、  
Storyboard上からコンポーネントをコードで利用できるようにする。
```
(ex) usernameOutlet: UITextField!
usernameOutlet: UITextField!はユーザ名テキスト入力を行うコンポーネントである

usernameValidationOutlet: UILabel!は、そのユーザ名のバリデート結果を表示する
```

次に、ViewModelをviewDidLoadメソッド内で初期化し、ViewControllerで保持せず利用する。  
これは、かなり割り切った使い方で、viewDidLoadが終了すると同時にviewModelは保持されていないことで破棄される。  
この王にしている理由は単にViewModelに状態がなく、ViewControllerのプロパティとして保持する必要がないためにやっているだけに過ぎないが、なぜViewModelが破棄されてもイベントの変換が動作し続けるのかはここではスルーする。  

最後に、ViewControllerはViewModelのプロパティに対してバインドし、ViewModelによって実行された結果をViewに反映する。  
ViewModelについて、出力のストリームは複数あるが、代表的なものだけ取り上げる。  
```
(ex)
validatedUsername: Observable<ValidationResult>はサインアップ用に入力されたユーザ名のバリデート結果をストリームとしており、ValidationResultをイベントとして伝える  
signupEnabled: Observable<Bool>はバリデート結果に関係なくサインアップできることを伝えるためのストリームとなる

```

## 継承によるdisposeBagの保持
- ViewController（GitHubSignupViewController1）は、サンプル用のViewControllerを継承しており、サンプルコード全体で使われるdisposeBagを保持する。
- disposeBag：まとめてObservableを処分するための仕組み
    - dsposeBagにを破棄することでObservableをまとめて破棄できる。
- ViewControllerが破棄されるとき、そのプロパティも自動で破棄されるためにdisposeBagの仕組みが働くようになっている。

## 任意のタイミングでのdispose
- disposeBagを使ってViewControllerの破棄同時にObservableをまとめて破棄することが一般的ではあるが、開発者の任意のタイミングでObservableを破棄することもできる。
- そのための方法として、subscribeメソッドの戻り値Disposableインスタンスに対してdispose()メソッドを呼び出す方法がある。


## IBOutletからObservableの作成
- ユーザ入力をイベントのストリームとしてViewModelへ伝えるため、IBOutletなUIコンポーネントからObservableを作成する必要がある。
```
(ex)usernameOutlet: UITextField!
username.rx.text.orEmpty.asObservable()を呼び出して、Observable<String>を取得
```

## ViewModelの出力をViewにバインド
- ViewModelで処理したプレゼンテーションロジックは、出力のストリームとしてViewにバインドする必要がある

```
(ex)ViewModelのsignupEnabled、がサインアップ可能かどうかのイベントしてバインドするviewModel.signupEnabled
// signupEnabled: Observable<Bool>に対するsubscribeメソッドのonNextクロージャにより、signupEnabledストリームの変化をBoolとして取得し、signupOutlet: UIButton!のisEnabledおよびalphaプロパティにバインディングすることで形状を変化させる
    .subscribe(onNext: {
        self?.signupOutlet.isEnabled = valid
        self?.signupOutlet.alpha = valid ? 1.0 : 0.5
    })
    .disposed(by: disposeBag)
```

```
(ex) UIバインディングの例としては、bind(to:)メソッドがある
// validatedUsernameはユーザ名をバリデートした結果をenumのイベントとして伝えるストリームで、usernameValidationOutlet: UILabel!に対してバインドしている
viewModel.validatedUsername
    .bind(to: usernameValidationOutlet.rx.validationResult)
    .dsposed(by: disposeBag)
```

```
(ex)Rx/RxCocoa/Observable+Bind.swift
// このメソッドの注目点は、メソッドの末尾にwhere O: ObserverType, Self.E == O.Eと記述された条件付きのジェネリクス関数になっており、これは「Generic Where Clauses」と呼ばれる。
// この条件としては、ObservableであるvalidatedUsernameをバインドする対象の引数observerとの間で、
// 「引数はObserverType」かつ「ObservableType.E == ObserverType.E」が成り立つ場合のメソッドという制約となっている。
// 具体的には、ViewModelの出力はvalidatedUsername: Observable<ValidationResult>であるので、
// バインドされるのはObserverType<ValidationResult>であるということが必要
extension ObservableType {
    public func bind<O: ObserverType>(to observer: O) -> Disposable where O.E == E {
    return self.subscribe(observer)
}
// 省略
}
```

```
// rx.validationResultプロパティは、BindingExtensions.swiftで以下のように実装
// Binder：RxSwiftによってObserverTypeプロトコルを採用する構造体である
// 実際のrx.validationResultの処理内容はバインドしたい実装をBinderで初期化することで、bindメソッド時にその処理が動作する
// ここでは、ValidationResultからテキストカラーと表示をUILabelに代入している
// これはコードを書く量を減らすために実装しているのであって、オリジナルバインド処理を毎回書かなければいけない訳ではない
extension Reactive where Base: UILabel {
    var validationResult: Binder<ValidationResult> {
        return Binder(base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}
```
