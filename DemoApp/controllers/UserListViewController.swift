//
//  ViewController.swift
//  DemoApp
//
//  Created by Charles Etieve on 01/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import UIKit
import Moya
import Moya_ObjectMapper
import RxSwift
import RxCocoa
import RxDataSources

class UserListViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableview: UITableView!
    private let refreshControl = UIRefreshControl()
    
    let bag = DisposeBag()
    private var viewModel: UserListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        viewModel = UserListViewModel(provider: appDelegate.provider, navigationController: self.navigationController)
        
        if #available(iOS 10.0, *) {
            tableview.refreshControl = refreshControl
        } else {
            tableview.addSubview(refreshControl)
        }
        
        tableview.delegate = self
        
        bindViewModel()
    }
    
    func bindViewModel() {
        //viewmodel output
        viewModel.output.users.drive(tableview.rx.items(cellIdentifier: "Cell")) { index, model, cell in
                let userCell = cell as! UserCell
                userCell.user = model
            }.disposed(by: bag)
        viewModel.output.loading.drive(self.refreshControl.rx.isRefreshing).disposed(by: bag)
        viewModel.output.error.drive(onNext: { error in
                self.displayAlert(error)
            }).disposed(by: bag)
        
        //viewmodel input
        refreshControl.rx.controlEvent(UIControlEvents.valueChanged).bind(to: viewModel.input.refresh).disposed(by: bag)
        tableview.rx.itemSelected.bind(to: viewModel.input.itemSelected).disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if let selectedIndexPath = tableview.indexPathForSelectedRow {
            tableview.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}

extension UserListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

