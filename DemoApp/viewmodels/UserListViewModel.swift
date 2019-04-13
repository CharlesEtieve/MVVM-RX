//
//  UsersViewModel.swift
//  DemoApp
//
//  Created by Charles Etieve on 02/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

class UserListViewModel {
    
    let output: Output
    var input: Input
    
    struct Output {
        var users: Driver<[User]>
        var loading: Driver<Bool>
        var error: Driver<Error>
    }
    
    struct Input {
        var refresh: AnyObserver<Void>
    }
    
    private var users = BehaviorSubject<[User]>(value: [User]())
    private var loading = ActivityIndicator()
    private var error = PublishSubject<Error>()
    private var refresh = PublishSubject<Void>()
    
    private var userList = [User]()
    private let bag = DisposeBag()
    private var provider: MoyaProvider<MyService>
    
    init(provider: MoyaProvider<MyService>) {
        self.provider = provider
        output = Output(users: users.asDriver(onErrorJustReturn: [User]()),
                        loading: loading.asDriver(onErrorJustReturn: false),
                        error : error.asDriver(onErrorJustReturn: CustomError.init()))
        input = Input(refresh: refresh.asObserver())
        
        refresh.asObservable()
            .flatMap { provider.rx.request(.readUsers).trackActivity(self.loading) }
            .mapArray(User.self)
            .subscribe { event in
                if let userList = event.element {
                    self.userList = userList
                    self.users.asObserver().onNext(userList)
                }
                if let error = event.error {
                    self.error.asObserver().onNext(error)
                }
            }.disposed(by: bag)
        
        refresh.asObserver().onNext(())
    }
    
    func getUserAt(index: Int) -> User {
        return userList[index]
    }
    
}

public class CustomError :  Error {
    var code : Int?
    var errors : [String]?
    var message : String?
}
