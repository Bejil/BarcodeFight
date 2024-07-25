//
//  BF_Firebase.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 07/08/2023.
//

import Foundation
import Firebase
import FirebaseCore
import GoogleSignIn
import FirebaseRemoteConfig

public class BF_Firebase {
	
	public static let shared:BF_Firebase = .init()
	public var config:RemoteConfig!
	
	public func start() {
		
		FirebaseApp.configure()
		
		config = .remoteConfig()
		config.setDefaults(fromPlist: "remote_config_defaults")
		config.fetch { [weak self] status, _ -> Void in
			
			if status == .success {
				
				self?.config.activate()
			}
		}
	}
	
	public func handle(_ url:URL) -> Bool {
		
		return GIDSignIn.sharedInstance.handle(url)
	}
}
