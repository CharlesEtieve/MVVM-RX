//
//  UserFeedViewController.swift
//  v-labs
//
//  Created by Charles Etieve on 04/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import Kingfisher
import SVProgressHUD

class UserFeedViewController : UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userTitle: UILabel!
    private let refreshControl = UIRefreshControl()
    
    var user: User!
    var viewModel: UserFeedViewModel!
    var dataSource: RxCollectionViewSectionedReloadDataSource<MultipleSectionModel>!
    var postsViewModels = [IndexPath: PostViewModel]()
    let bag = DisposeBag()
    let provider = (UIApplication.shared.delegate as! AppDelegate).provider
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = UserFeedViewModel(user: user, provider: provider)
        userTitle.text = user.username
        
        collectionView.delegate = self
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        
        bindViewModel()
    }
    
    func bindViewModel() {
        
        //viewmodel output
        dataSource = RxCollectionViewSectionedReloadDataSource<MultipleSectionModel>(
            configureCell: { dataSource, collectionView, indexPath, item in
                switch dataSource[indexPath] {
                case let .PhotoSection(photo):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
                    cell.image.kf.setImage(with: URL(string: photo.thumbnailUrl!)!, options: [.transition(.fade(0.1))])
                    return cell
                case let .PostSection(post):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCell
                    let postViewModel = self.getPostViewModel(for: post)
                    
                    cell.viewModel = postViewModel
                    
                    postViewModel.output.comments.skip(1).drive(onNext: { _ in
                        self.collectionView.reloadItems(at: [indexPath])
                    }).disposed(by: self.bag)
                    postViewModel.output.error.drive(onNext: { error in
                        self.displayAlert(error)
                    }).disposed(by: self.bag)
                    postViewModel.output.loading.drive(SVProgressHUD.rx.isAnimating).disposed(by: self.bag)
                    
                    return cell
                }
        }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            let model = dataSource.sectionModels[indexPath.section]
            let title = model.title
            let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Section", for: indexPath) as! UserFeedSectionView
            section.title.text = title
            return section
        })
        
        viewModel.output.feed
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        viewModel.output.loading.drive(self.refreshControl.rx.isRefreshing).disposed(by: bag)
        
        //viewmodel input
        refreshControl.rx.controlEvent(UIControlEvents.valueChanged).bind(to: viewModel.input.refresh).disposed(by: bag)
    }
    
    var postViewModelDict = [Int: PostViewModel]()
    
    func getPostViewModel(for post: Post) -> PostViewModel {
        if let postViewModel = postViewModelDict[post.id!] {
            return postViewModel
        } else {
            let postViewModel = PostViewModel(post: post, provider: provider)
            postViewModelDict[post.id!] = postViewModel
            return postViewModel
        }
        
    }
    
}

extension UserFeedViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        switch dataSource[indexPath] {
        case .PhotoSection:
            let cellWidth = width / 3
            return CGSize(width: cellWidth, height: cellWidth)
        case let .PostSection(post):
            let postViewModel = getPostViewModel(for: post)
            let cellWidth = width
            return CGSize(width: cellWidth, height: PostCell.calculateHeight(cellWidth: cellWidth, viewModel: postViewModel))
        }
    }
}
