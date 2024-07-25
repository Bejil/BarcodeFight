//
//  UIApplication_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 03/08/2023.
//

import Foundation
import UIKit

extension UIApplication {
	
	public static var isDebug:Bool {
		
		var state = false
		
#if DEBUG
		state = true
#endif
		
		return state
	}
	
	public func topMostViewController() -> UIViewController? {
		
		return UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }?.rootViewController?.topMostViewController()
	}
	
	public static var statusBarHeight:CGFloat {
		
		let window = UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }
		return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0
	}
	
	public static func hideKeyboard(){
		
		UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
	}
	
	public enum FeedbackType : String {
		
		case Error = "Error"
		case Success = "Success"
		case On = "On"
		case Off = "Off"
	}
	
	public static func feedBack(_ type:FeedbackType) {
		
		if type == .On || type == .Off {
			
			UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		}
		else {
			
			UINotificationFeedbackGenerator().notificationOccurred(type == .Success ? .success : .error)
		}
	}
	
	public static func wait(_ delay:Double = 0.3, _ completion:(()->Void)?) {
		
		DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
			
			completion?()
		}
	}
}
