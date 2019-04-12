//
//  PostViewModel.swift
//  v-labs
//
//  Created by Charles Etieve on 07/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

class PostViewModel {
    
    var output: Output
    var input: Input
    
    struct Output {
        var comments: Driver<[Comment]>
        var loading: Driver<Bool>
        var error: Driver<Error>
        var buttonTitle: Driver<String>
    }
    
    struct Input {
        var buttonTapped: AnyObserver<Void>
    }
    
    private var comments = BehaviorSubject<[Comment]>(value: [Comment]())
    private var buttonTitle = BehaviorSubject<String>(value: "openCommentButton".localized())
    private var loading = ActivityIndicator()
    private var error = PublishSubject<Error>()
    private var buttonTapped = PublishSubject<Void>()
    
    private var post: Post
    private let bag = DisposeBag()
    private let provider: MoyaProvider<MyService>
    
    // for collectionview sizeAtItem that do not support Rx
    var rawOutput: RawOutput
    
    struct RawOutput {
        var title: String
        var body: String
        var displayComments: Bool
        var comments: [Comment]
    }
    
    init(post: Post, provider: MoyaProvider<MyService>) {
        self.post = post
        self.provider = provider
        output = Output(comments: comments.asDriver(onErrorJustReturn: [Comment]()),
                        loading: loading.asDriver(onErrorJustReturn: false),
                        error : error.asDriver(onErrorJustReturn: CustomError.init()),
                        buttonTitle: buttonTitle.asDriver(onErrorJustReturn: "openCommentButton".localized()))
        rawOutput = RawOutput(title: post.title!,
                              body: post.body!,
                              displayComments : false,
                              comments: [Comment]())
        input = Input(buttonTapped: buttonTapped.asObserver())
        
        buttonTapped.scan(false) { lastState, newValue in
            return !lastState
        }.subscribe { value in
            if let checked = value.element {
                if checked {
                    self.provider.rx
                        .request(.readCommentForPost(postId: String(post.id!)))
                        .trackActivity(self.loading).asSingle()
                        .mapArray(Comment.self)
                        .subscribe { event in
                            switch event {
                            case .success(let comments):
                                self.buttonTitle.asObserver().onNext("closeCommentButton".localized())
                                self.rawOutput.comments = comments
                                self.rawOutput.displayComments = true
                                self.comments.asObserver().onNext(comments)
                            case .error(let error):
                                self.error.asObserver().onNext(error)
                            }
                        }.disposed(by: self.bag)
                } else {
                    self.rawOutput.displayComments = false
                    self.rawOutput.comments = [Comment]()
                    self.buttonTitle.asObserver().onNext("openCommentButton".localized()) //TODO localized
                    self.comments.asObserver().onNext(Array<Comment>())
                }
            }
        }.disposed(by: bag)
    }
    
    
}

public class CustomError :  Error {
    var code : Int?
    var errors : [String]?
    var message : String?
}
