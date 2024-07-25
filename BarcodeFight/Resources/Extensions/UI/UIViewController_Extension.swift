//
//  UIViewController_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 03/08/2023.
//

import Foundation
import UIKit

extension UIViewController {
	
	func topMostViewController() -> UIViewController {
		
		if let presented = self.presentedViewController {
			
			return presented.topMostViewController()
		}
		
		if let navigation = self as? UINavigationController {
			
			return navigation.visibleViewController?.topMostViewController() ?? navigation
		}
		
		if let tab = self as? UITabBarController {
			
			return tab.selectedViewController?.topMostViewController() ?? tab
		}
		
		return self
	}
}
