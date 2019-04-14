//
//  UserFeedViewModelTests.swift
//  DemoAppTests
//
//  Created by Charles Etieve on 19/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import XCTest
import Moya
import RxTest
import RxSwift
import RxBlocking
import RxDataSources
import RxCocoa

@testable import DemoApp

class AlbumListViewModelTests: XCTestCase {
    
    var viewModel: AlbumListViewModel!
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
                    self.viewModel = AlbumListViewModel(user: firstUser, provider: self.provider, navigationController: nil)
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

    func testOutputAlbumList() {
        
        let reloadTime = 100
        
        let collectionView = testScheduler.createObserver([SectionModel<String, Photo>].self)
        viewModel.output.albums.drive(collectionView).disposed(by: bag)
        
        let refresh = testScheduler.createHotObservable([next(reloadTime, ())])
        refresh.bind(to: viewModel.input.refresh).disposed(by: bag)
        
        testScheduler.start()
        
        XCTAssertEqual(getTimeFrom(observer: collectionView, recordIndex: 0), 0)
        if let sections = getValueFrom(observer: collectionView, recordIndex: 0) {
            print(sections.count)
            XCTAssertEqual(sections.count, 10)
            XCTAssertEqual(sections[0].items[0].url, "https://via.placeholder.com/600/92c952")
        }
        
        XCTAssertEqual(getTimeFrom(observer: collectionView, recordIndex: 1), reloadTime)
        if let sections = getValueFrom(observer: collectionView, recordIndex: 1) {
            print(sections.count)
            XCTAssertEqual(sections.count, 10)
            XCTAssertEqual(sections[0].items[0].url, "https://via.placeholder.com/600/92c952")
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
