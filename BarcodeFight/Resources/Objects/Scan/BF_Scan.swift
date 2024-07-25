//
//  BF_Scan.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 16/08/2023.
//

import Foundation
import UIKit

public class BF_Scan : NSObject {
	
	public static let shared:BF_Scan = .init()
	private var nextScanTimer:Timer?
	public var progress:Float {
		
		guard let creationDate = BF_User.current?.creationDate else {
			
			return 0.0
		}
		
		let timeInterval = Date().timeIntervalSince(creationDate)
		let interval = TimeInterval(BF_Firebase.shared.config.int(.FreeScanTimeInterval))
		let nextOccurrenceTime = ceil(timeInterval / interval) * interval
		let previousTime = nextOccurrenceTime - interval
		
		let totalInterval = nextOccurrenceTime - previousTime
		if totalInterval == 0 {
			
			return 1.0
		}
		
		let elapsedTimeInCurrentInterval = timeInterval - previousTime
		return Float(elapsedTimeInCurrentInterval / totalInterval)
	}
	public var remainingTimeBeforeNextScan:TimeInterval? {
		
		if let creationDate = BF_User.current?.creationDate {
			
			let timeInterval = Date().timeIntervalSince(creationDate)
			let nextOccurrenceTime = ceil(timeInterval / TimeInterval(BF_Firebase.shared.config.int(.FreeScanTimeInterval))) * TimeInterval(BF_Firebase.shared.config.int(.FreeScanTimeInterval))
			let remainingTime = nextOccurrenceTime - timeInterval
			return remainingTime
		}
		
		return nil
	}
	public var nextScanString:String? {
		
		if let remainingTimeBeforeNextScan = remainingTimeBeforeNextScan, remainingTimeBeforeNextScan >= 1 {
			
			let formatter = DateComponentsFormatter()
			formatter.unitsStyle = .abbreviated
			formatter.zeroFormattingBehavior = .dropAll
			formatter.allowedUnits = [.hour, .minute, .second]
			
			if let formattedRemainingTime = formatter.string(from: remainingTimeBeforeNextScan) {
				
				return formattedRemainingTime
			}
		}
		
		return nil
	}
	
	deinit {
		
		resetNextScanTimer()
	}
	
	public func presentEmptyMonstersAlertController() {
		
		let alertController:BF_Alert_ViewController = .init()
		alertController.title = String(key: "fights.emptyMonsters.alert.title")
		alertController.add(UIImage(named: "placeholder_empty"))
		alertController.add(String(key: "fights.emptyMonsters.alert.label.0"))
		
		if !(BF_User.current?.monsters.isEmpty ?? true) {
			
			alertController.add(String(key: "fights.emptyMonsters.alert.label.1"))
			alertController.addButton(title: String(key: "fights.emptyMonsters.alert.button.0")) { _ in
				
				alertController.close {
					
					UI.MainController.present(BF_NavigationController(rootViewController: BF_Items_ViewController()), animated: true)
				}
			}
		}
		
		alertController.add(String(key: "fights.emptyMonsters.alert.label.2"))
		alertController.addButton(title: String(key: "fights.emptyMonsters.alert.button.1")) { _ in
			
			alertController.close {
				
				BF_Scan.scan()
			}
		}
		
		alertController.addDismissButton()
		alertController.present()
	}
	
	public func start(_ handler:((Int)->Void)?) {
		
		resetNextScanTimer()
		
		nextScanTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			
			if let remainingTimeBeforeNextScan = self?.remainingTimeBeforeNextScan {
				
				if remainingTimeBeforeNextScan < 1 {
					
					if BF_User.current?.scanAvailable ?? 0 < BF_Firebase.shared.config.int(.ScanMaxNumber) {
						
						BF_User.current?.scanAvailable += 1
						BF_User.current?.update { error in
							
							if error == nil {
								
								NotificationCenter.post(.updateAccount)
								BF_Toast.shared.present(title: String(key: "user.freeScan.toast.title"), subtitle: String(key: "user.freeScan.toast.subtitle"), style: .Success)
							}
							else {
								
								BF_User.current?.scanAvailable -= 1
							}
						}
					}
				}
			}
		}
		
		if let lastConnexionDate = BF_User.current?.lastConnexionDate {
			
			let timeInterval = Date().timeIntervalSince(lastConnexionDate)
			let occurrenceCount = Int(timeInterval / TimeInterval(BF_Firebase.shared.config.int(.FreeScanTimeInterval)))
			
			if occurrenceCount > 0 && (BF_User.current?.scanAvailable ?? 0) + occurrenceCount <= BF_Firebase.shared.config.int(.ScanMaxNumber) {
				
				BF_User.current?.scanAvailable += occurrenceCount
				BF_User.current?.update { error in
					
					if error == nil {
						
						NotificationCenter.post(.updateAccount)
						
						handler?(occurrenceCount)
					}
				}
			}
		}
	}
	
	private func resetNextScanTimer() {
		
		nextScanTimer?.invalidate()
		nextScanTimer = nil
	}
	
	public func nextScanTimes(count: Int) -> [Date]? {
		
		if let nextScanRemaining = remainingTimeBeforeNextScan {
			
			var results = [Date]()
			let currentTime = Date()
			let scanInterval = TimeInterval(BF_Firebase.shared.config.int(.FreeScanTimeInterval))
			
			for i in 0..<count {
				
				let nextScanDate = currentTime.addingTimeInterval(nextScanRemaining + TimeInterval(i) * scanInterval)
				results.append(nextScanDate)
			}
			
			return results
		}
		
		return nil
	}
}
