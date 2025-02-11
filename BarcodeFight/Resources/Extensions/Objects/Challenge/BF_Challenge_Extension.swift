//
//  BF_Challenge_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 30/08/2024.
//

import Foundation
import Firebase

extension BF_Challenge {
	
	static func increase(_ id:String) {
		
		BF_User.current?.increaseChallenge(id)
		
		NotificationCenter.post(.updateChallenges)
		
		BF_Challenge.get { challenges, error in
		
			if let userChallenge = BF_User.current?.challenges.items.first(where: { $0.uid == id }),
			   let distantChallenge = challenges?.first(where: { $0.uid == id }),
			   let challengeName = distantChallenge.name{
				
				if userChallenge.dates?.count == Challenges.Max {
					
					BF_Toast_Manager.shared.addToast(title: challengeName, subtitle: String(key: "challenges.toast.content"), style: .Success)
				}
				else if let sortedDates = userChallenge.dates?.sorted(),
						let lastDate = sortedDates.last,
							lastDate < Date(),
							Calendar.current.isDateInYesterday(lastDate) {
					
					var consecutiveCount = 1
					var previousDate = lastDate
					
					for date in sortedDates.filter({ $0 != lastDate }).reversed() {
						
						if let expectedDate = Calendar.current.date(byAdding: .day, value: -1, to: previousDate),
						   Calendar.current.isDate(date, inSameDayAs: expectedDate) {
							
							consecutiveCount += 1
							previousDate = date
						}
						else {
							
							break
						}
					}
					
					let starsStackView:BF_Challenges_Stars_StackView = .init()
					starsStackView.currentIndex = min(consecutiveCount, Challenges.Max)
					
					BF_Toast_Manager.shared.addToast(title: challengeName, subtitle: String(key: "challenges.toast.progress.content"), style: .Success, customView: starsStackView)
				}
			}
		}
	}
}

extension [BF_Challenge] {
	
	public var pending: [BF_Challenge] {
		
		return filter { challenge in
			
			if let userChallenge = BF_User.current?.challenges.items.first(where: { $0.uid == challenge.uid }) {
				
				let isCompleted = (userChallenge.dates?.count ?? 0) >= Challenges.Max
				let isDoneToday = userChallenge.dates?.contains(where: {
					Calendar.current.isDate($0, inSameDayAs: Date())
				}) ?? false
				
				return !isCompleted && !isDoneToday
			}
			
			return true
		}
	}
	
	public var done: [BF_Challenge] {
		
		return filter { challenge in
			
			if let userChallenge = BF_User.current?.challenges.items.first(where: { $0.uid == challenge.uid }) {
				
				let isCompleted = (userChallenge.dates?.count ?? 0) >= Challenges.Max
				let isDoneToday = userChallenge.dates?.contains(where: {
					Calendar.current.isDate($0, inSameDayAs: Date())
				}) ?? false
				
				return isCompleted || isDoneToday
			}
			
			return false
		}
	}
}
