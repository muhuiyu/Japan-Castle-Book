//
//  CastleDetailHeaderCarouselCell.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit
import Kingfisher

class CastleDetailHeaderCarouselCell: CollectionViewCell {
    
    private let photoView = UIImageView()
    
    var imageURL: URL? {
        didSet {
            photoView.kf.setImage(with: imageURL)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        configureConstraints()
    }
}

// MARK: - View Config
extension CastleDetailHeaderCarouselCell {
    
    private func configureViews() {
        photoView.contentMode = .scaleAspectFill
        photoView.layer.cornerRadius = 8
        photoView.layer.masksToBounds = true
        contentView.addSubview(photoView)
    }
    
    private func configureConstraints() {
        photoView.snp.remakeConstraints { make in
            make.edges.equalTo(contentView.layoutMarginsGuide)
        }
    }

}
