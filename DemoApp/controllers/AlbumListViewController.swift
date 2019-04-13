//
//  UserFeedViewController.swift
//  DemoApp
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

class AlbumListViewController : UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userTitle: UILabel!
    
    private let refreshControl = UIRefreshControl()
    
    var user: User!
    var viewModel: AlbumListViewModel!
    let bag = DisposeBag()
    let provider = (UIApplication.shared.delegate as! AppDelegate).provider
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AlbumListViewModel(user: user, provider: provider)
        userTitle.text = String(format: "someoneAlbums".localized(), user!.username!)
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
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Photo>>(
            configureCell: { dataSource, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
                let placeHolder = UIImage(named: "placeholderPhoto")
                cell.image.kf.setImage(with: URL(string: item.thumbnailUrl!)!, placeholder: placeHolder, options: [.transition(.fade(0.1))])
                return cell
        }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            let model = dataSource.sectionModels[indexPath.section]
            let title = model.model
            let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Section", for: indexPath) as! UserFeedSectionView
            section.title.text = title
            return section
        })
        
        viewModel.output.albums
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        viewModel.output.loading.drive(self.refreshControl.rx.isRefreshing).disposed(by: bag)
        
        //viewmodel input
        refreshControl.rx.controlEvent(UIControlEvents.valueChanged).bind(to: viewModel.input.refresh).disposed(by: bag)
    }
    
}

extension AlbumListViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let cellWidth = width / 3
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
