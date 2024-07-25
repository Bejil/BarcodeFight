//
//  AppDelegate.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 30/07/2023.
//

import UIKit
import IQKeyboardManagerSwift

@main

class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		BF_Firebase.shared.start()
		BF_Account.shared.start()
		
		start()
		
		IQKeyboardManager.shared.enable = true
		IQKeyboardManager.shared.toolbarTintColor = Colors.Button.Primary.Background
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.backgroundColor = Colors.Primary
		window?.rootViewController = BF_NavigationController(rootViewController: BF_Monsters_List_Home_ViewController())
		window?.makeKeyAndVisible()
		
		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		
		return BF_Firebase.shared.handle(url)
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		
		BF_Account.shared.stateDidChange()
		
		start()
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		
		end()
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		
		end()
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		
		end()
	}
	
	private func start() {
		
		BF_Notifications.shared.cancelAll()
		
		BF_User.current?.lastConnexionDate = Date()
		BF_User.current?.update(nil)
		
		BF_Fight_Live.deleteActives(nil)
	}
	
	private func end() {
		
		BF_Fight_Live.deleteActives(nil)
		
		BF_Notifications.shared.scheduleWelcome()
		BF_Notifications.shared.scheduleWalkingDead()
		
		if let nextTimes = BF_Scan.shared.nextScanTimes(count: 15) {
			
			nextTimes.forEach({ date in
				
				BF_Notifications.shared.scheduleFreeScan(date)
			})
		}
		
		if let nextTimes = BF_Ruby.shared.nextRubyTimes(count: 15) {
			
			nextTimes.forEach({ date in
				
				BF_Notifications.shared.scheduleFreeRuby(date)
			})
		}
	}
}

