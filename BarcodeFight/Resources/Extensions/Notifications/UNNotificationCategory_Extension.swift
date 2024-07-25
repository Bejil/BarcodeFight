//
//  UNNotificationCategory_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 07/06/2021.
//

import Foundation
import UserNotifications

extension UNNotificationCategory {
	
	public enum Category : String, CaseIterable {

		case Home = "home"
		case FreeScan = "scan"
		case FreeRuby = "ruby"
	}
	
	public static func category(_ category:Category) -> UNNotificationCategory {
		
		UNNotificationCategory(identifier: category.rawValue, actions: UNNotificationAction.all, intentIdentifiers: [], options: .customDismissAction)
	}
	
	public static var all:Set<UNNotificationCategory> = Set(Category.allCases.compactMap({ category($0) }))
}
