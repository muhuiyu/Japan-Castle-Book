//
//  CastleAlertComposer.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import UIKit

final class CastleAlertComposer {
    private init() {}
    
    static func castleDetailAddLogAlertComposedWith(
        navigateToTakePhoto: @escaping (() -> Void),
        navigateToAddStamp: @escaping (() -> Void),
        navigateToAddVisitLog: @escaping (() -> Void)
    ) -> UIAlertController {
        
        let alert = UIAlertController(
            title: Text.castleDetailViewControllerAddLogAlertChooseAction,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(
            UIAlertAction(
                title: Text.castleDetailViewControllerAddLogAlertTakePhoto,
                style: .default
            ) {  _ in navigateToTakePhoto() })
        alert.addAction(
            UIAlertAction(
                title: Text.castleDetailViewControllerAddLogAlertAddStamp,
                style: .default
            ) { _ in navigateToAddStamp() })
        alert.addAction(
            UIAlertAction(
                title: Text.castleDetailViewControllerAddLogAlertAddVisitLog,
                style: .default
            ) { _ in navigateToAddVisitLog() })
        alert.addAction(
            UIAlertAction(
                title: Text.castleDetailViewControllerAddLogAlertCancel,
                style: .cancel))
        return alert
    }
    
    static func castleDetailAddStampAlertComposedWith(
        navigateToAddDigitalStamp: @escaping (() -> Void),
        navigateToTakePhoto: @escaping (() -> Void)
    ) -> UIAlertController {
        
        let alert = UIAlertController(
            title: Text.castleDetailLogViewControllerAddStampAlertChooseAction,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(
            UIAlertAction(
                title: Text.castleDetailLogViewControllerAddStampAlertAddDigitalStamp,
                style: .default,
                handler: { _ in navigateToAddDigitalStamp() }))
        alert.addAction(
            UIAlertAction(
                title: Text.castleDetailViewControllerAddLogAlertTakePhoto,
                style: .default,
                handler: { _ in navigateToTakePhoto() }))
        alert.addAction(
            UIAlertAction(
                title: Text.castleDetailLogViewControllerAddStampAlertCancel,
                style: .cancel))
        return alert
    }
    
    static func castleDetailEditStampAlertComposedWith(
        didTapRemoveStamp: @escaping () -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(
                title: Text.castleDetailLogViewControllerEditStampAlertRemoveStamp,
                style: .destructive,
                handler: { _ in didTapRemoveStamp() }))
        alert.addAction(
            UIAlertAction(
                title: Text.castleDetailLogViewControllerEditStampAlertCancel,
                style: .cancel))
        return alert
    }
}

