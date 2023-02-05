import RxSwift

@main
public struct chapter02 {
    public static func main() {
        _ = Observable.just(10)
            .map({ $0 * 2})
            .subscribe(onNext: { print($0) })
        
        _ = Observable.just(10)
            .map({ (arg: Int) -> Int in
                return arg * 2
            })
            .subscribe(onNext: {(arg: Int) -> Void in
                print(arg)
            })
        
        _ = Observable.just(10)
            .map({ (arg: Int) -> String in
                return "value: \(arg)"
            })
            .subscribe(onNext: { (arg: String) -> Void in
                print(arg)
            })
        
        /*
         RxSwiftは、どのようにメソッドチェインを実現しているか
         
         // RxSwiftにおけるObservableType.just
         // Self.Eはジェネリクス
         extension ObservableType {
            public static func just(_ element: Self.E) -> RxSwift.Observable<Self.E>
         }
         
         // Rx/RxSwift/Observable.swift
         public Observable<Element>: ObservableType {
            // Type of elements in sequence.
            public typealias E = Element
         }
         
         (ex) Self.EをIntに置き換える
         extension ObservableType {
            public static func just(_ element: Int) -> RxSwift.Observable<Int>
         }
         
         // Rx/RxSwift/Observables/Map.swift
         extension ObservableType {
            public func map<R>(_ transform: @escaping (Self.E) throws -> R) -> RxSwift.Obsrevable<R>
         }
         
         ※ Rについては、クロージャの戻り値およびmap自体の戻り値によって決定
         ・クロージャの戻り値：@escaping (Self.E) throws -> R
         ・map自体の戻り値：RxSwift.Observable<R>
         
         つまり、
         mapのクロージャの戻り値をIntとすると、RはInt
         mapのクロージャの戻り値をStringとすると、RはString
         
         // Rx/RxSwift/ObservableType+Extentions.swift
         extension ObservableType {
            public func subscribe(onNext: ((Self.E) -> Swift.Void)? = default, ...) -> Disposable
         }
         
         // Self.EをStringに置き換える
         extension ObservableType {
            public func subscribe(onNext: ((String) -> Swift.Void)? = default, ...) -> Disposable
         }
         */
    }
}
