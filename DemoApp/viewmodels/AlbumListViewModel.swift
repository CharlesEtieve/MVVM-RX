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
        var itemSelected: AnyObserver<IndexPath>
    }
    
    private var albums = BehaviorSubject<[SectionModel<String, Photo>]>(value: [SectionModel<String, Photo>]())
    private var loading = ActivityIndicator()
    private var error = PublishSubject<Error>()
    private var refresh = PublishSubject<Void>()
    private var itemSelected = PublishSubject<IndexPath>()
    
    private let bag = DisposeBag()
    private let provider: MoyaProvider<MyService>
    private var user: User
    private var navigationController: UINavigationController
    
    init(user: User, provider: MoyaProvider<MyService>, navigationController: UINavigationController) {
        self.user = user
        self.provider = provider
        self.navigationController = navigationController
        output = Output(albums: albums.asDriver(onErrorJustReturn:  [SectionModel<String, Photo>]()),
                        loading: loading.asDriver(onErrorJustReturn: false),
                        error : error.asDriver(onErrorJustReturn: CustomError.init()))
        input = Input(refresh: refresh.asObserver(),
                      itemSelected: itemSelected.asObserver())
        
        let userId = String(user.id!)
        
        refresh.asObservable()
            .flatMap { provider.rx.request(.readAlbumForUser(userId: userId)).trackActivity(self.loading) }
            .mapArray(Album.self)
            .flatMap ({ albums -> Observable<[(String, [Photo])]> in
                var albumsRequest = [Observable<(String, [Photo])>]()
                for album in albums {
                    if let albumId = album.id, let albumTitle = album.title {
                        let observable = self.provider.rx
                            .request(.readPhotoForAlbum(albumId: String(albumId)))
                            .trackActivity(self.loading)
                            .mapArray(Photo.self)
                            .asObservable()
                            .map { photos in (albumTitle, photos) }
                        albumsRequest.append(observable)
                    }
                }
                return Observable.combineLatest(albumsRequest) { $0 }
            })
            .subscribe { event in
                if let albums = event.element {
                    var array = [SectionModel<String, Photo>]()
                    for album in albums {
                        array.append(SectionModel<String, Photo>(model: album.0, items: album.1))
                    }
                    self.albums.asObserver().onNext(array)
                }
                if let error = event.error {
                    self.error.asObserver().onNext(error)
                }
            }.disposed(by: bag)
        
        refresh.asObserver().onNext(())
        
        itemSelected.asObservable().subscribe { event in
            if let indexPath = event.element {
                if let photo = self.getPhoto(at: indexPath) {
                    let storyBoard = UIStoryboard(name: "Photo", bundle: nil)
                    let viewController = storyBoard.instantiateViewController(withIdentifier: "photoControllerID") as! PhotoViewController
                    viewController.photo = photo
                    self.navigationController.pushViewController(viewController, animated: true)
                }
            }
        }.disposed(by: bag)
    }
    
    private func getPhoto(at indexPath: IndexPath) -> Photo? {
        do {
            return try albums.value()[indexPath.section].items[indexPath.row]
        } catch {
            return nil
        }
    }
    
}
