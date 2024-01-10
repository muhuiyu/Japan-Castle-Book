//
//  TabCoordinator.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit
import Combine

protocol TabCoordinatorProtocol: Coordinator {
    var tabBarController: UITabBarController { get set }
}

class TabCoordinator: NSObject, TabCoordinatorProtocol {
    
    var type: CoordinatorType = .tab
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var tabBarController: UITabBarController
    
    var childCoordinators: [Coordinator] = []
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = .init()
    }
    
    func start() {
        configureTabBarController()
    }
}

extension TabCoordinator {
    private func configureTabBarController() {
        let pages: [TabBarPage] = TabBarPage.allCases
        tabBarController.viewControllers = pages.map { makeViewController(for: $0) }
        tabBarController.selectedIndex = TabBarPage.castleList.order
        navigationController.viewControllers = [ tabBarController ]
        configureTabBarStyle()
    }
    
    private func makeViewController(for tab: TabBarPage) -> UIViewController {
        switch tab {
        case .castleList:
            let navigationController = UINavigationController()
            let coordinator = CastleListCoordinator(navigationController, tabBarItem: tab.tabBarItem)
            coordinator.finishDelegate = self
            childCoordinators.append(coordinator)
            coordinator.start()
            return navigationController
        case .map:
            let viewController = UIViewController()
            viewController.view.backgroundColor = .green
            viewController.tabBarItem = tab.tabBarItem
            return viewController
        case .settings:
            let viewController = UIViewController()
            viewController.view.backgroundColor = .orange
            viewController.tabBarItem = tab.tabBarItem
            return viewController
        }
    }
    
    private func configureTabBarStyle() {
        UITabBar.appearance().backgroundColor = .systemBackground
    }
    
}

extension TabCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0.type != childCoordinator.type }
    }
}

enum TabBarPage: Int, CaseIterable {
    case castleList = 0
    case map
    case settings
    
    var order: Int {
        return self.rawValue
    }
    
    var title: String {
        switch self {
        case .castleList: return Text.tabCollection
        case .map: return Text.tabMap
        case .settings: return Text.tabSettings
        }
    }
    
    var image: UIImage? {
        let imageName = switch self {
        case .castleList: Icon.CollectionTab.inactive
        case .map: Icon.MapTab.inactive
        case .settings: Icon.SettingsTab.inactive
        }
        return UIImage(systemName: imageName)
    }
    
    var selectedImage: UIImage? {
        let imageName = switch self {
        case .castleList: Icon.CollectionTab.active
        case .map: Icon.MapTab.active
        case .settings: Icon.SettingsTab.active
        }
        return UIImage(systemName: imageName)
    }
    
    var tabBarItem: UITabBarItem {
        return UITabBarItem(title: self.title, image: self.image, selectedImage: self.selectedImage)
    }
}


