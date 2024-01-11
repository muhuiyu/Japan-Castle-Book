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
    }
}

extension CastleListViewController {
    
    private func configureViews() {
        title = Text.castleListViewControllerTitle
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
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
    
    private func reconfigureCells() {}
    
    private func reconfigureSpinnerView() {
        self.spinnerView.stopAnimating()
        self.spinnerView.isHidden = true
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
        return UICollectionViewCell()
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
}

extension CastleListViewController {
    private func getCellViewModel(at indexPath: IndexPath) -> CastleListCellViewModel {
        return collectionSections[indexPath.section].items[indexPath.row]
    }
}
