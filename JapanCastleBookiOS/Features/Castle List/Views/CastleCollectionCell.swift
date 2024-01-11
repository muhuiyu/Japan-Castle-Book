//
//  CastleCollectionCell.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit
import JapanCastleBook

class CastleCollectionCell: CollectionViewCell {
    private let titleLabel = UILabel()
    private let containerView = UIView()
    private let placeholderImageView = UIImageView()
    private let doneImageView = UIImageView()
    
    var viewModel: CastleListCellViewModel? {
        didSet {
            configureTitleAndImageViews()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        configureConstraints()
    }
}

// MARK: - View Config
extension CastleCollectionCell {
    
    private func configureViews() {
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        placeholderImageView.image = Images.castlePlaceholder
        placeholderImageView.contentMode = .scaleAspectFit
        placeholderImageView.alpha = 0.2
        containerView.addSubview(placeholderImageView)
        
        containerView.layer.borderColor = UIColor.gray.cgColor
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        contentView.addSubview(containerView)
        
        doneImageView.image = Images.castleDoneStamp
        doneImageView.contentMode = .scaleAspectFit
        doneImageView.isHidden = true
        contentView.addSubview(doneImageView)
    }
    
    private func configureConstraints() {
        titleLabel.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(14)
            make.top.leading.trailing.equalTo(contentView.layoutMarginsGuide)
        }
        containerView.snp.remakeConstraints { make in
            make.top.equalTo(contentView.layoutMarginsGuide).inset(24)
            make.leading.trailing.equalTo(contentView.layoutMarginsGuide)
            make.height.equalTo(containerView.snp.width)
            make.bottom.lessThanOrEqualTo(contentView.layoutMarginsGuide)
        }
        placeholderImageView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }
        doneImageView.snp.remakeConstraints { make in
            make.size.equalTo(42)
            make.bottom.trailing.equalTo(contentView.layoutMarginsGuide).inset(12)
        }
    }
    
    private func adjustFontSize(for name: String) {
        if name.count >= 10 {
            titleLabel.font = .systemFont(ofSize: 10)
        } else {
            titleLabel.font = .systemFont(ofSize: 14)
        }
    }
    
    private func configureTitleAndImageViews() {
        guard let title = viewModel?.title, let hasVisited = viewModel?.hasVisited() else { return }
        
        titleLabel.text = title
        adjustFontSize(for: title)
        
        doneImageView.isHidden = !hasVisited
        placeholderImageView.alpha = hasVisited ? 1 : 0.2
    }
}

extension CastleCollectionCell {
    var title: String? { titleLabel.text }
}

