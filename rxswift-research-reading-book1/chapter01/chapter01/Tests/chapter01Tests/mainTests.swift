//
//  mainTests.swift
//  
//
//  Created by 藤門莉生 on 2023/02/04.
//

import XCTest
import RxTest
import RxSwift

/*
 インクリメンタル検索を作る時、アプリを使うユーザはある程度すばやく文字を入力しているが、
 それと同時に必要のない情報をフィルタリングすることは重要である。
 全ての文字をそのまま処理するよりも、RxSwiftは時間の概念を保つことで、
 イベントのタイミングによっても処理を制御できるという特徴がある
 
 RxSwiftは、関数型プログラミングとリアクティブプログラミングにより、
 使い勝手の良いイベントドリブンなアプリケーション開発の手助けになる
 */
class MainTests: XCTestCase {
    func testRxTest() {
        /*
         コードに対する時間の表現は、RxSwiftのテスト用フレームワークであるRxTestを使う
         RxTest.TestSchedulerは仮想的な時間の経過の表現が可能になる
         テスト時には、この仮想的な時間を扱うことで、時間を再現したテストコードを書くことができる
         */
        let scheduler = TestScheduler(initialClock: 0)
        
        let obsevable = scheduler.createHotObservable([
            Recorded.next(1, "R"),
            Recorded.next(2, "Rx"),
            Recorded.next(3, "RxS"),
            Recorded.next(4, "RxSw"),
            Recorded.next(5, "RxSwi"),
            Recorded.next(6, "RxSwift"),
        ])
        
        /*
         debounce()メソッドにより、1秒以内の変更は無視されるため、1秒ごとに入力が続くイベントは
         最後の結果まで渡ってこない
         
         R-Rx-RxS-RxSw-RxSwi-RxSwif-RxSwift
         debounce(1)
         RxSwift
         */
        _ = obsevable
            .debounce(.seconds(1), scheduler: scheduler)
            .subscribe(onNext: {print("onNext: ", $0)})
        
        scheduler.start()
    }
    
    func testRxTest2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let observable = scheduler.createHotObservable([
            Recorded.next(1, "R"),
            Recorded.next(2, "Rx"),
            Recorded.next(4, "RxS"),
            Recorded.next(5, "RxSw"),
            Recorded.next(6, "RxSwi"),
            Recorded.next(7, "RxSwift"),
        ])
        
        /*
         RxからRxSの間に2秒ほど時間がかかっているということによって、
         debounceの1秒よりも長い時間となるので、
         文字列Rxは経過時間条件を抜けるため、イベントとして伝わる
         */
        _ = observable
            .debounce(.seconds(1), scheduler: scheduler)
            .subscribe(onNext: { print("onNext: ", $0) })
        
        scheduler.start()
    }
}
