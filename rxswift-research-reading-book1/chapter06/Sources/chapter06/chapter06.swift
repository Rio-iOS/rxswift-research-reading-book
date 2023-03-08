import RxSwift
import RxCocoa
import Foundation

@main
public struct chapter06 {
   
    public static func main() {
        // combineLatest()
        /*
         【注目点】
         repeatedPassword: PublishSubject<String>()の値が変わっても、
         常にpassword: PublishSubject<String>()の最新の値abのみを使っている
         
         combineLatestは最新の値へと切り替わるごとに動作し、
         合成される全てのストリームの最新の値を使っている
         */
        let password = PublishSubject<String>()
        let repeatedPassword = PublishSubject<String>()
        
        _ = Observable.combineLatest(password, repeatedPassword) { "\($0), \($1)" }
            .subscribe(onNext: {
                print("onNext: \($0)")
            })
        
        password.onNext("a")
        password.onNext("ab")
        
        repeatedPassword.onNext("A")
        repeatedPassword.onNext("AB")
        repeatedPassword.onNext("ABC")
        
        // zip()
        /*
         【注目点】
         入力として実行する1,2,3,4の順序とA,B,C,Dのそれぞれの順序が、
         出力時にも揃っていること
         
         (ex)
         2の後にAのデータが発生させても、それは別々の順序のため関係ない
         
         zipは、どちらかの値が最新ではない可能性があることに気を付ける必要がある
         zip()は、最新の結果の状態をチェックするのには向かない
         実際は、「イベントが揃ったら動作する仕組みとして割り切って使う」
         */
        let intSubject = PublishSubject<Int>()
        let stringSubject = PublishSubject<String>()
        
        _ = Observable.zip(intSubject, stringSubject) {"\($0) \($1)"}
            .subscribe(onNext: {
                print($0)
            })
        
        intSubject.onNext(1)
        intSubject.onNext(2)
        
        stringSubject.onNext("A")
        stringSubject.onNext("B")
        stringSubject.onNext("C")
        stringSubject.onNext("D")
        
        intSubject.onNext(3)
        intSubject.onNext(4)
       
        // flatMapLatest
        /*
         flatMapLatestを使うことによって、
         連続したイベントから最新でないイベントを購読しなくて済むというメリットがある。
         
         a: -(○:1)-(○:2)->
         b: -(□)->
         結果：-(□:1)-(□:2)->
         ストリーム「b」における四角変換までの長さをt1とすると、
         変換結果である最下段のストリームへ「四角1」と「四角2」のイベントとして変換されるまでの時間である
         
         ストリーム「a」のおけるイベント「1」と「2」までの長さt2は、
         イベント「1」の発火後から「2」が発火するまでの時間
         このt2をt1より短くした場合にどうなるか（条件：t2 < t1）
         
         a: -(○:1)-(○:2)->
         b: -(□)->
         結果： -(□:2)->
         変換結果である最下段のストリームには、四角変換された「□:1」がなくなっており、
         同じく四角変換された「□:2」のみが残っている。
         このような動作となる理由としては、イベン「1」を四角に変換し終えるより前に、
         「2」の四角変換が始まったことでflatMapLatestは「1」の変換をdisposeする
         
         flatMapLatestを使うことで、連続したイベントから最新でないイベントを購読しなくて済むというメリット
         注意するべきこととしては、最新かどうかという点についてはイベントの変換時間と、
         変換元となるイベントの連続する時間が関係する
         つまり、必ずしも最新のみを購読できるわけではない。
         さらに、変換元の連続するイベントに対する変換自体は実行されており、
         途中でdisposeされることにより結果が購読されないということ
         */
        
        // withLatestFrom
        /*
         a: -(○:1)-(○:2)-(○:3)-(○:4)->
         b: --(□:1)-(□:2)-(□:3)-(□:4)->
         結果：-(□:2)-(□:3)-(□:4)->
         ストリーム「a」のイベント「1」が実行されても「b」のストリームに要素がないため
         何も出力されない
         ストリーム「a」のイベント「2」が実行された際「b」のストリームとしては「1」の要素があるため
         そのタイミングで「□:2」が出力される
         ストリーム「a」のイベント「3」が実行された際「b」のストリームとしては「2」の要素があるため
         そのタイミングで「□:3」が出力される
         ストリーム「a」のイベント「4」が実行された際「b」のストリームとしては「3」の要素があるため
         そのタイミングで「□:4」が出力される
         */
    }
}
