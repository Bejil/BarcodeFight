//
//  BF_Notifications.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 24/06/2022.
//

import Foundation
import UIKit
import UserNotifications

public class BF_Notifications : NSObject {
	
	public enum Identifiers:String {
		
		case FreeScan = "notificationsFreeScan"
		case FreeRuby = "notificationsFreeRuby"
		case WalkingDead = "notificationsWalkingDead"
		case Welcome = "notificationsWelcome"
	}
	
	static let shared:BF_Notifications = .init()
	private var notificationCenter:UNUserNotificationCenter = .current()
	
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
				
				completion?(status)
			}
		}
	}
	
	public func manageNotification(_ category:String?, _ action:String?, and userInfo:[AnyHashable : Any]?) {
		
		if action != UNNotificationAction.Identifiers.Dismiss.rawValue {
			
			BF_UrlScheme.manage(category: category, userInfo: userInfo)
		}
	}
	
	public func schedule(_ request:UNNotificationRequest) {
		
		cancel(request.identifier)
		notificationCenter.add(request) { error in
			
			if let error = error {
				
				BF_Alert_ViewController.present(error)
			}
		}
	}
	
	public func cancelAll() {
		
		notificationCenter.removeAllPendingNotificationRequests()
	}
	
	public func cancel(_ identifier:String?) {
		
		if let identifier = identifier {
			
			notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
		}
	}
	
	public func scheduleWalkingDead() {
		
		let content:UNMutableNotificationContent = .init()
		content.title = String(key: "notifications.walkingDead.title")
		content.body = String(key: "notifications.walkingDead.content")
		content.sound = UNNotificationSound.default
		content.categoryIdentifier = UNNotificationCategory.Category.Home.rawValue
		
		let trigger:UNTimeIntervalNotificationTrigger = .init(timeInterval: Date().timeIntervalSinceNow + (2*24*60*60), repeats: false)
		
		let request:UNNotificationRequest = .init(identifier: BF_Notifications.Identifiers.WalkingDead.rawValue, content: content, trigger: trigger)
		schedule(request)
	}
	
	public func scheduleWelcome() {
		
		if !(UserDefaults.get(.welcomeNotification) as? Bool ?? false) {
			
			let content:UNMutableNotificationContent = .init()
			content.title = String(key: "notifications.welcome.title")
			content.body = String(key: "notifications.welcome.content")
			content.sound = UNNotificationSound.default
			content.categoryIdentifier = UNNotificationCategory.Category.Home.rawValue
			
			let trigger:UNTimeIntervalNotificationTrigger = .init(timeInterval: Date().timeIntervalSinceNow + (15*60), repeats: false)
			
			let request:UNNotificationRequest = .init(identifier: BF_Notifications.Identifiers.Welcome.rawValue, content: content, trigger: trigger)
			schedule(request)
			
			UserDefaults.set(true, .welcomeNotification)
		}
	}
	
	public func scheduleFreeScan(_ date:Date) {
		
		let content:UNMutableNotificationContent = .init()
		content.title = String(key: "notifications.freeScan.title")
		content.body = String(key: "notifications.freeScan.content")
		content.sound = UNNotificationSound.default
		content.categoryIdentifier = UNNotificationCategory.Category.FreeScan.rawValue
		
		let trigger:UNTimeIntervalNotificationTrigger = .init(timeInterval: date.timeIntervalSinceNow, repeats: false)
		
		let request:UNNotificationRequest = .init(identifier: BF_Notifications.Identifiers.FreeScan.rawValue, content: content, trigger: trigger)
		schedule(request)
	}
	
	public func scheduleFreeRuby(_ date:Date) {
		
		let content:UNMutableNotificationContent = .init()
		content.title = String(key: "notifications.freeRuby.title")
		content.body = String(key: "notifications.freeRuby.content")
		content.sound = UNNotificationSound.default
		content.categoryIdentifier = UNNotificationCategory.Category.FreeRuby.rawValue
		
		let trigger:UNTimeIntervalNotificationTrigger = .init(timeInterval: date.timeIntervalSinceNow, repeats: false)
		
		let request:UNNotificationRequest = .init(identifier: BF_Notifications.Identifiers.FreeRuby.rawValue, content: content, trigger: trigger)
		schedule(request)
	}
}

extension BF_Notifications : UNUserNotificationCenterDelegate {
	
	public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		
		completionHandler([.banner, .list, .sound, .badge])
	}
	
	public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		
		let categoryIdentifier = response.notification.request.content.categoryIdentifier
		let actionIdentifier = response.actionIdentifier
		let userInfo = response.notification.request.content.userInfo
		
		manageNotification(categoryIdentifier, actionIdentifier, and: userInfo)
		
		completionHandler()
	}
}
