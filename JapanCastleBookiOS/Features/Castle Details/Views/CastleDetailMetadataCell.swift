//
//  CastleDetailMetadataCell.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit

class CastleDetailMetadataCell: TableViewCell {
    private let stackView = UIStackView()

    var data: CastleDetailViewModel.CastleDetailRowMetadata? {
        didSet {
            configureData()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        stackView.axis = .vertical
        contentView.addSubview(stackView)
        stackView.snp.remakeConstraints { make in
            make.edges.equalTo(contentView.layoutMarginsGuide)
        }
    }
}

// MARK: - View Config
extension CastleDetailMetadataCell {
    private func configureData() {
        guard let data else { return }
        
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
        }
        
        let dataList: [(String, String)] = [
            (Icon.CastleDetailMetadataCell.phoneNumber, data.phoneNumber),
            (Icon.CastleDetailMetadataCell.time, data.openingHours),
            (Icon.CastleDetailMetadataCell.address, data.address),
            (Icon.CastleDetailMetadataCell.stampLocation, data.stampLocation)
        ]
        for data in dataList {
            let view = UIView()
            let iconView = UIImageView()
            let valueLabel = UILabel()
            
            iconView.tintColor = .darkGray
            iconView.contentMode = .scaleAspectFit
            iconView.image = UIImage(systemName: data.0)
            view.addSubview(iconView)
            valueLabel.text = data.1
            valueLabel.font = .preferredFont(forTextStyle: .caption1)
            valueLabel.numberOfLines = 0
            view.addSubview(valueLabel)
            
            iconView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().inset(8)
                make.top.equalTo(view.layoutMarginsGuide)
                make.size.equalTo(16)
            }
            valueLabel.snp.remakeConstraints { make in
                make.leading.equalTo(iconView.snp.trailing).offset(12)
                make.trailing.top.bottom.equalTo(view.layoutMarginsGuide)
            }
            stackView.addArrangedSubview(view)
        }
    }
}
