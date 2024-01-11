//
//  CastleDetailPageViewController.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit

class CastleDetailPageViewController: NSObject {
    
    let page = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    let subViewControllers: [UIViewController]
    
    init(subViewControllers: [UIViewController]) {
        self.subViewControllers = subViewControllers
        super.init()
        page.dataSource = self
    }
    
    func configure() {
        if let firstViewController = subViewControllers.first {
            page.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func didSelectIndex(_ index: Int) {
        switch index {
        case 0:
            page.setViewControllers([subViewControllers[0]], direction: .reverse, animated: true, completion: nil)
        case 1:
            page.setViewControllers([subViewControllers[1]], direction: .forward, animated: true, completion: nil)
        default:
            break
        }
    }
}

extension CastleDetailPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = subViewControllers.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        return subViewControllers[currentIndex - 1]
    }
       
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = subViewControllers.firstIndex(of: viewController), currentIndex < subViewControllers.count - 1 else {
            return nil
        }
        return subViewControllers[currentIndex + 1]
    }
}
