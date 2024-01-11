//
//  CastleUIComposer.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit
import JapanCastleBook

final class CastleUIComposer {
    private init() {}
    
    static func castleListComposedWith(coordinator: Coordinator,
                                       didTapCastle: @escaping ((Castle) -> Void)) -> CastleListViewController {
        let castleService = LocalCastleService()
        let visitHistoryService = CoreDataCastleVisitHistoryService()
        let viewModel = CastleListViewModel(coordinator: coordinator,
                                            castleService: castleService,
                                            visitHistoryService: visitHistoryService,
                                            didTapCastle: didTapCastle)
        let viewController = CastleListViewController(viewModel: viewModel)
        return viewController
    }
    
    static func adaptCastlesToCastlesCollectionViewSectionData(
        _ castles: [Castle],
        visitHistoryService: CastleVisitHistoryService,
        didTapCastle: @escaping ((Castle) -> Void)
    ) -> [CastleListViewController.SectionData] {
        return castles
            .reduce(into: [CastleArea: [Castle]](), { $0[$1.area, default: []].append($1) })
            .sorted(by: { $0.key.rawValue < $1.key.rawValue })
            .map { (area, castles) in
                
                let viewModels = castles.map { castle in
                    let viewModel = CastleListCellViewModel(castle: castle, visitHistoryService: visitHistoryService)
                    viewModel.didTapCell = { [castle] in didTapCastle(castle) }
                    return viewModel
                }
                return CastleListViewController.SectionData(
                    items: viewModels,
                    title: area.title,
                    backgroundColor: area.backgroundColor)
            }
    }
    
    static func castleDetailComposedWith(coordinator: Coordinator, castle: Castle) -> CastleDetailViewController {
        let viewModel = CastleDetailViewModel(coordinator: coordinator, castle: castle)
        
        let tableViewController = CastleDetailTableViewController(viewModel: viewModel)
        
        let logViewController = ViewController()
        logViewController.view.backgroundColor = .systemPink
        
        let subViewControllers = [ tableViewController, logViewController ]
        
        let pageViewController = CastleDetailPageViewController(subViewControllers: subViewControllers)
        let viewController = CastleDetailViewController(viewModel: viewModel, pageViewController: pageViewController)
        return viewController
    }
}

extension CastleArea {
    var backgroundColor: UIColor {
        switch self {
        case .hokkaidoTohoku: return .systemCyan
        case .kantoKoshinetsu: return .systemYellow
        case .hokurikuTokai: return .systemPink
        case .kinki: return .systemTeal
        case .chugokuShikoku: return .systemBrown
        case .kyusyuOkinawa: return .systemBrown
        }
    }
}
