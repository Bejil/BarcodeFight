//
//  UNNotificationAction_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 07/06/2021.
//

import Foundation
import UserNotifications

extension UNNotificationAction {
	
	public enum Identifiers : String, CaseIterable {

		case Dismiss = "dismiss"
		case Confirm = "confirm"
	}
	
	public static var all:[UNNotificationAction] {
		
		return Identifiers.allCases.compactMap({ action($0) })
	}
	
	private static func action(_ identifier:Identifiers) -> UNNotificationAction {
		
		return UNNotificationAction(identifier: identifier.rawValue, title: String(key: "notifications.action.\(identifier.rawValue)"), options: UNNotificationActionOptions(rawValue: 0))
	}
}
