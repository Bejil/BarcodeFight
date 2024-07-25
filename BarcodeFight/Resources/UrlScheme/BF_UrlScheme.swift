//
//  BF_UrlScheme.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 03/04/2023.
//

import Foundation
import UserNotifications

public class BF_UrlScheme : Codable {
	
	static public func manage(category:String?, action:String? = nil, userInfo:[AnyHashable : Any]?) {
		
		if action != UNNotificationAction.Identifiers.Dismiss.rawValue {
			
			UI.MainController.dismiss(animated: true) {
				
				if category == UNNotificationCategory.Category.FreeScan.rawValue {
					
					BF_User.current?.scanAvailable = min(BF_Firebase.shared.config.int(.ScanMaxNumber), (BF_User.current?.scanAvailable ?? 0) + 1)
					BF_User.current?.update({ error in
						
						if let error {
							
							BF_Alert_ViewController.present(error)
						}
						else {
							
							NotificationCenter.post(.updateAccount)
						}
					})
				}
				else if category == UNNotificationCategory.Category.FreeRuby.rawValue {
					
					BF_User.current?.rubies = min(BF_Firebase.shared.config.int(.RubiesMaxNumber), (BF_User.current?.rubies ?? 0) + 1)
					BF_User.current?.update({ error in
						
						if let error {
							
							BF_Alert_ViewController.present(error)
						}
						else {
							
							NotificationCenter.post(.updateAccount)
						}
					})
				}
			}
		}
	}
}
