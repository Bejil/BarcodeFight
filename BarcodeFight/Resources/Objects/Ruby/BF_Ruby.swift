//
//  BF_Ruby.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 02/05/2024.
//

import Foundation
import UIKit

public class BF_Ruby : NSObject {
	
	public static let shared:BF_Ruby = .init()
	private var nextRubyTimer:Timer?
	public var progress:Float {
		
		guard let creationDate = BF_User.current?.creationDate else {
			
			return 0.0
		}
		
		let timeInterval = Date().timeIntervalSince(creationDate)
		let interval = TimeInterval(BF_Firebase.shared.config.int(.FreeRubyTimeInterval))
		let nextOccurrenceTime = ceil(timeInterval / interval) * interval
		let previousTime = nextOccurrenceTime - interval
		
		let totalInterval = nextOccurrenceTime - previousTime
		if totalInterval == 0 {
			
			return 1.0
		}
		
		let elapsedTimeInCurrentInterval = timeInterval - previousTime
		return Float(elapsedTimeInCurrentInterval / totalInterval)
	}
	public var remainingTimeBeforeNextRuby:TimeInterval? {
		
		if let creationDate = BF_User.current?.creationDate {
			
			let timeInterval = Date().timeIntervalSince(creationDate)
			let nextOccurrenceTime = ceil(timeInterval / TimeInterval(BF_Firebase.shared.config.int(.FreeRubyTimeInterval))) * TimeInterval(BF_Firebase.shared.config.int(.FreeRubyTimeInterval))
			let remainingTime = nextOccurrenceTime - timeInterval
			return remainingTime
		}
		
		return nil
	}
	public var nextRubyString:String? {
		
		if let remainingTimeBeforeNextRuby = remainingTimeBeforeNextRuby, remainingTimeBeforeNextRuby >= 1 {
			
			let formatter = DateComponentsFormatter()
			formatter.unitsStyle = .abbreviated
			formatter.zeroFormattingBehavior = .dropAll
			formatter.allowedUnits = [.hour, .minute, .second]
			
			if let formattedRemainingTime = formatter.string(from: remainingTimeBeforeNextRuby) {
				
				return formattedRemainingTime
			}
		}
		
		return nil
	}
	
	deinit {
		
		resetNextRubyTimer()
	}
	
	public func start(_ handler:((Int)->Void)?) {
		
		resetNextRubyTimer()
		
		nextRubyTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			
			if let remainingTimeBeforeNextRuby = self?.remainingTimeBeforeNextRuby {
				
				if remainingTimeBeforeNextRuby < 1 {
					
					if BF_User.current?.rubies ?? 0 < BF_Firebase.shared.config.int(.RubiesMaxNumber) {
						
						BF_User.current?.rubies += 1
						BF_User.current?.update { error in
							
							if error == nil {
								
								NotificationCenter.post(.updateAccount)
								BF_Toast.shared.present(title: String(key: "user.freeRuby.toast.title"), subtitle: String(key: "user.freeRuby.toast.subtitle"), style: .Success)
							}
							else {
								
								BF_User.current?.rubies -= 1
							}
						}
					}
				}
			}
		}
		
		if let lastConnexionDate = BF_User.current?.lastConnexionDate {
			
			let timeInterval = Date().timeIntervalSince(lastConnexionDate)
			let occurrenceCount = Int(timeInterval / TimeInterval(BF_Firebase.shared.config.int(.FreeRubyTimeInterval)))
			
			if occurrenceCount > 0 && (BF_User.current?.rubies ?? 0) + occurrenceCount <= BF_Firebase.shared.config.int(.RubiesMaxNumber) {
				
				BF_User.current?.rubies += occurrenceCount
				BF_User.current?.update { error in
					
					if error == nil {
						
						NotificationCenter.post(.updateAccount)
						
						handler?(occurrenceCount)
					}
				}
			}
		}
	}
	
	private func resetNextRubyTimer() {
		
		nextRubyTimer?.invalidate()
		nextRubyTimer = nil
	}
	
	public func nextRubyTimes(count: Int) -> [Date]? {
		
		if let nextRubyRemaining = remainingTimeBeforeNextRuby {
			
			var results = [Date]()
			let currentTime = Date()
			let rubyInterval = TimeInterval(BF_Firebase.shared.config.int(.FreeRubyTimeInterval))
			
			for i in 0..<count {
				
				let nextRubyDate = currentTime.addingTimeInterval(nextRubyRemaining + TimeInterval(i) * rubyInterval)
				results.append(nextRubyDate)
			}
			
			return results
		}
		
		return nil
	}
}
