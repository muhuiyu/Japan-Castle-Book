//
//  CastleDetailTableViewController.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit

class CastleDetailTableViewController: ViewController {
    private let tableView = UITableView()
    
    private let viewModel: CastleDetailViewModel
    
    init(viewModel: CastleDetailViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
    }
}

// MARK: - View Config
extension CastleDetailTableViewController {
    private func configureViews() {
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CastleDetailHeaderCell.self, forCellReuseIdentifier: CastleDetailHeaderCell.reuseID)
        tableView.register(CastleDetailMetadataCell.self, forCellReuseIdentifier: CastleDetailMetadataCell.reuseID)
        tableView.register(CastleDetailInfoCell.self, forCellReuseIdentifier: CastleDetailInfoCell.reuseID)
        view.addSubview(tableView)
    }
    
    private func configureConstraints() {
        tableView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension CastleDetailTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.infoData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowData = viewModel.infoData[indexPath.row]
        
        switch rowData {
        case .header(let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CastleDetailHeaderCell.reuseID, for: indexPath) as? CastleDetailHeaderCell else {
                 return UITableViewCell()
            }
            cell.data = data
            return cell
        case .metadata(let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CastleDetailMetadataCell.reuseID, for: indexPath) as? CastleDetailMetadataCell else {
                 return UITableViewCell()
            }
            cell.data = data
            return cell
        case .info(key: let key, value: let value):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CastleDetailInfoCell.reuseID, for: indexPath) as? CastleDetailInfoCell else { return UITableViewCell() }
            cell.title = key
            cell.value = value
            return cell
        case .infoIconValue(icon: let icon, value: let value):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CastleDetailInfoCell.reuseID, for: indexPath) as? CastleDetailInfoCell else { return UITableViewCell() }
            cell.imageName = icon
            cell.value = value
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
