//
//  CastleDetailLogPreviewCell.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import Foundation
import UIKit

class CastleDetailLogPreviewCell: TableViewCell {
    
    private let dateLabel = UILabel()
    private let titleLabel = UILabel()
    private let previewLabel = UILabel()
    private let photoView = UIView()
    
    var data: CastleDetailViewModel.CastleDetailVisitHistoryRowData? {
        didSet {
            guard let data else { return }
            dateLabel.text = data.date
            titleLabel.text = data.title
            previewLabel.text = data.preview
            configurePhoto(withURL: data.photoURL)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

// MARK: - View Config
extension CastleDetailLogPreviewCell {
    
    private func configureViews() {
        dateLabel.text = "Dec 20, 2023"
        dateLabel.font = .preferredFont(forTextStyle: .caption1)
        contentView.addSubview(dateLabel)
        titleLabel.text = "title"
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        contentView.addSubview(titleLabel)
        previewLabel.text = "this is some preview"
        previewLabel.textColor = .darkGray
        previewLabel.numberOfLines = 2
        previewLabel.font = .preferredFont(forTextStyle: .caption1)
        contentView.addSubview(previewLabel)
        
        photoView.backgroundColor = .white
        photoView.layer.borderColor = UIColor.gray.cgColor
        photoView.layer.borderWidth = 1
        photoView.layer.cornerRadius = 4
        photoView.clipsToBounds = true
        contentView.addSubview(photoView)
    }
    
    private func configureConstraints() {
        dateLabel.snp.remakeConstraints { make in
            make.leading.equalTo(contentView.layoutMarginsGuide).inset(8)
            make.top.equalTo(contentView.layoutMarginsGuide)
            make.trailing.equalTo(photoView.snp.leading)
            
        }
        titleLabel.snp.remakeConstraints { make in
            make.leading.trailing.equalTo(dateLabel)
            make.top.equalTo(dateLabel.snp.bottom).offset(4)
        }
        previewLabel.snp.remakeConstraints { make in
            make.leading.trailing.equalTo(dateLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalTo(contentView.layoutMarginsGuide).inset(8)
        }
        photoView.snp.remakeConstraints { make in
            make.trailing.equalTo(contentView.layoutMarginsGuide)
            make.top.equalTo(contentView.layoutMarginsGuide)
            make.size.equalTo(48)
        }
    }
    
    private func configurePhoto(withURL url: URL) {
        photoView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        // TODO: - read from photos
        let myImageView = UIImageView(image: UIImage(named: "photo-example"))
        myImageView.contentMode = .scaleAspectFill
        photoView.addSubview(myImageView)
        myImageView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

