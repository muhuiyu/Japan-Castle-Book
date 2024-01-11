//
//  CastleDetailHeaderCell.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit

class CastleDetailHeaderCell: TableViewCell {
    private let layout = UICollectionViewFlowLayout()
    private lazy var photoCarouselView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private let stampView = UIImageView()
    private let numberLabel = UILabel()
    private let numberView = UIView()
    private let nameLabel = UILabel()
    private let readingLabel = UILabel()
    
    var data: CastleDetailViewModel.CastleDetailRowHeaderData? {
        didSet {
            guard let data else { return }
            numberLabel.text = String(data.number)
            nameLabel.text = data.name
            readingLabel.text = data.reading
            photoCarouselView.reloadData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureConstraints()
    }
}

// MARK: - View Config
extension CastleDetailHeaderCell {
    
    private func configureViews() {
        layout.scrollDirection = .horizontal
        photoCarouselView.showsHorizontalScrollIndicator = false
        photoCarouselView.dataSource = self
        photoCarouselView.register(CastleDetailHeaderCarouselCell.self, forCellWithReuseIdentifier: CastleDetailHeaderCarouselCell.reuseID)
        contentView.addSubview(photoCarouselView)
        
        configureCarouselItemSize()
        
        numberLabel.textAlignment = .center
        numberLabel.font = .systemFont(ofSize: 12, weight: .heavy)
        numberView.addSubview(numberLabel)
        numberView.layer.borderWidth = 2
        numberView.layer.cornerRadius = 14
        contentView.addSubview(numberView)
        
        nameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        contentView.addSubview(nameLabel)
        readingLabel.font = .preferredFont(forTextStyle: .caption1)
        contentView.addSubview(readingLabel)
        
        stampView.image = Images.castleDoneStamp
        stampView.layer.cornerRadius = 30
        stampView.backgroundColor = .white
        contentView.addSubview(stampView)
    }
    
    private func configureConstraints() {
        photoCarouselView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalTo(contentView.safeAreaLayoutGuide)
            make.height.equalTo(photoCarouselView.snp.width).multipliedBy(0.6)
        }
        stampView.snp.remakeConstraints { make in
            make.top.equalTo(photoCarouselView.snp.bottom).offset(-48)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(12)
            make.size.equalTo(60)
        }
        numberLabel.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
        numberView.snp.remakeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.leading.equalTo(contentView.layoutMarginsGuide)
            make.size.equalTo(28)
        }
        nameLabel.snp.remakeConstraints { make in
            make.top.equalTo(photoCarouselView.snp.bottom).offset(20)
            make.leading.equalTo(numberView.snp.trailing).offset(12)
            make.trailing.equalTo(contentView.layoutMarginsGuide)
        }
        readingLabel.snp.remakeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.leading.equalTo(nameLabel).offset(2)
            make.bottom.equalTo(contentView.layoutMarginsGuide).inset(12)
        }
    }
    
    private func configureCarouselItemSize() {
        let cellScale: CGFloat = 0.8
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = screenSize.width * cellScale
        let cellHeight = screenSize.width * cellScale * 0.7
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        photoCarouselView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    }
}

extension CastleDetailHeaderCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.imageURLs.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastleDetailHeaderCarouselCell.reuseID, for: indexPath) as? CastleDetailHeaderCarouselCell else { return UICollectionViewCell() }
        cell.imageURL = data?.imageURLs[indexPath.row]
        return cell
    }
}
