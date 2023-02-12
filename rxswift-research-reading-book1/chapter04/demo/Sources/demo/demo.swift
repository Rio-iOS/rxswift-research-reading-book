
import RxSwift
@main
public struct demo {

    public static func main() {
        let subject = PublishSubject<String>()
        
        let subscription = subject
            .subscribe(onNext: {
                print("onNext: ", $0)
            }, onCompleted: {
                print("終了")
            }, onDisposed: {
                print("破棄")
            })
        
        subject.onNext("1")
        subject.onNext("2")
        subscription.dispose()
        subject.onNext("3")
        subject.onNext("4")
        subject.onCompleted()
    }
}
