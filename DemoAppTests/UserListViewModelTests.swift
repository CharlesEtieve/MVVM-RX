//
//  UserListViewModelTests.swift
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

class UserListViewModelTests: XCTestCase {
    
    var viewModel: UserListViewModel!
    var testScheduler: TestScheduler!
    var bag: DisposeBag!
    let provider = MoyaProvider<MyService>(stubClosure: MoyaProvider.immediatelyStub)

    override func setUp() {
        // called before the invocation of each test
        super.setUp()
        viewModel = UserListViewModel(provider: provider)
        testScheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
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
        
        let reloadTime = 100
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

    func testOutputUsers() {
        let tableView = testScheduler.createObserver([User].self)
        viewModel.output.users.drive(tableView).disposed(by: bag)
        
        let reloadTime = 100
        let refresh = testScheduler.createHotObservable([next(reloadTime, ())])
        refresh.bind(to: viewModel.input.refresh).disposed(by: bag)
        
        testScheduler.start()
        
        XCTAssertEqual(getTimeFrom(observer: tableView, recordIndex: 0), 0)
        if let users = getValueFrom(observer: tableView, recordIndex: 0) {
            let firstUser = users[0]
            XCTAssertEqual(users.count, 10)
            XCTAssertEqual(firstUser.id, 1)
            XCTAssertEqual(firstUser.name, "Leanne Graham")
            XCTAssertEqual(firstUser.email, "Sincere@april.biz")
            XCTAssertEqual(firstUser.phone, "1-770-736-8031 x56442")
        }
        XCTAssertEqual(getTimeFrom(observer: tableView, recordIndex: 1), reloadTime)
        if let users = getValueFrom(observer: tableView, recordIndex: 1) {
            let firstUser = users[0]
            XCTAssertEqual(users.count, 10)
            XCTAssertEqual(firstUser.id, 1)
            XCTAssertEqual(firstUser.name, "Leanne Graham")
            XCTAssertEqual(firstUser.email, "Sincere@april.biz")
            XCTAssertEqual(firstUser.phone, "1-770-736-8031 x56442")
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
