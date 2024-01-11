//
//  CastleDetailViewController.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit

class CastleDetailViewController: BaseViewController<CastleDetailViewModel> {
    
    private let segmentedControl = UISegmentedControl(items: [
        Text.castleDetailViewControllerSegmentedControlInfo,
        Text.castleDetailViewControllerSegmentedControlVisitLog,
    ])
    private let pageViewController: CastleDetailPageViewController
    private let completeButton = UIButton()
    
    init(viewModel: CastleDetailViewModel, pageViewController: CastleDetailPageViewController) {
        self.pageViewController = pageViewController
        super.init(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
    }
}

// MARK: - View Config
extension CastleDetailViewController {
    
    private func configureViews() {
        title = viewModel.title
        
        configureSegmentedControl()
        configurePageViewController()
        configureCompleteButton()
    }
    
    private func configureConstraints() {
        segmentedControl.snp.remakeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide)
            make.centerX.equalToSuperview()
        }
        pageViewController.page.view.snp.remakeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(12)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(completeButton.snp.top)
        }
        completeButton.snp.remakeConstraints { make in
            make.height.equalTo(48)
            make.bottom.leading.trailing.equalTo(view.layoutMarginsGuide)
        }
    }
    
    private func presentAddLogAlert() {
        let alert = CastleAlertComposer.castleDetailAddLogAlertComposedWith(
            navigateToTakePhoto: presentAddPhoto,
            navigateToAddStamp: presentAddStamp,
            navigateToAddVisitLog: presentAddVisitLog
        )
        present(alert, animated: true)
    }
    
    private func presentAddVisitLog() {
        
    }
    
    private func presentAddStamp() {
        
    }
    
    private func presentAddPhoto() {
        
    }
    
    private func configureSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        view.addSubview(segmentedControl)
    }
    
    @objc
    private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        pageViewController.didSelectIndex(sender.selectedSegmentIndex)
    }

    private func configurePageViewController() {
        pageViewController.configure()
        addChild(pageViewController.page)
        view.addSubview(pageViewController.page.view)
        pageViewController.page.didMove(toParent: self)
    }
    
    private func configureCompleteButton() {
        completeButton.setTitle(Text.castleDetailViewControllerCompleteButton, for: .normal)
        completeButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .heavy)
        completeButton.backgroundColor = .systemMint
        completeButton.layer.cornerRadius = 16
        completeButton.addAction(UIAction(handler: { [weak self] _ in
            self?.presentAddLogAlert()
        }), for: .touchUpInside)
        view.addSubview(completeButton)
    }
}
