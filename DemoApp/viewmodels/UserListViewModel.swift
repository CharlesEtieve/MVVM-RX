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
        var itemSelected: AnyObserver<IndexPath>
    }
    
    private var users = BehaviorSubject<[User]>(value: [User]())
    private var loading = ActivityIndicator()
    private var error = PublishSubject<Error>()
    private var refresh = PublishSubject<Void>()
    private var itemSelected = PublishSubject<IndexPath>()
    
    private let bag = DisposeBag()
    private var provider: MoyaProvider<MyService>
    private var navigationController: UINavigationController?
    
    init(provider: MoyaProvider<MyService>, navigationController: UINavigationController?) {
        self.provider = provider
        self.navigationController = navigationController
        output = Output(users: users.asDriver(onErrorJustReturn: [User]()),
                        loading: loading.asDriver(onErrorJustReturn: false),
                        error : error.asDriver(onErrorJustReturn: CustomError.init()))
        input = Input(refresh: refresh.asObserver(),
                      itemSelected: itemSelected.asObserver())
        
        refresh.asObservable()
            .flatMap { provider.rx.request(.readUsers).trackActivity(self.loading) }
            .mapArray(User.self)
            .catchError { error -> Observable<[User]> in
                self.error.asObserver().onNext(error)
                return Observable.just([User]())
            }
            .bind(to: self.users.asObserver())
            .disposed(by: bag)
            
        itemSelected.asObservable().subscribe { event in
            if let indexPath = event.element {
                if let user = self.getUser(at: indexPath) {
                    let storyBoard = UIStoryboard(name: "AlbumList", bundle: nil)
                    let viewController = storyBoard.instantiateViewController(withIdentifier: "AlbumListControllerID") as! AlbumListViewController
                    viewController.user = user
                    navigationController?.pushViewController(viewController, animated: true)
                }
            }
            }.disposed(by: bag)
        
        refresh.asObserver().onNext(())
    }
    
    private func getUser(at indexPath: IndexPath) -> User? {
        do {
            return try users.value()[indexPath.row]
        } catch {
            return nil
        }
    }
    
}

public class CustomError :  Error {
    var code : Int?
    var errors : [String]?
    var message : String?
}
