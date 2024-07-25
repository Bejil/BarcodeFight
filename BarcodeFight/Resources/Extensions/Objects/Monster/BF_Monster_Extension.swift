	//
	//  BF_Monster.swift
	//  BarcodeFight
	//
	//  Created by BLIN Michael on 06/08/2023.
	//

import Foundation
import UIKit

extension BF_Monster {
	
	public var isDead:Bool {
		
		return status.hp <= 0
	}
	
	convenience init(rank:Stats.Rank, percent:Int) {
		
		self.init()
		
		let ranksCount:Float = Float(BF_Monster.Stats.Rank.allCases.count)
		let statsSlice:Float = Float(BF_Monster.Stats.range.upperBound) / ranksCount
		let statsByPercent:Float = statsSlice / 10.0
		let minRankStat:Float = Float(rank.rawValue)*statsSlice
		let minStat:Float = minRankStat + (statsByPercent * (max(0.0, Float(percent) - 10.0) / 10.0))
		let maxStat:Float = minRankStat + (statsByPercent * (Float(percent) / 10.0))
		
		stats.hp = Int(max(Float(BF_Monster.Stats.range.lowerBound),Float.random(in: minStat ... maxStat)))
		stats.mp = Int(max(Float(BF_Monster.Stats.range.lowerBound),Float.random(in: minStat ... maxStat)))
		stats.atk = Int(max(Float(BF_Monster.Stats.range.lowerBound),Float.random(in: minStat ... maxStat)))
		stats.def = Int(max(Float(BF_Monster.Stats.range.lowerBound),Float.random(in: minStat ... maxStat)))
		stats.luk = Int(max(Float(BF_Monster.Stats.range.lowerBound),Float.random(in: minStat ... maxStat)))
		
		status.hp = stats.hp
		status.mp = stats.mp
	}
	
	public func add(_ completion:(()->Void)?) {
		
		if BF_User.current?.monsters.count ?? 0 >= BF_Firebase.shared.config.int(.MaxMonstersCount) + (BF_User.current?.monstersPlaces ?? 0) {
			
			let alertController:BF_Alert_ViewController = .init()
			alertController.title = String(key: "monsters.add.max.alert.title")
			alertController.add(UIImage(named: "placeholder_delete"))
			alertController.add(String(key: "monsters.add.max.alert.content"))
			alertController.addButton(title: String(key: "monsters.add.max.alert.button.delete")) { [weak self] _ in
				
				alertController.close { [weak self] in
					
					let viewController:BF_Monsters_List_Select_ViewController = .init()
					viewController.monsters = BF_User.current?.monsters
					viewController.handler = { [weak self] monsters in
						
						BF_User.current?.monsters.removeAll(where: { $0 == monsters?.first })
						
						let alertController:BF_Alert_ViewController = .presentLoading()
						
						BF_User.current?.update({ [weak self] error in
							
							alertController.close { [weak self] in
								
								if let error {
									
									BF_Alert_ViewController.present(error)
								}
								else {
									
									self?.add(completion)
								}
							}
						})
					}
					
					UI.MainController.present(BF_NavigationController(rootViewController: viewController), animated: true)
				}
			}
			alertController.addButton(title: String(key: "monsters.add.max.alert.button.buy")) { _ in
				
				alertController.close {
					
					UI.MainController.present(BF_NavigationController(rootViewController: BF_Items_Shop_ViewController()), animated: true)
				}
			}
			alertController.addCancelButton()
			alertController.present()
		}
		else {
			
			let alertController:BF_Alert_ViewController = .presentLoading()
			
			BF_User.current?.monsters.append(self)
			BF_User.current?.updateAndAddExperience(BF_Firebase.shared.config.int(.ExperienceMonsterEnrollment), withToast: true) { error in
				
				alertController.close {
					
					if let error = error {
						
						BF_Alert_ViewController.present(error)
					}
					else {
						
						NotificationCenter.post(.updateMonsters)
						
						completion?()
					}
				}
			}
		}
	}
}

extension [BF_Monster] {
	
	public enum Sort : String {
		
		case Date = "date"
		case Name = "name"
		case Rank = "rank"
		case Element = "element"
		case StatusHp = "status.hp"
		case StatusMp = "status.mp"
		case StatsHp = "stats.hp"
		case StatsMp = "stats.mp"
		case StatsAtk = "stats.atk"
		case StatsDef = "stats.def"
		case StatsLuk = "stats.luk"
		case FightsVictories = "fights.victories"
		case FightsDefeats = "fights.defeats"
		case FightsDropouts = "fights.dropouts"
		case Battle = "battle"
		
		public var name:String {
			
			return String(key: "monsters.sort.\(rawValue).button")
		}
	}
	
	public func sort(_ sort:Sort) -> [BF_Monster] {
		
		switch sort {
		
		case .Date:
			return sorted(by: { $0.scanDate ?? Date() > $1.scanDate ?? Date() })
		case .Name:
			return sorted(by: { $0.name < $1.name })
		case .Rank:
			return sorted(by: { $0.stats.rank > $1.stats.rank })
		case .Element:
			return sorted(by: { $0.element == $1.element })
		case .StatusHp:
			return sorted(by: { $0.status.hp / $0.stats.hp > $1.status.hp / $1.stats.hp })
		case .StatusMp:
			return sorted(by: { $0.status.mp / $0.stats.mp > $1.status.mp / $1.stats.mp })
		case .StatsHp:
			return sorted(by: { $0.stats.hp > $1.stats.hp })
		case .StatsMp:
			return sorted(by: { $0.stats.mp > $1.stats.mp })
		case .StatsAtk:
			return sorted(by: { $0.stats.atk > $1.stats.atk })
		case .StatsDef:
			return sorted(by: { $0.stats.def > $1.stats.def })
		case .StatsLuk:
			return sorted(by: { $0.stats.luk > $1.stats.luk })
		case .FightsVictories:
			return sorted(by: { $0.fights.victories.count > $1.fights.victories.count })
		case .FightsDefeats:
			return sorted(by: { $0.fights.defeats.count > $1.fights.defeats.count })
		case .FightsDropouts:
			return sorted(by: { $0.fights.dropouts.count > $1.fights.dropouts.count })
		case .Battle:
			return sorted(by: { $0.stats.rank > $1.stats.rank && $0.status.hp > $1.status.hp })
		}
	}
}

extension BF_Monster.Genre {
	
	public var readable:String {
		
		return String(key: "monsters.genre.\(rawValue)")
	}
}

extension BF_Monster.Stats {
	
	public var readableHeight:String {
		
		return [String(format: "%.1f", height/100),String(key: "monsters.stats.height.currency")].joined(separator: " ")
	}
	
	public var readableWeight:String {
		
		return [String(format: "%.1f", weight/100),String(key: "monsters.stats.weight.currency")].joined(separator: " ")
	}
}

extension BF_Monster.Stats.Rank {
	
	public var readable:String {
		
		return String(key: "monsters.stats.rank.\(rawValue)")
	}
}

extension BF_Monster.Element {
	
	public var readable:String {
		
		return String(key: "monsters.element.\(rawValue)")
	}
	
	public var image:UIImage? {
		
		switch self {
			
		case .Fire:
			return UIImage(systemName: "flame")
		case .Ice:
			return UIImage(systemName: "snowflake")
		case .Wind:
			return UIImage(systemName: "wind")
		case .Earth:
			return UIImage(systemName: "globe.europe.africa")
		case .Electricity:
			return UIImage(systemName: "bolt")
		case .Water:
			return UIImage(systemName: "drop")
		case .Lightness:
			return UIImage(systemName: "sun.max")
		case .Darkness:
			return UIImage(systemName: "moonphase.waxing.crescent")
		case .Neutral:
			return UIImage(systemName: "square.dotted")
		}
	}
	
	public var color:UIColor {
		
		switch self {
			
		case .Fire:
			return Colors.Monsters.Elements.Fire
		case .Ice:
			return Colors.Monsters.Elements.Ice
		case .Wind:
			return Colors.Monsters.Elements.Wind
		case .Earth:
			return Colors.Monsters.Elements.Earth
		case .Electricity:
			return Colors.Monsters.Elements.Electricity
		case .Water:
			return Colors.Monsters.Elements.Water
		case .Lightness:
			return Colors.Monsters.Elements.Lightness
		case .Darkness:
			return Colors.Monsters.Elements.Darkness
		case .Neutral:
			return Colors.Monsters.Elements.Neutral
		}
	}
}
