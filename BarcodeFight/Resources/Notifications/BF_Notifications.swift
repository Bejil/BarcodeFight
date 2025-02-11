//
//  BF_Notifications.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 24/06/2022.
//

import Foundation
import UIKit
import UserNotifications
import FirebaseMessaging

public class BF_Notifications : NSObject {
	
	static let shared:BF_Notifications = .init()
	private var notificationCenter:UNUserNotificationCenter = .current()
	public var apnsToken:Data? {
		
		didSet {
			
			Messaging.messaging().apnsToken = apnsToken
		}
	}
	
	public override init() {
		
		super.init()
		
		notificationCenter.delegate = self
		notificationCenter.setNotificationCategories(UNNotificationCategory.all)
	}
	
	public func check(withCapping capping:Bool = false, andCompletion completion:((Error?)->Void)? = nil) {
		
		if capping {
			
			if let date = UserDefaults.get(.notifications) as? Date {
				
				let calendar = Calendar.current
				let date1 = calendar.startOfDay(for: date)
				let date2 = calendar.startOfDay(for: Date())
				
				let components = calendar.dateComponents([.day], from: date1, to: date2)
				
				if let day = components.day, day > 2  {
					
					check(withCapping:false, andCompletion:completion)
				}
			}
			else{
				
				check(withCapping:false, andCompletion:completion)
			}
			
			UserDefaults.set(Date(), .notifications)
		}
		else{
			
			BF_Authorizations.shared.askIfNeeded(.notifications) { _ in
				
				completion?(nil)
			}
		}
	}
	
	public func requestAuthorization(_ completion:((Bool)->Void)?) {
		
		notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
			
			DispatchQueue.main.async {
				
				let status = granted && error == nil
				
				UIApplication.shared.registerForRemoteNotifications()
				
				completion?(status)
			}
		}
	}
	
	public func manageNotification(_ category:String?, _ action:String?, and userInfo:[AnyHashable : Any]?) {
		
		if action != UNNotificationAction.Identifiers.Dismiss.rawValue {
			
			BF_UrlScheme.manage(category: category, userInfo: userInfo)
		}
	}
}

extension BF_Notifications : UNUserNotificationCenterDelegate {
	
	public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		
		let userInfo = notification.request.content.userInfo
		Messaging.messaging().appDidReceiveMessage(userInfo)
		
		completionHandler([.banner, .list, .sound, .badge])
	}
	
	public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		
		let userInfo = response.notification.request.content.userInfo
		Messaging.messaging().appDidReceiveMessage(userInfo)
		
		let categoryIdentifier = response.notification.request.content.categoryIdentifier
		let actionIdentifier = response.actionIdentifier
		
		manageNotification(categoryIdentifier, actionIdentifier, and: userInfo)
		
		completionHandler()
	}
}
