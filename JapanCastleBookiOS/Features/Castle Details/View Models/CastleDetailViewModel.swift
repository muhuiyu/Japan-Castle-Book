//
//  CastleDetailViewModel.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import JapanCastleBook

class CastleDetailViewModel: BaseViewModel {
    
    struct CastleDetailRowHeaderData {
        let name: String
        let reading: String
        let number: Int
        let imageURLs: [URL]
    }
    
    struct CastleDetailRowMetadata {
        let phoneNumber: String
        let openingHours: String
        let address: String
        let stampLocation: String
    }
    
    enum CastleDetailRowData {
        case header(data: CastleDetailRowHeaderData)
        case metadata(data: CastleDetailRowMetadata)
        case info(key: String, value: String)
        case infoIconValue(icon: String, value: String)
    }
    
    struct Constants {
        static var stampCellIndexPath: IndexPath { IndexPath(row: 0, section: 0) }
    }
    
    let title: String
    
    private(set) var infoData: [CastleDetailRowData] = []
    
    init(coordinator: Coordinator, castle: Castle) {
        self.title = castle.name
        super.init(coordinator: coordinator)
        configureData(for: castle)
    }
    
    private func configureData(for castle: Castle) {
        infoData.append(.header(data: castleDetailRowHeaderData(for: castle)))
        infoData.append(.metadata(data: castleDetailMetadata(for: castle)))
        infoData.append(.info(key: Text.castleDetailViewControllerAccessGuideLLabel, value: castle.accessGuide))
        infoData.append(.info(key: Text.castleDetailViewControllerURLLabel, value: "not yet"))
    }
    
}

extension CastleDetailViewModel {
    private func castleDetailRowHeaderData(for castle: Castle) -> CastleDetailRowHeaderData {
        let defaultImageURLs = [
            URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2013/11/kumamotojo-e1383488845835.jpg")!
        ]
        
        return CastleDetailRowHeaderData(name: castle.name,
                                         reading: castle.reading,
                                         number: castle.id,
                                         imageURLs: castle.imageURLs.isEmpty ? defaultImageURLs : castle.imageURLs)
    }
    
    private func castleDetailMetadata(for castle: Castle) -> CastleDetailRowMetadata {
        return CastleDetailRowMetadata(phoneNumber: castle.phoneNumber,
                                       openingHours: castle.openingHours,
                                       address: castle.address,
                                       stampLocation: "[\(Text.castleDetailTableViewControllerStampLocationLabel)]\n\(castle.stampLocation)")
    }
}
