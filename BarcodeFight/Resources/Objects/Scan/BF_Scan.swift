//
//  BF_Scan.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 02/05/2024.
//

import Foundation
import UIKit

public class BF_Scan: NSObject {
	
	public static let shared: BF_Scan = .init()
	private var timer: Timer?
	public var timeInterval: TimeInterval? {
		
		let currentTime = Date()
		let nextDate = nextDate(from: currentTime)
		return max(0, nextDate.timeIntervalSince(currentTime))
	}
	public var string: String? {
		
		guard let remainingTime = timeInterval, remainingTime > 0 else { return nil }
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .abbreviated
		formatter.allowedUnits = [.hour, .minute, .second]
		return formatter.string(from: remainingTime)
	}
	public var previousString:String? {
		
		let calendar = Calendar.current
		let currentTime = Date()
		
		var lastNoonComponents = calendar.dateComponents([.year, .month, .day], from: currentTime)
		lastNoonComponents.hour = 16
		lastNoonComponents.minute = 0
		lastNoonComponents.second = 0
		
		let lastNoon: Date
		
		if let todayNoon = calendar.date(from: lastNoonComponents), todayNoon <= currentTime {
			
			lastNoon = todayNoon
		}
		else {
			
			lastNoon = calendar.date(byAdding: .day, value: -1, to: calendar.date(from: lastNoonComponents)!)!
		}
		
		let timeInterval = currentTime.timeIntervalSince(lastNoon)
		
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .abbreviated
		formatter.allowedUnits = [.hour, .minute, .second]
		return formatter.string(from: timeInterval)
	}
	public var newCount:Int {
		
		if let lastConnexionDate = BF_User.current?.lastConnexionDate {
			
			let calendar = Calendar.current
			let currentTime = Date()
			
			var lastResetComponents = calendar.dateComponents([.year, .month, .day], from: lastConnexionDate)
			lastResetComponents.hour = 16
			
			let lastResetDate = calendar.date(from: lastResetComponents) ?? lastConnexionDate
			let alignedLastConnexionDate = lastConnexionDate < lastResetDate ? lastResetDate.addingTimeInterval(-TimeInterval.day) : lastResetDate
			
			let interval = currentTime.timeIntervalSince(alignedLastConnexionDate)
			let count = max(0, Int(interval / TimeInterval.day))
			
			return count
		}
		
		return 0
	}
	
	deinit {
		
		resetTimer()
	}
	
	public func start() {
		
		resetTimer()
		
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			
			guard let self = self, let remainingTime = self.timeInterval, remainingTime < 1 else { return }
			
			BF_User.current?.scanAvailable += 1
			BF_User.current?.update { error in
				
				if error == nil {
					
					NotificationCenter.post(.updateAccount)
					
					BF_Toast_Manager.shared.addToast(title: String(key: "user.freeScan.toast.title"), subtitle: String(key: "user.freeScan.toast.subtitle"), style: .Success)
				}
				else {
					
					BF_User.current?.scanAvailable -= 1
				}
			}
		}
	}
	
	private func resetTimer() {
		
		timer?.invalidate()
		timer = nil
	}
	
	private func nextDate(from date: Date) -> Date {
		
		let calendar = Calendar.current
		guard let nextNoon = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: date) else { return date }
		return nextNoon <= date ? calendar.date(byAdding: .day, value: 1, to: nextNoon)! : nextNoon
	}
}
