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
		
		BF_Fight_Live.deleteActives(nil)
	}
	
	private func end() {
		
		BF_Fight_Live.deleteActives(nil)
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		
		BF_Notifications.shared.apnsToken = deviceToken
	}
}

