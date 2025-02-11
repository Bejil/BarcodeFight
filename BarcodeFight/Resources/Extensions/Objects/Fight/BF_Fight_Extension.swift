//
//  BF_Fight_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 17/08/2023.
//

import Foundation
import UIKit

extension BF_Fight {
	
	public static func new(_ user:BF_User? = nil) {
		
		if BF_User.current?.rubies ?? 0 < BF_Firebase.shared.config.int(.RubiesFightCost) {
			
			let alertController:BF_Rubies_Alert_ViewController = .init()
			alertController.present()
		}
		else {
			
			if BF_User.current?.monsters.filter({ !$0.isDead }).isEmpty ?? true {
				
				BF_Monster.presentEmptyMonstersAlertController()
			}
			else {
				
				let promptEmptyOpponentAlert:(()->Void) = {
					
					let alertController:BF_Alert_ViewController = .init()
					alertController.title = String(key: "fights.emptyOpponent.alert.title")
					alertController.add(UIImage(named: "placeholder_empty"))
					alertController.add(String(key: "fights.emptyOpponent.alert.label.0"))
					alertController.add(String(key: "fights.emptyOpponent.alert.label.1"))
					alertController.addButton(title: String(key: "fights.emptyOpponent.alert.button")) { button in
						
						button?.isLoading = true
						
						BF_User.current?.rubies -= BF_Firebase.shared.config.int(.RubiesFightCost)
						BF_User.current?.update({ error in
							
							alertController.close {
								
								if let error = error {
									
									BF_Alert_ViewController.present(error)
								}
								else {
									
									NotificationCenter.post(.updateAccount)
									
									let viewController:BF_Battle_Opponent_ViewController = .init()
									viewController.opponentMonsters = [.init(from: String.randomBarCode, with: nil),.init(from: String.randomBarCode, with: nil),.init(from: String.randomBarCode, with: nil)]
									UI.MainController.present(BF_NavigationController(rootViewController: viewController), animated: true)
								}
							}
						})
					}
					alertController.addCancelButton()
					alertController.present()
				}
				
				let check:((Error?,BF_User?,(([BF_Monster]?)->Void)?)->Void) = { error, user, completion in
					
					if let error = error { 
						
						BF_Alert_ViewController.present(error)
					}
					else if let user = user, user.uid != BF_User.current?.uid {
						
						let monsters = user.enemyTeam
						
						if !(monsters?.isEmpty ?? true) {
							
							BF_Alert_ViewController.presentLoading() { alertController in
								
								BF_User.current?.rubies -= BF_Firebase.shared.config.int(.RubiesFightCost)
								BF_User.current?.update({ error in
									
									alertController?.close {
										
										if let error = error {
											
											BF_Alert_ViewController.present(error)
										}
										else {
											
											NotificationCenter.post(.updateAccount)
											
											completion?(monsters)
										}
									}
								})
							}
						}
						else {
							
							promptEmptyOpponentAlert()
						}
					}
					else {
						
						promptEmptyOpponentAlert()
					}
				}
				
				let start:((BF_User?,[BF_Monster]?)->Void) = { user, monsters in
					
					monsters?.forEach({
						
						$0.status.hp = $0.stats.hp
						$0.status.mp = $0.stats.mp
					})
					
					let viewController:BF_Battle_Opponent_User_ViewController = .init()
					viewController.opponent = user
					viewController.opponentMonsters = monsters
					UI.MainController.present(BF_NavigationController(rootViewController: viewController), animated: true)
				}
				
				if let user {
					
					check(nil,user) { monsters in
						
						start(user,monsters)
					}
				}
				else {
					
					let alertController:BF_Alert_ViewController = .init()
					alertController.title = String(key: "fights.alert.title")
					alertController.add(UIImage(named: "battle_icon"))
					alertController.add(String(key: "fights.alert.label.0"))
					alertController.addButton(title: String(key: "fights.alert.button.0"), subtitle: String(key: "fights.alert.cost.0") + "\(BF_Firebase.shared.config.int(.RubiesFightCost))" + String(key: "fights.alert.cost.1"), image: UIImage(named: "items_rubies")) { button in
						
						alertController.close {
							
							BF_Alert_ViewController.presentLoading() { alertController in
								
								BF_User.getRandom { error, user in
									
									alertController?.close {
										
										check(error,user) { monsters in
											
											start(user,monsters)
										}
									}
								}
							}
						}
					}
					alertController.add(String(key: "fights.alert.label.1"))
					
					alertController.addButton(title: String(key: "fights.alert.button.1"), subtitle: String(key: "fights.alert.cost.0") + "\(BF_Firebase.shared.config.int(.RubiesFightCost))" + String(key: "fights.alert.cost.1"), image: UIImage(named: "items_rubies")) { button in
						
						alertController.close {
							
							let viewController:BF_Scanner_ViewController = .init()
							viewController.style = .Qr
							viewController.handler = { string in
								
								BF_Alert_ViewController.presentLoading() { alertController in
									
									BF_User.get(string) { user, error in
										
										alertController?.close() {
											
											if let user {
												
												check(error,user) { _ in
													
													BF_Fight_Live_Manager.shared.createNewFight(against: user)
												}
											}
											else {
												
												BF_Alert_ViewController.present(BF_Error(String(key: "fights.alert.notFound.error")))
											}
										}
									}
								}
							}
							UI.MainController.present(viewController, animated: true)
						}
					}
					
					alertController.addCancelButton()
					alertController.present(as: .Sheet)
				}
			}
		}
	}
}

extension [BF_Fight] {
	
	public var victories:[BF_Fight] {
		
		return filter({ $0.state == .Victory })
	}
	
	public var defeats:[BF_Fight] {
		
		return filter({ $0.state == .Defeat })
	}
	
	public var dropouts:[BF_Fight] {
		
		return filter({ $0.state == .Dropout })
	}
}
