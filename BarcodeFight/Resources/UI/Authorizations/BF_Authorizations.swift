//
//  BF_Authorizations.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 24/06/2022.
//

import Foundation
import UIKit
import AVFoundation
import CoreLocation
import Photos
import UserNotifications

public class BF_Authorizations : NSObject {
	
	public enum Style : String {
		
		case camera = "NSCameraUsageDescription"
		case locationWhenInUse	= "NSLocationWhenInUseUsageDescription"
		case photoLibrary = "NSPhotoLibraryUsageDescription"
		case notifications = ""
	}
	
	public static let shared:BF_Authorizations = .init()
	private lazy var locationManager:CLLocationManager = .init()
	private var locationCompletion:((Bool)->Void)?
	
	public func askIfNeeded(_ authorization:BF_Authorizations.Style, _ completion:((Bool)->Void)?) {
		
		if authorization == .camera {
			
			let status = AVCaptureDevice.authorizationStatus(for: .video)
			
			if status == .authorized {
				
				completion?(true)
			}
			else if status == .denied {
				
				promptDeniedAlert(authorization)
				completion?(false)
			}
			else{
				
				promptAuthorizationAlert(authorization, completion)
			}
		}
		else if authorization == .locationWhenInUse {
			
			let status = locationManager.authorizationStatus
			
			if status == .authorizedWhenInUse {
				
				completion?(true)
			}
			else if status == .denied {
				
				promptDeniedAlert(authorization)
				completion?(false)
			}
			else{
				
				promptAuthorizationAlert(authorization, completion)
			}
		}
		else if authorization == .photoLibrary {
			
			let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
			
			if status == .authorized {
				
				completion?(true)
			}
			else if status == .denied {
				
				promptDeniedAlert(authorization)
				completion?(false)
			}
			else{
				
				promptAuthorizationAlert(authorization, completion)
			}
		}
		else if authorization == .notifications {
			
			UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
				
				DispatchQueue.main.async { [weak self] in
					
					if settings.authorizationStatus == .authorized {
						
						completion?(true)
					}
					else if settings.authorizationStatus == .denied {
						
						self?.promptDeniedAlert(authorization)
						completion?(false)
					}
					else{
						
						self?.promptAuthorizationAlert(authorization, completion)
					}
				}
			}
		}
	}
	
	private func promptAuthorizationAlert(_ authorization:BF_Authorizations.Style, _ completion:((Bool)->Void)?) {
		
		let alertController:BF_Alert_ViewController = .init()
		alertController.title = String(key: "authorizations.ask.alert.title")
		alertController.add(UIImage(named: "placeholder_ask"))
		
		if authorization == .notifications {
			
			alertController.add(String(key: "authorizations.ask.alert.notifications"))
		}
		else {
			
			alertController.add(Bundle.main.object(forInfoDictionaryKey: authorization.rawValue) as? String)
		}
		
		alertController.addButton(title: String(key: "authorizations.ask.alert.button")) { [weak self] _ in

			alertController.close() { [weak self] in

				if authorization == .camera {

					AVCaptureDevice.requestAccess(for: .video) { [weak self] status in

						DispatchQueue.main.async { [weak self] in

							if !status {

								self?.promptDeniedAlert(authorization)
							}

							completion?(status)
						}
					}
				}
				else if authorization == .locationWhenInUse {
					
					self?.locationCompletion = completion
					self?.locationManager.delegate = self
					self?.locationManager.requestWhenInUseAuthorization()
				}
				else if authorization == .photoLibrary {
					
					PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
						
						DispatchQueue.main.async { [weak self] in
							
							if status != .authorized {
								
								self?.promptDeniedAlert(authorization)
							}
							
							completion?(status == .authorized)
						}
					}
				}
				else if authorization == .notifications {
					
					BF_Notifications.shared.requestAuthorization { [weak self] status in
						
						if !status {
							
							self?.promptDeniedAlert(authorization)
						}
						
						completion?(status)
					}
				}
			}
		}
		alertController.backgroundView.isUserInteractionEnabled = false
		alertController.present()
	}
	
	private func promptDeniedAlert(_ authorization:BF_Authorizations.Style) {
		
		let alertController:BF_Alert_ViewController = .init()
		alertController.title = String(key: "authorizations.denied.alert.title")
		alertController.add(UIImage(named: "placeholder_error"))
		
		if authorization == .notifications {
			
			alertController.add(String(key: "authorizations.ask.alert.notifications"))
		}
		else {
			
			alertController.add(Bundle.main.object(forInfoDictionaryKey: authorization.rawValue) as? String)
		}
		
		alertController.add(String(key: "authorizations.denied.alert.content"))
		
		if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
			
			alertController.addButton(title: String(key: "authorizations.denied.alert.button")) { _ in
				
				alertController.close() {
					
					UIApplication.shared.open(url)
				}
			}
		}
		alertController.addCancelButton()
		alertController.present()
	}
}

extension BF_Authorizations : CLLocationManagerDelegate {
	
	public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		
		DispatchQueue.main.async { [weak self] in
			
			if status == .authorizedWhenInUse {
				
				self?.locationCompletion?(true)
			}
			else if status == .denied {
				
				self?.promptDeniedAlert(.locationWhenInUse)
				self?.locationCompletion?(false)
			}
			
			self?.locationCompletion = nil
		}
	}
}
