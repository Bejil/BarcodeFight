//
//  UserDefaults_Extension.swift
//  ListYa
//
//  Created by BLIN Michael on 21/06/2022.
//

import Foundation

extension UserDefaults {

	public enum Keys : String, CaseIterable {
		
		case welcomeNotification = "welcomeNotification"
		case notifications = "notifications"
		case onboarding = "onboarding"
		case battleTutorial = "battleTutorial"
		case battleLimitTutorial = "battleLimitTutorial"
		case homeTutorial = "homeTutorial"
	}
	
	public static func set(_ value:Any?, _ key:UserDefaults.Keys) {
		
		let standardUserDefaults = UserDefaults.standard
		standardUserDefaults.set(value, forKey: key.rawValue)
		standardUserDefaults.synchronize()
	}
	
	public static func get(_ key:UserDefaults.Keys) -> Any? {
		
		let standardUserDefaults = UserDefaults.standard
		return standardUserDefaults.value(forKey: key.rawValue)
	}
	
	public static func delete(_ key:UserDefaults.Keys) {
		
		let standardUserDefaults = UserDefaults.standard
		standardUserDefaults.removeObject(forKey: key.rawValue)
		standardUserDefaults.synchronize()
	}
	
	public static func reset() {
		
		Keys.allCases.forEach({ delete($0) })
	}
}
