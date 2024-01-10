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
        let viewModel = CastleListViewModel(coordinator: coordinator)
        let viewController = CastleListViewController(viewModel: viewModel)
        viewController.view.backgroundColor = .purple
        viewController.title = "Castle List"
        return viewController
    }
}
