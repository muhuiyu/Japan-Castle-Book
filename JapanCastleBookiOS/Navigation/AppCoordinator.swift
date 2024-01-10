//
//  AppCoordinator.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit
import Combine

protocol AppCoordinatorProtocol: Coordinator {
    func showMainFlow()
}

class AppCoordinator: AppCoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate? = nil
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .app
    
    private var tabBarController: UITabBarController?
    private var tabCoordinator: TabCoordinator
    
    required init(_ navigationController: UINavigationController, tabCoordinator: TabCoordinator) {
        self.navigationController = navigationController
        self.tabCoordinator = tabCoordinator
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    func start() {
        showMainFlow()
    }
    
    func showMainFlow() {
        let tabCoordinator = tabCoordinator
        tabCoordinator.finishDelegate = self
        tabCoordinator.start()
        childCoordinators.append(tabCoordinator)
    }
}

extension AppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0.type != childCoordinator.type })
    }
}

