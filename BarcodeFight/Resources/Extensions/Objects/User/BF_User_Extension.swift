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
	
	public func updateAndAddExperience(_ exp:Int, _ completion:((Error?)->Void)? = nil) {
		
		let previousLevel = level.number
		experience += exp
		
		let levelUp = previousLevel < level.number
		
		if levelUp {
			
			scanAvailable += BF_Firebase.shared.config.int(.LevelRewardScanNumber)
			coins += BF_Firebase.shared.config.int(.LevelRewardCoinsNumber)
		}
		
		update { [weak self] error in
			
			if error == nil {
				
				NotificationCenter.post(.updateAccount)
				
				if levelUp {
					
					BF_Item.get { items, error in
						
						if let error {
							
							BF_Alert_ViewController.present(error)
						}
						else if let chest = items?.first(where: { $0.uid == Items.ChestObjects }) {
							
							BF_User.current?.items.append(chest)
							BF_User.current?.update({ error in
								
								if let error {
									
									BF_Alert_ViewController.present(error)
								}
								else {
									
									let alertController:BF_Item_Chest_Objects_Alert_ViewController = .init()
									alertController.present {
										
										BF_Toast_Manager.shared.addToast(title: String(key: "user.level.up.toast.title"), subtitle: [String(key: "user.level.up.toast.subtitle.0"),[String(key: "user.level.up.toast.subtitle.1"),"\(BF_Firebase.shared.config.int(.LevelRewardScanNumber))",String(key: "user.level.up.toast.subtitle.scans")].joined(separator: " "),[String(key: "user.level.up.toast.subtitle.1"),"\(BF_Firebase.shared.config.int(.LevelRewardCoinsNumber))",String(key: "user.level.up.toast.subtitle.coins")].joined(separator: " ")].joined(separator: "\n"), style: .Success)
									}
								}
							})
						}
					}
				}
				else if exp != 0 {
					
					let state = exp > 0
					let stateString = state ? "up" : "down"
					
					BF_Toast_Manager.shared.addToast(title: String(key: "user.experience.\(stateString).toast.title"), subtitle: [String(key: "user.experience.\(stateString).toast.subtitle.0"),String(abs(exp)),String(key: "user.experience.\(stateString).toast.subtitle.1")].joined(separator: " "), style: state ? .Success : .Warning)
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
				
				BF_User.current?.scanAvailable += 1
			}
		})
		
		update(completion)
	}
	
	public var lastTeam:[BF_Monster] {
		
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
	
	public func bestTeam(against team: [BF_Monster]?) -> [BF_Monster]? {
		
		var playerMonsters = monsters
		var bestTeam:[BF_Monster] = .init()
		var opponentsCompared:[BF_Monster] = .init()
		
		team?.forEach({ opponent in
			
			if let index = playerMonsters.firstIndex(where: {
				
				!opponentsCompared.contains(opponent) &&
				$0.stats.rank >= opponent.stats.rank &&
				$0.element > opponent.element &&
				$0.status.hp >= opponent.status.hp/2 &&
				!$0.isDead
			}) {
				
				let monster = playerMonsters[index]
				
				opponentsCompared.append(opponent)
				bestTeam.append(monster)
				playerMonsters.remove(at: index)
			}
		})
		
		if bestTeam.count < BF_Firebase.shared.config.int(.FightMonstersCount) {
			
			team?.forEach({ opponent in
				
				if let index = playerMonsters.firstIndex(where: {
					
					!opponentsCompared.contains(opponent) &&
					$0.stats.rank >= opponent.stats.rank  &&
					$0.status.hp >= opponent.status.hp/2 &&
					!$0.isDead
					
				}) {
					
					let monster = playerMonsters[index]
					
					opponentsCompared.append(opponent)
					bestTeam.append(monster)
					playerMonsters.remove(at: index)
				}
			})
		}
		
		if bestTeam.count < BF_Firebase.shared.config.int(.FightMonstersCount) {
			
			team?.forEach({ opponent in
				
				if let index = playerMonsters.firstIndex(where: {
					
					!opponentsCompared.contains(opponent) &&
					$0.element > opponent.element &&
					$0.status.hp >= opponent.status.hp/2 &&
					!$0.isDead
					
				}) {
					
					let monster = playerMonsters[index]
					
					opponentsCompared.append(opponent)
					bestTeam.append(monster)
					playerMonsters.remove(at: index)
				}
			})
		}
		
		while bestTeam.count < BF_Firebase.shared.config.int(.FightMonstersCount), let monster = playerMonsters.max(by: { $0.stats.rank < $1.stats.rank }), !monster.isDead {
			
			bestTeam.append(monster)
			playerMonsters.removeAll { $0 == monster }
		}
		
		return bestTeam
	}
	
	public var enemyTeam:[BF_Monster]? {
		
		return Array(monsters.filter({ !$0.isDead }).sort(.Battle).prefix(BF_Firebase.shared.config.int(.FightMonstersCount)))
	}
}
