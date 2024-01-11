//
//  CastleDetailInfoCell.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit

class CastleDetailInfoCell: TableViewCell {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    
    var imageName: String? {
        didSet {
            guard let imageName else { return }
            iconView.image = UIImage(systemName: imageName)
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var value: String? {
        didSet {
            valueLabel.text = value
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureConstraints()
    }
}

// MARK: - View Config
extension CastleDetailInfoCell {
    
    private func configureViews() {
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        valueLabel.numberOfLines = 0
        contentView.addSubview(valueLabel)
        
        iconView.contentMode = .scaleAspectFit
        contentView.addSubview(iconView)
    }
    
    private func configureConstraints() {
        iconView.snp.remakeConstraints { make in
            make.leading.equalTo(contentView.layoutMarginsGuide).inset(12)
            make.top.equalTo(contentView.layoutMarginsGuide)
            make.size.equalTo(20)
        }
        valueLabel.snp.remakeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(12)
            make.trailing.top.bottom.equalTo(contentView.layoutMarginsGuide)
        }
        
    }
}
