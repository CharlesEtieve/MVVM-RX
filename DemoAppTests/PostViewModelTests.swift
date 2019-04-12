//
//  PostViewModelTests.swift
//  v-labsTests
//
//  Created by Charles Etieve on 20/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import XCTest
import Moya
import RxTest
import RxSwift
import RxBlocking
import RxCocoa

@testable import DemoApp

class PostViewModelTests: XCTestCase {

    var viewModel: PostViewModel!
    var testScheduler: TestScheduler!
    var bag: DisposeBag!
    let provider = MoyaProvider<MyService>(stubClosure: MoyaProvider.immediatelyStub)
    
    override func setUp() {
        // called before the invocation of each test
        super.setUp()
        testScheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
        provider.rx.request(.readPostForUser(userId: "1"))
            .mapArray(Post.self)
            .subscribe { event in
                switch event {
                case .success(let postList):
                    let firstPost = postList[0]
                    self.viewModel = PostViewModel(post: firstPost, provider: self.provider)
                case .error(_):
                    break
                }
            }.disposed(by: bag)
    }
    
    override func tearDown() {
        // called after the invocation of each test
        super.tearDown()
        viewModel = nil
        testScheduler = nil
        bag = nil
    }
    
    func testOutputLoading() {
        let loading = testScheduler.createObserver(Bool.self)
        viewModel.output.loading.drive(loading).disposed(by: bag)
        
        let buttonTapped = testScheduler.createHotObservable([next(100, ()), next(200, ())])
        buttonTapped.bind(to: viewModel.input.buttonTapped).disposed(by: bag)
        
        testScheduler.start()
        
        XCTAssertEqual(getTimeFrom(observer: loading, recordIndex: 0), 0)
        XCTAssertEqual(getValueFrom(observer: loading, recordIndex: 0), false)
        XCTAssertEqual(getTimeFrom(observer: loading, recordIndex: 1), 100)
        XCTAssertEqual(getValueFrom(observer: loading, recordIndex: 1), true)
        XCTAssertEqual(getTimeFrom(observer: loading, recordIndex: 2), 100)
        XCTAssertEqual(getValueFrom(observer: loading, recordIndex: 2), false)
    }
    
    func testOutputButtonTitle() {
        let buttonTitle = testScheduler.createObserver(String.self)
        viewModel.output.buttonTitle.drive(buttonTitle).disposed(by: bag)
        
        let buttonTapped = testScheduler.createHotObservable([next(100, ()), next(200, ())])
        buttonTapped.bind(to: viewModel.input.buttonTapped).disposed(by: bag)
        
        testScheduler.start()
        
        XCTAssertEqual(getTimeFrom(observer: buttonTitle, recordIndex: 0), 0)
        XCTAssertEqual(getValueFrom(observer: buttonTitle, recordIndex: 0), "openCommentButton".localized())
        XCTAssertEqual(getTimeFrom(observer: buttonTitle, recordIndex: 1), 100)
        XCTAssertEqual(getValueFrom(observer: buttonTitle, recordIndex: 1), "closeCommentButton".localized())
        XCTAssertEqual(getTimeFrom(observer: buttonTitle, recordIndex: 2), 200)
        XCTAssertEqual(getValueFrom(observer: buttonTitle, recordIndex: 2), "openCommentButton".localized())
    }

    func testOutputComments() {
        let comments = testScheduler.createObserver([Comment].self)
        viewModel.output.comments.drive(comments).disposed(by: bag)
    
        let buttonTapped = testScheduler.createHotObservable([next(100, ()), next(200, ())])
        buttonTapped.bind(to: viewModel.input.buttonTapped).disposed(by: bag)
        
        testScheduler.start()
        
        XCTAssertEqual(getTimeFrom(observer: comments, recordIndex: 0), 0)
        if let comments = getValueFrom(observer: comments, recordIndex: 0) {
            XCTAssertEqual(comments.count, 0)
        }
        
        XCTAssertEqual(getTimeFrom(observer: comments, recordIndex: 1), 100)
        if let comments = getValueFrom(observer: comments, recordIndex: 1) {
            XCTAssertEqual(comments.count, 5)
            let firstComment = comments[0]
            XCTAssertEqual(firstComment.id, 1)
            XCTAssertEqual(firstComment.postId, 1)
            XCTAssertEqual(firstComment.name, "id labore ex et quam laborum")
            XCTAssertEqual(firstComment.email, "Eliseo@gardner.biz")
            XCTAssertEqual(firstComment.body, "laudantium enim quasi est quidem magnam voluptate ipsam eos\ntempora quo necessitatibus\ndolor quam autem quasi\nreiciendis et nam sapiente accusantium")
        }
        
        XCTAssertEqual(getTimeFrom(observer: comments, recordIndex: 2), 200)
        if let comments = getValueFrom(observer: comments, recordIndex: 2) {
            XCTAssertEqual(comments.count, 0)
        }
        
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func getValueFrom<T>(observer: TestableObserver<T>, recordIndex : Int) -> T? {
        let records = observer.events
        if recordIndex < records.count {
            let record = records[recordIndex]
            let value = record.value
            if let result = value.element {
                return result
            }
            if let error = value.error {
                XCTFail(error.localizedDescription)
            }
        } else {
            XCTFail("no record for index")
        }
        return nil
    }
    
    func getTimeFrom<T>(observer: TestableObserver<T>, recordIndex : Int) -> Int? {
        let records = observer.events
        if recordIndex < records.count {
            let record = records[recordIndex]
            return record.time
        } else {
            XCTFail("no record for index")
        }
        return nil
    }

}
