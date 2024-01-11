//
//  CastleDetailLogStampCell.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit

class CastleDetailLogStampCell: TableViewCell {
    static var reuseID: String { return NSStringFromClass(self) }
    
    private let containerView = UIView()
    private let placeholderImageView = UIImageView()
    private let addStampButton = UIButton()
    private let stampImageView = UIImageView()
    
    var hasVisited: Bool = false {
        didSet {
            reconfigureViews()
        }
    }
    
    var didTapAddStamp: (() -> Void)?
    var didTapStamp: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureConstraints()
        configureGestures()
    }
}

// MARK: - View Config
extension CastleDetailLogStampCell {
    
    private func reconfigureViews() {
        addStampButton.isHidden = hasVisited
        stampImageView.isHidden = !hasVisited
    }
    
    private func configureViews() {
        configureContainerView()
        configurePlaceholderImageView()
        configureAddStampButton()
        configureStampImageView()
    }
    
    private func configureConstraints() {
        containerView.snp.remakeConstraints { make in
            make.edges.equalTo(contentView.layoutMarginsGuide).inset(24)
            make.height.equalTo(containerView.snp.width)
        }
        placeholderImageView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(450)
        }
        addStampButton.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(containerView.snp.width).multipliedBy(0.6)
        }
        stampImageView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(250)
        }
    }
    
    private func configureGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapStampImageView(_:)))
        stampImageView.addGestureRecognizer(tapRecognizer)
    }

}
extension CastleDetailLogStampCell {
    
    private func configureContainerView() {
        containerView.backgroundColor = .white
        containerView.layer.borderColor = UIColor.red.cgColor
        containerView.layer.borderWidth = 1
        containerView.layer.cornerRadius = 4
        contentView.addSubview(containerView)
    }
    
    private func configurePlaceholderImageView() {
        placeholderImageView.image = Images.castlePlaceholder
        placeholderImageView.alpha = 0.1
        placeholderImageView.contentMode = .scaleAspectFit
        containerView.addSubview(placeholderImageView)
    }
    
    private func configureAddStampButton() {
        addStampButton.setTitle(Text.castleDetailLogViewControllerAddStampButton, for: .normal)
        addStampButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .heavy)
        addStampButton.backgroundColor = .systemMint
        addStampButton.layer.cornerRadius = 16
        addStampButton.addAction(UIAction(handler: { [weak self] _ in
            self?.didTapAddStamp?()
        }), for: .touchUpInside)
        containerView.addSubview(addStampButton)
    }
    
    private func configureStampImageView() {
        stampImageView.image = UIImage(named: "kumamoto")
        stampImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 80)
        stampImageView.contentMode = .scaleAspectFit
        stampImageView.isUserInteractionEnabled = true
        stampImageView.isHidden = true
        containerView.addSubview(stampImageView)
    }
    
    @objc
    private func didTapStampImageView(_ sender: UITapGestureRecognizer) {
        self.didTapStamp?()
    }
}

