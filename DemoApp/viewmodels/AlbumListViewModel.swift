//
//  UserFeedViewModel.swift
//  DemoApp
//
//  Created by Charles Etieve on 04/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import RxDataSources

class AlbumListViewModel {
    
    let output: Output
    var input: Input
    
    struct Output {
        var albums: Driver<[SectionModel<String, Photo>]>
        var loading: Driver<Bool>
        var error: Driver<Error>
    }
    
    struct Input {
        var refresh: AnyObserver<Void>
    }
    
    private var albums = BehaviorSubject<[SectionModel<String, Photo>]>(value: [SectionModel<String, Photo>]())
    private var loading = ActivityIndicator()
    private var error = PublishSubject<Error>()
    private var refresh = PublishSubject<Void>()
    
    private let bag = DisposeBag()
    private let provider: MoyaProvider<MyService>
    private var user: User
    
    init(user: User, provider: MoyaProvider<MyService>) {
        self.user = user
        self.provider = provider
        output = Output(albums: albums.asDriver(onErrorJustReturn:  [SectionModel<String, Photo>]()),
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
                    
                    Observable.zip(albumsRequest).subscribe { event in
                        
                        if let photosArray = event.element {
                            
                            var array = [SectionModel<String, Photo>]()
                            
                            for index in 0...photosArray.count-1 {
                                array.append(SectionModel<String, Photo>(model: albums[index].title!, items: photosArray[index]))
                            }
                            
                            self.albums.asObserver().onNext(array)
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
    
}
