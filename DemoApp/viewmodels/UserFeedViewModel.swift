//
//  UserFeedViewModel.swift
//  v-labs
//
//  Created by Charles Etieve on 04/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import RxDataSources

class UserFeedViewModel {
    
    let output: Output
    var input: Input
    
    struct Output {
        var feed: Driver<[MultipleSectionModel]>
        var loading: Driver<Bool>
        var error: Driver<Error>
    }
    
    struct Input {
        var refresh: AnyObserver<Void>
    }
    
    private var feed = BehaviorSubject<[MultipleSectionModel]>(value: [MultipleSectionModel]())
    private var loading = ActivityIndicator()
    private var error = PublishSubject<Error>()
    private var refresh = PublishSubject<Void>()
    
    private let bag = DisposeBag()
    private let provider: MoyaProvider<MyService>
    private var user: User
    
    init(user: User, provider: MoyaProvider<MyService>) {
        self.user = user
        self.provider = provider
        output = Output(feed: feed.asDriver(onErrorJustReturn: [MultipleSectionModel]()),
                        loading: loading.asDriver(onErrorJustReturn: false),
                        error : error.asDriver(onErrorJustReturn: CustomError.init()))
        input = Input(refresh: refresh.asObserver())
        
        let userId = String(user.id!)
        
        refresh.asObservable()
            .flatMap { provider.rx.request(.readAlbumForUser(userId: userId)).trackActivity(self.loading) }
            .mapArray(Album.self)
            .subscribe { event in
                if let albums = event.element {
                    var albumsRequest = [Observable<[Photo]>]()
                    for album in albums {
                        let albumId = String(album.id!)
                        let observable = self.provider.rx
                            .request(.readPhotoForAlbum(albumId: albumId))
                            .trackActivity(self.loading).asSingle()
                            .mapArray(Photo.self)
                            .asObservable()
                        albumsRequest.append(observable)
                    }
                    
                    let postsRequest = self.provider.rx
                        .request(.readPostForUser(userId: userId))
                        .mapArray(Post.self)
                        .asObservable()
                    
                    Observable.zip(postsRequest, Observable.zip(albumsRequest)).subscribe { event in
                        
                        if let feed = event.element {
                            
                            let posts = feed.0
                            let photos = feed.1
                            
                            let sections = self.generateSections(posts, albums, photos)
                            self.feed.asObserver().onNext(sections)
                        }
                        if let error = event.error {
                            self.error.asObserver().onNext(error)
                        }
                        }.disposed(by: self.bag)
                }
                if let error = event.error {
                    self.error.asObserver().onNext(error)
                }
            }.disposed(by: bag)
        
        refresh.asObserver().onNext(())
    }
    
    func generateSections(_ posts: [Post], _ albums: [Album], _ photos: [[Photo]]) -> [MultipleSectionModel] {
        var sections = [MultipleSectionModel]()
        var postsSections = [SectionItem]()
        for post in posts {
            postsSections.append(SectionItem.PostSection(post: post))
        }
        sections.append(MultipleSectionModel.PostSection(title: "posts".localized(), items: postsSections))
        for index in 0...albums.count - 1 {
            let album = albums[index]
            let albumPhotos = photos[index]
            var photosSections = [SectionItem]()
            for photo in albumPhotos {
                photosSections.append(SectionItem.PhotoSection(photo: photo))
            }
            let section = MultipleSectionModel.PhotoSection(title: album.title!, items: photosSections)
            sections.append(section)
        }
        return sections
    }
    
}

enum MultipleSectionModel {
    case PhotoSection(title: String, items: [SectionItem])
    case PostSection(title: String, items: [SectionItem])
}

enum SectionItem {
    case PhotoSection(photo: Photo)
    case PostSection(post: Post)
}

extension MultipleSectionModel: SectionModelType {
    typealias Item = SectionItem
    
    var items: [SectionItem] {
        switch  self {
        case .PhotoSection(title: _, items: let items):
            return items.map {$0}
        case .PostSection(title: _, items: let items):
            return items.map {$0}
        }
    }
    
    init(original: MultipleSectionModel, items: [Item]) {
        switch original {
        case let .PhotoSection(title: title, items: _):
            self = .PhotoSection(title: title, items: items)
        case let .PostSection(title, _):
            self = .PostSection(title: title, items: items)
        }
    }
}

extension MultipleSectionModel {
    var title: String {
        switch self {
        case .PhotoSection(title: let title, items: _):
            return title
        case .PostSection(title: let title, items: _):
            return title
        }
    }
}
