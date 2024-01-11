//
//  CastleListViewController.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit

class CastleListViewController: BaseViewController<CastleListViewModel> {
    
    private let layout = UICollectionViewFlowLayout()
    private(set) lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private let spinnerView = UIActivityIndicatorView()
    private let errorView = UILabel()
    
    private var collectionSections = [SectionData]() { didSet { collectionView.reloadData() } }
    
    struct SectionData {
        var items: [CastleListCellViewModel]
        var title: String
        var backgroundColor: UIColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadCastles()
        hidesBottomBarWhenPushed = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hidesBottomBarWhenPushed = false
    }
}

extension CastleListViewController {
    
    private func configureViews() {
        title = Text.castleListViewControllerTitle
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CastleCollectionCell.self, forCellWithReuseIdentifier: CastleCollectionCell.reuseID)
        collectionView.register(CastleCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CastleCollectionHeaderView.reuseID)
        view.addSubview(collectionView)
        
        spinnerView.startAnimating()
        view.addSubview(spinnerView)
        
        errorView.isHidden = true
        view.addSubview(errorView)
    }
    
    private func configureConstraints() {
        collectionView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        spinnerView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
        errorView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func configureBindings() {
        viewModel.$castles
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.reconfigureCells()
                self.reconfigureSpinnerView()
            }
            .store(in: &subscriptions)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message {
                    self?.errorView.text = message
                    self?.errorView.isHidden = false
                } else {
                    self?.errorView.text = nil
                    self?.errorView.isHidden = true
                }
            }
            .store(in: &subscriptions)
    }
    
    private func reconfigureCells() {
        collectionSections = viewModel.getCollectionViewSectionData()
    }
    
    private func reconfigureSpinnerView() {
        spinnerView.stopAnimating()
        spinnerView.isHidden = true
    }
}

extension CastleListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionSections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastleCollectionCell.reuseID, for: indexPath) as? CastleCollectionCell else { return UICollectionViewCell() }
        cell.viewModel = getCellViewModel(at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsAcross: CGFloat = 3
        let spaceBetweenCells: CGFloat = 10
        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim + 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        getCellViewModel(at: indexPath).didTapCell?()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CastleCollectionHeaderView.reuseID, for: indexPath) as? CastleCollectionHeaderView else {
                return UICollectionReusableView()
            }
            headerView.title = collectionSections[indexPath.section].title
            headerView.color = collectionSections[indexPath.section].backgroundColor
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 72)
    }
}

extension CastleListViewController {
    private func getCellViewModel(at indexPath: IndexPath) -> CastleListCellViewModel {
        return collectionSections[indexPath.section].items[indexPath.row]
    }
}
