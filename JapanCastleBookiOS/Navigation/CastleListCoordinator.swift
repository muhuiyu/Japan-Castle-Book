//
//  CastleListCoordinator.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit
import JapanCastleBook

protocol CastleListCoordinatorProtocol: Coordinator {
    func showCastleListViewController()
    func showCastleDetailViewController(for castle: Castle)
}

class CastleListCoordinator: CastleListCoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .collection
    
    private let tabBarItem: UITabBarItem
    
    required init(
        _ navigationController: UINavigationController,
        tabBarItem: UITabBarItem
    ) {
        self.navigationController = navigationController
        self.tabBarItem = tabBarItem
    }
    
    func start() {
        showCastleListViewController()
    }
    
    func showCastleListViewController() {
        let viewController = CastleUIComposer.castleListComposedWith(
            coordinator: self,
            didTapCastle: showCastleDetailViewController(for:)
        )
        viewController.tabBarItem = tabBarItem
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showCastleDetailViewController(for castle: Castle) {
        let viewController = CastleUIComposer.castleDetailComposedWith(coordinator: self, castle: castle)
        navigationController.pushViewController(viewController, animated: true)
    }
}

