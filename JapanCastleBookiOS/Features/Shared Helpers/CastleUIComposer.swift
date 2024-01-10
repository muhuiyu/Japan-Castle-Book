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
}
