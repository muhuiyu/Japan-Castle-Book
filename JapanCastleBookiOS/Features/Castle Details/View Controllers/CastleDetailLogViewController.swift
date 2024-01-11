//
//  CastleDetailLogViewController.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit

class CastleDetailLogViewController: ViewController {
    private let viewModel: CastleDetailViewModel
    
    private let tableView = UITableView()
    
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
extension CastleDetailLogViewController {
    
    private func configureViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(CastleDetailLogStampCell.self, forCellReuseIdentifier: CastleDetailLogStampCell.reuseID)
        tableView.register(CastleDetailLogPreviewCell.self, forCellReuseIdentifier: CastleDetailLogPreviewCell.reuseID)
        view.addSubview(tableView)
    }
    
    private func configureConstraints() {
        tableView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Handlers
extension CastleDetailLogViewController {
    private func didTapAddStampButton() {
        let alert = CastleAlertComposer.castleDetailAddStampAlertComposedWith(
            navigateToAddDigitalStamp: didTapAddDigitalStamp,
            navigateToTakePhoto: didTapTakePhoto)
        present(alert, animated: true)
    }
    
    private func didTapStampImageView() {
        let alert = CastleAlertComposer.castleDetailEditStampAlertComposedWith(didTapRemoveStamp: didTapRemoveStamp)
        present(alert, animated: true)
    }
    
    private func didTapRemoveStamp() {
        DispatchQueue.main.async { [weak self] in
            self?.removeStamp()
            self?.tableView.reloadRows(at: [CastleDetailViewModel.Constants.stampCellIndexPath], with: .automatic)
        }
    }
    
    private func removeStamp() {
        
    }
    
    private func didTapAddDigitalStamp() {
        
    }
    
    private func didTapTakePhoto() {
        
    }
}

// MARK: - TableView
extension CastleDetailLogViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CastleDetailLogViewController.numberOfStampCells + viewModel.visitHistoryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case CastleDetailLogViewController.stampCellIndex:
            return makeLogStampCell(tableView, cellForRowAt: indexPath)
        default:
            return makeLogPreviewCell(tableView, cellForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Helpers
extension CastleDetailLogViewController {
    static let stampCellIndex = 0
    static let numberOfStampCells = 1
    
    private func makeLogStampCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CastleDetailLogStampCell.reuseID, for: indexPath) as? CastleDetailLogStampCell else {
            return UITableViewCell()
        }
        cell.didTapAddStamp = { [weak self] in
            self?.didTapAddStampButton()
        }
        cell.didTapStamp = { [weak self] in
            self?.didTapStampImageView()
        }
        return cell
    }
    
    private func makeLogPreviewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CastleDetailLogPreviewCell.reuseID, for: indexPath) as? CastleDetailLogPreviewCell else {
            return UITableViewCell()
        }
        cell.data = viewModel.visitHistoryData[indexPath.row - CastleDetailLogViewController.numberOfStampCells]
        return cell
    }
}

