//
//  CastleCollectionHeaderView.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit

class CastleCollectionHeaderView: UICollectionReusableView {
    static let reuseID = NSStringFromClass(CastleCollectionHeaderView.self)
    
    private let titleLabel = UILabel()
    private let containerView = UIView()
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var color: UIColor? {
        didSet {
            containerView.backgroundColor = color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Config
extension CastleCollectionHeaderView {
    private func configureViews() {
        backgroundColor = .clear
        
        titleLabel.font = .preferredFont(forTextStyle: .body)
        containerView.addSubview(titleLabel)
        addSubview(containerView)
    }
    
    private func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        containerView.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(12)
        }
    }
}

