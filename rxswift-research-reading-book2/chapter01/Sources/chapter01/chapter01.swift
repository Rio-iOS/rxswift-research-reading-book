import RxSwift

@main
public struct chapter01 {
    // 異常終了
    public enum TestError: Error {
        case test
    }
    
    public static func main() {
        /*
         Rxではストリームにエラーイベントが通知されると、異常終了によりストリームは破棄され終了する。
         アプリ作りによってはそれで充分な可能性もあるが、購読が終了となることで困るパターンもある。
         それを解決するため、エラーイベントが発生することを想定し、複数ある手段の中から
         適切なエラーハンドリング手段を利用しないといけない。
         */
        /*
         2つの終了パターン
         適切なエラーハンドリング手法を選定するために、
         ストリーム購読には、「正常終了」と「異常終了」の2つの終了パターンがある
         2つの共通点は、終了後にイベントが購読されなくなることだが、
         正常終了と異常終了では動作的に違いがある。
         */
        /*
         Observable.ofによって作られた2つのイベント「1」「2」をきっかけに
         まず「1」のイベント「A」が発火して終了し、イベント「B」は発火されない
         同じようにイベント「2」でも「A」が発火して終了しする流れとなっている。
         subscribe()では、onCompletedはもちろん、onDisposedメソッドが呼び出される。
         ストリームはdisposeされる際にアクションを実行できる。
         Disposables.create()のクロージャでdisposeされた際に任意の処理を実行できる
         */
        // 正常終了
        let sequence = Observable.of(1, 2)
            .flatMap { string -> Observable<String> in
                print("flatMap: \(string)")
                let observable = Observable<String>.create { observer in
                    observer.onNext("A")
                    
                    observer.onCompleted()
                    
                    return Disposables.create() {
                        print("Dispose Action.")
                    }
                }
                return observable
            }
        
        _ = sequence.subscribe(onNext: {
            print("onNext: \($0)")
        }, onError: {
            print("onError: \($0)")
        }, onCompleted: {
            print("onCompleted:")
        }, onDisposed: {
            print("onDisposed:")
        })
        
        /*
         正常終了の結果と違う部分は、Observable.of(1, 2)ストリームにおけるイベント「2」が発火していないこと
         flatMapにより作成されたObservable<String>ストリームの異常終了により、
         Observable.of(1, 2)のストリームの購読を停止させられた
         
         エラーが通知されること自体は起こり得ることだが、
         それによってUIからのイベントを無視してしまうというのは想定外のはずであり、
         そのために正しいエラーハンドリングのための知識が重要になってくる
         */
        let sequence2 = Observable.of(1, 2).flatMap { string -> Observable<String> in
            print("flatMap: \(string)")
            let observable = Observable<String>.create { observer in
                observer.onNext("A")
                
                observer.onError(TestError.test)
                
                observer.onNext("B")
                
                return Disposables.create() {
                    print("Dispose Action")
                }
            }
            
            return observable
        }
        
        _ = sequence2.subscribe(onNext: {
            print("onNext: \($0)")
        }, onError: {
            print("onError: \($0)")
        }, onCompleted: {
            print("onCompleted:")
        }, onDisposed: {
            print("onDisposed:")
        })
        
        // 購読の破棄
        /*
         disposeされると、その後の「B」イベントは購読されなくなる。
         */
        let subject = PublishSubject<String>()
        
        let disposable = subject
            .subscribe(onNext: {
                print("onNext: \($0)")
            }, onError: {
                print("onError: \($0)")
            }, onCompleted: {
                print("onCompleted:")
            }, onDisposed: {
                print("onDisposed:")
            })
        
        subject.onNext("A")
        
        disposable.dispose()
        
        subject.onNext("B")
        
        subject.onCompleted()
    }
}
