//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Moxa on 22/03/26.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        UIApplication.shared.windows.first
    }
    
    @MainActor static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    @MainActor static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }

}
