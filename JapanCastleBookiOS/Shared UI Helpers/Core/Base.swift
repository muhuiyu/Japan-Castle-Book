//
//  Base.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import Foundation
import UIKit
import Combine

class BaseViewController<T>: ViewController {
    
    var subscriptions = Set<AnyCancellable>()
    
    let viewModel: T
    
    init(viewModel: T) {
        self.viewModel = viewModel
        super.init()
    }
}

class BaseViewModel: Coordinating {
    var subscriptions = Set<AnyCancellable>()
    
    var coordinator: Coordinator?
    
    init(coordinator: Coordinator? = nil) {
        self.coordinator = coordinator
    }
}

protocol CellProtocol: NSObjectProtocol {
    static var reuseID: String { get }
}

class BaseTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BaseCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

typealias TableViewCell = BaseTableViewCell & CellProtocol
typealias CollectionViewCell = BaseCollectionViewCell & CellProtocol

extension CellProtocol where Self: UITableViewCell {
    static var reuseID: String { return NSStringFromClass(self) }
}

extension CellProtocol where Self: UICollectionViewCell {
    static var reuseID: String { return NSStringFromClass(self) }
}

