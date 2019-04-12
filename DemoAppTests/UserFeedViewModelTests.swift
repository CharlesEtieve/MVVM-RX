//
//  UserFeedViewModelTests.swift
//  v-labsTests
//
//  Created by Charles Etieve on 19/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import XCTest
import Moya
import RxTest
import RxSwift
import RxBlocking
import RxCocoa

@testable import DemoApp

class UserFeedViewModelTests: XCTestCase {
    
    var viewModel: UserFeedViewModel!
    var testScheduler: TestScheduler!
    var bag: DisposeBag!
    let provider = MoyaProvider<MyService>(stubClosure: MoyaProvider.immediatelyStub)

    override func setUp() {
        // called before the invocation of each test
        super.setUp()
        testScheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
        provider.rx.request(.readUsers)
            .mapArray(User.self)
            .subscribe { event in
                switch event {
                case .success(let userList):
                    let firstUser = userList[0]
                    self.viewModel = UserFeedViewModel(user: firstUser, provider: self.provider)
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
        
        let reloadTime = 100
        let loading = testScheduler.createObserver(Bool.self)
        
        viewModel.output.loading.drive(loading).disposed(by: bag)
        
        let refresh = testScheduler.createHotObservable([next(reloadTime, ())])
        refresh.bind(to: viewModel.input.refresh).disposed(by: bag)
        
        testScheduler.start()
        
        XCTAssertEqual(getTimeFrom(observer: loading, recordIndex: 0), 0)
        XCTAssertEqual(getValueFrom(observer: loading, recordIndex: 0), false)
        XCTAssertEqual(getTimeFrom(observer: loading, recordIndex: 1), reloadTime)
        XCTAssertEqual(getValueFrom(observer: loading, recordIndex: 1), true)
        XCTAssertEqual(getTimeFrom(observer: loading, recordIndex: 2), reloadTime)
        XCTAssertEqual(getValueFrom(observer: loading, recordIndex: 2), false)
    }

    func testOutputUserFeed() {
        
        let reloadTime = 100
        
        let tableView = testScheduler.createObserver([MultipleSectionModel].self)
        viewModel.output.feed.drive(tableView).disposed(by: bag)
        
        let refresh = testScheduler.createHotObservable([next(reloadTime, ())])
        refresh.bind(to: viewModel.input.refresh).disposed(by: bag)
        
        testScheduler.start()
        
        XCTAssertEqual(getTimeFrom(observer: tableView, recordIndex: 0), 0)
        if let sections = getValueFrom(observer: tableView, recordIndex: 0) {
            XCTAssertEqual(sections.count, 11)
            let postSection = sections[0]
            let postItems = postSection.items
            let postItem = postItems[0]
            switch postItem {
            case .PostSection(let post) :
                XCTAssertEqual(post.id, 1)
                XCTAssertEqual(post.userId, 1)
                XCTAssertEqual(post.title, "sunt aut facere repellat provident occaecati excepturi optio reprehenderit")
                XCTAssertEqual(post.body, "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
            case .PhotoSection(_):
                XCTFail()
            }
            let photoSection = sections[1]
            let photoItems = photoSection.items
            let photo = photoItems[0]
            switch photo {
            case .PostSection(_) :
                XCTFail()
            case .PhotoSection(let photo):
                XCTAssertEqual(photo.url, "https://via.placeholder.com/600/92c952")
            }
        }
        
        XCTAssertEqual(getTimeFrom(observer: tableView, recordIndex: 1), reloadTime)
        if let sections = getValueFrom(observer: tableView, recordIndex: 1) {
            XCTAssertEqual(sections.count, 11)
            let postSection = sections[0]
            let postItems = postSection.items
            let postItem = postItems[0]
            switch postItem {
            case .PostSection(let post) :
                XCTAssertEqual(post.id, 1)
                XCTAssertEqual(post.userId, 1)
                XCTAssertEqual(post.title, "sunt aut facere repellat provident occaecati excepturi optio reprehenderit")
                XCTAssertEqual(post.body, "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
            case .PhotoSection(_):
                XCTFail()
            }
            let photoSection = sections[1]
            let photoItems = photoSection.items
            let photo = photoItems[0]
            switch photo {
            case .PostSection(_) :
                XCTFail()
            case .PhotoSection(let photo):
                XCTAssertEqual(photo.url, "https://via.placeholder.com/600/92c952")
            }
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
