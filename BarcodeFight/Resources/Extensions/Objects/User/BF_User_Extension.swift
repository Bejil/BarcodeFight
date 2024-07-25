//
//  BF_User_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 14/08/2023.
//

import Foundation

extension BF_User {
	
	public struct Level {
		
		public var number:Int = 0
		public var range:Range<Int> = 0..<0
	}
	
	public var level:Level {
		
		var number = 1
		var lowerBound = 0
		var upperBound = 100 * number
		
		while experience >= upperBound {
			
			number += 1
			lowerBound = upperBound
			upperBound += (number * 100 * number)
		}
		
		return Level(number: number,range: lowerBound..<upperBound)
	}
	
	public func updateAndAddExperience(_ exp:Int, withToast:Bool, _ completion:((Error?)->Void)? = nil) {
		
		let previousLevel = level.number
		experience += exp
		
		let levelState = previousLevel != level.number
		let levelUp = levelState && previousLevel < level.number
		let levelDown = levelState && previousLevel > level.number
		
		if levelUp {
			
			scanAvailable += BF_Firebase.shared.config.int(.LevelRewardScanNumber)
			coins += BF_Firebase.shared.config.int(.LevelRewardCoinsNumber)
		}
		
		update { [weak self] error in
			
			if error == nil {
				
				NotificationCenter.post(.updateAccount)
				
				if withToast {
					
					if levelUp {
						
						BF_Toast.shared.present(title: String(key: "user.level.up.toast.title"), subtitle: [String(key: "user.level.up.toast.subtitle.0"),[String(key: "user.level.up.toast.subtitle.1"),"\(BF_Firebase.shared.config.int(.LevelRewardScanNumber))",String(key: "user.level.up.toast.subtitle.scans")].joined(separator: " "),[String(key: "user.level.up.toast.subtitle.1"),"\(BF_Firebase.shared.config.int(.LevelRewardCoinsNumber))",String(key: "user.level.up.toast.subtitle.coins")].joined(separator: " ")].joined(separator: "\n"), style: .Success)
					}
					else if levelDown {
						
						BF_Toast.shared.present(title: String(key: "user.level.down.toast.title"), subtitle: String(key: "user.level.down.toast.subtitle"), style: .Warning)
					}
					else if exp > 0 {
						
						BF_Toast.shared.present(title: String(key: "user.experience.up.toast.title"), subtitle: [String(key: "user.experience.up.toast.subtitle.0"),String(exp),String(key: "user.experience.up.toast.subtitle.1")].joined(separator: " "), style: .Success)
					}
					else if exp < 0 {
						
						BF_Toast.shared.present(title: String(key: "user.experience.down.toast.title"), subtitle: [String(key: "user.experience.down.toast.subtitle.0"),String(abs(exp)),String(key: "user.experience.down.toast.subtitle.1")].joined(separator: " "), style: .Success)
					}
				}
			}
			else {
				
				self?.experience -= exp
				
				if levelUp {
					
					self?.scanAvailable -= BF_Firebase.shared.config.int(.LevelRewardScanNumber)
					self?.coins -= BF_Firebase.shared.config.int(.LevelRewardCoinsNumber)
				}
			}
			
			completion?(error)
		}
	}
	
	public func setRewards(_ items:[BF_Item]?, _ completion:((Error?)->Void)?) {
		
		items?.forEach({
			
			if ![Items.Scan,Items.Rubies,Items.Coins.Five].contains($0.uid) {
				
				BF_User.current?.items.append($0)
			}
			else if $0.uid == Items.Coins.Five {
				
				BF_User.current?.coins += $0.price ?? 5
			}
			else if $0.uid == Items.Rubies {
				
				BF_User.current?.rubies += 1
			}
			else if $0.uid == Items.Scan {
				
				BF_User.current?.scanAvailable = min(BF_Firebase.shared.config.int(.ScanMaxNumber), (BF_User.current?.scanAvailable ?? 0) + 1)
			}
		})
		
		update(completion)
	}
	
	public var playerTeam:[BF_Monster]? {
		
		let mostRecentFight = fights.sorted(by: { $0.creationDate > $1.creationDate }).first
		let player = [mostRecentFight?.creator,mostRecentFight?.opponent].compactMap({ $0 }).first(where: { $0.userId == uid })
		
		var lastMonsters = monsters.filter({
			
			return !$0.isDead ? player?.monstersIds?.contains($0.uid) ?? false : false
			
		}).sort(.Battle)
		
		let remainingMonsters = monsters.filter({ monster in
			
			return !monster.isDead && !lastMonsters.contains(where: { $0.uid == monster.uid })
			
		}).sort(.Battle)
		
		let additionalMonsters = Array(remainingMonsters.prefix(BF_Firebase.shared.config.int(.FightMonstersCount)-lastMonsters.count))
		lastMonsters.append(contentsOf: additionalMonsters)
		
		return lastMonsters.sort(.Battle)
	}
	
	public var enemyTeam:[BF_Monster]? {
		
		return Array(monsters.filter({ !$0.isDead }).sort(.Battle).prefix(BF_Firebase.shared.config.int(.FightMonstersCount)))
	}
}
