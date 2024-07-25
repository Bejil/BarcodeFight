//
//  BF_Fight_Live.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 03/05/2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

public class BF_Fight_Live_Manager: NSObject {
	
	static public let shared:BF_Fight_Live_Manager = .init()
	private var demandsListener:ListenerRegistration?
	public var stateListener:ListenerRegistration?
	
	deinit {
		
		demandsListener?.remove()
		stateListener?.remove()
	}
	
	public func startListeningDemands() {
		
		if BF_User.current?.uid != nil {
			
			demandsListener = BF_Fight_Live.listenDemands { fight in
				
				if let fight {
					
					BF_User.get(fight.creator.uid) { [weak self] user, error in
						
						if let error {
							
							BF_Alert_ViewController.present(error)
						}
						else if let user {
							
							UI.MainController.dismiss(animated: true) {
								
								let alertController:BF_Alert_ViewController = .init()
								alertController.title = String(key: "fights.live.demandWaiting.alert.title")
								alertController.backgroundView.isUserInteractionEnabled = false
								
								let userStackView:BF_User_Opponent_StackView = .init()
								userStackView.user = user
								alertController.add(userStackView)
								
								alertController.addButton(title: String(key: "fights.live.demandWaiting.alert.accept.button")) { [weak self] button in
									
									self?.stateListener?.remove()
									
									fight.state = .DemandAccepted
									
									button?.isLoading = true
									
									fight.update { error in
										
										button?.isLoading = false
										
										alertController.close {
											
											if let error {
												
												BF_Alert_ViewController.present(error)
											}
											else {
												
												let viewController:BF_Battle_Opponent_User_ViewController = .init()
												viewController.fight = fight
												viewController.opponent = user
												viewController.opponentMonsters = user.enemyTeam
												UI.MainController.present(BF_NavigationController(rootViewController: viewController), animated: true)
											}
										}
									}
								}
								
								alertController.addButton(title: String(key: "fights.live.demandWaiting.alert.refuse.button")) { button in
									
									self?.stateListener?.remove()
									
									fight.state = .DemandRefused
									
									button?.isLoading = true
									
									fight.update { error in
										
										button?.isLoading = false
										
										alertController.close {
											
											if let error {
												
												BF_Alert_ViewController.present(error)
											}
										}
									}
								}
								
								alertController.present()
								
								self?.stateListener = fight.listen { [weak self] fight in
									
									if let fight, fight.state == .DemandCancelled {
										
										self?.stateListener?.remove()
										
										alertController.close {
											
											BF_Alert_ViewController.present(BF_Error(String(key: "fights.live.demandCancelled.alert.error")))
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	public func createNewFight(against user:BF_User) {
		
		BF_Fight_Live.isFightAlreadyActive(for: user) { [weak self] state in
			
			if state ?? true {
				
				BF_Alert_ViewController.present(BF_Error(String(key: "fights.live.alreadyActive.alert.error")))
			}
			else {
				
				let alertController:BF_Alert_ViewController = .init()
				alertController.backgroundView.isUserInteractionEnabled = false
				alertController.title = String(key: "fights.live.alert.title")
				
				let userStackView:BF_User_Opponent_StackView = .init()
				userStackView.user = user
				alertController.add(userStackView)
				
				alertController.addButton(title: String(key: "fights.live.alert.ask.button")) { [weak self] button in
					
					let fight:BF_Fight_Live = .init()
					fight.opponent = .init()
					fight.opponent?.uid = user.uid
					fight.state = .DemandWaiting
					
					button?.isLoading = true
					
					fight.save { [weak self] fight, error in
						
						button?.isLoading = false
						
						alertController.close { [weak self] in
							
							if let error {
								
								BF_Alert_ViewController.present(error)
							}
							else if let fight {
								
								var expirationTimer:Timer? = nil
								
								let alertController:BF_Alert_ViewController = .presentLoading()
								alertController.backgroundView.isUserInteractionEnabled = false
								
								alertController.addButton(title: String(key: "fights.live.alert.cancel.button")) { [weak self] button in
									
									self?.stateListener?.remove()
									
									fight.state = .DemandCancelled
									
									button?.isLoading = true
									
									fight.update { error in
										
										button?.isLoading = false
										
										if let error {
											
											BF_Alert_ViewController.present(error)
										}
										else {
											
											button?.isLoading = true
											
											fight.delete { error in
												
												button?.isLoading = false
												
												alertController.close {
													
													if let error {
														
														BF_Alert_ViewController.present(error)
													}
												}
											}
										}
									}
								}
								
								self?.stateListener = fight.listen({ [weak self] fight in
									
									if let fight {
										
										if fight.state == .DemandAccepted {
											
											self?.stateListener?.remove()
											
											expirationTimer?.invalidate()
											expirationTimer = nil
											
											alertController.close {
												
												let viewController:BF_Battle_Opponent_User_ViewController = .init()
												viewController.fight = fight
												viewController.opponent = user
												viewController.opponentMonsters = user.enemyTeam
												UI.MainController.present(BF_NavigationController(rootViewController: viewController), animated: true)
												
												BF_Toast().present(title: String(key: "fights.live.demandAccepted.toast.title"), style: .Success)
											}
										}
										else if fight.state == .DemandRefused {
											
											self?.stateListener?.remove()
											
											expirationTimer?.invalidate()
											expirationTimer = nil
											
											alertController.close {
												
												let alertController:BF_Alert_ViewController = .presentLoading()
												
												fight.delete { error in
													
													alertController.close {
														
														if let error {
															
															BF_Alert_ViewController.present(error)
														}
														else {
															
															BF_Alert_ViewController.present(BF_Error(String(key: "fights.live.demandRefused.toast.title")))
														}
													}
												}
											}
										}
									}
								})
							}
						}
					}
				}
				alertController.addCancelButton()
				alertController.present()
			}
		}
	}
}
	
public class BF_Fight_Live : Codable {
	
	public enum State : Int, Codable {
		
		case DemandWaiting
		case DemandAccepted
		case DemandRefused
		case DemandCancelled
		
		case OpponentUpdated
		
		case Cancelled
		
		case InitialTurnUpdate
		
		case FightUpdateOpponentCurrentMonster
		case FightHitOpponentCurrentMonster
		case FightOpponentDropout
	}
	
	public class Player : Codable {
		
		public var uid:String? = BF_User.current?.uid
		public var monsters:[BF_Monster]?
		public var currentMonster:BF_Monster?
		public var isStarter:Bool = false
	}
	
	public class Action : Codable {
		
		public var attacker:BF_Monster?
		public var target:BF_Monster?
		public var isMagical:Bool?
		public var isDodge:Bool?
		public var isCritical:Bool?
		public var isBlocked:Bool?
		public var hpToRemove:Double?
	}
	
	@DocumentID public var id:String?
	public var creationDate:Date = Date()
	public var state:State?
	public var creator:Player = .init()
	public var opponent:Player?
	public var lastAction:Action?
}

extension BF_Fight_Live {
	
	public static func isFightAlreadyActive(for user:BF_User?, _ completion:((Bool?)->Void)?) {
		
		Firestore.firestore().collection("fightsLive").whereField("opponent.uid", isEqualTo: user?.uid ?? "").getDocuments { querySnapshot, error in
			
			completion?(!(querySnapshot?.documents.compactMap({ try?$0.data(as: BF_Fight_Live.self) }).isEmpty ?? true))
		}
	}
	
	public static func deleteActives(_ completion:(()->Void)?) {
		
		let group = DispatchGroup()
		
		var results:[BF_Fight_Live] = .init()
		
		group.enter()
		
		Firestore.firestore().collection("fightsLive").whereField("creator.uid", isEqualTo: BF_User.current?.uid ?? "").getDocuments { snapshot, error in
			
			results.append(contentsOf: snapshot?.documents.compactMap { try? $0.data(as: BF_Fight_Live.self) } ?? [])
			group.leave()
		}
		
		group.enter()
		
		Firestore.firestore().collection("fightsLive").whereField("opponent.uid", isEqualTo: BF_User.current?.uid ?? "").getDocuments { snapshot, error in
			
			results.append(contentsOf: snapshot?.documents.compactMap { try? $0.data(as: BF_Fight_Live.self) } ?? [])
			group.leave()
		}
		
		group.notify(queue: .main) {
			
			let dispatchGroup = DispatchGroup()
			
			results.forEach({ fight in
				
				group.enter()
				
				fight.state = .Cancelled
				
				fight.update { _ in
					
					fight.delete { _ in
						
						group.leave()
					}
				}
			})
			
			dispatchGroup.notify(queue: .main) {
				
				completion?()
			}
		}
	}
	
	public func save(_ completion:((BF_Fight_Live?,Error?)->Void)?) {
		
		do {
			
			let documentReference = try Firestore.firestore().collection("fightsLive").addDocument(from: self)
			documentReference.getDocument(as: BF_Fight_Live.self) { result in
				
				switch result {
				case .success(let fight):
					completion?(fight, nil)
				case .failure(let error):
					completion?(nil, error)
				}
			}
		}
		catch {
			
			completion?(nil,error)
		}
	}
	
	public func update(_ completion:((Error?)->Void)?) {
		
		let docRef = Firestore.firestore().collection("fightsLive").document(id ?? "")
		
		do {
			
			try docRef.setData(from: self) { error in
				
				completion?(error)
			}
		}
		catch {
			
			completion?(error)
		}
	}
	
	public func delete(_ completion:((Error?)->Void)?) {
		
		let docRef = Firestore.firestore().collection("fightsLive").document(id ?? "")
		docRef.delete(completion: completion)
	}
	
	public func listen(_ completion:((BF_Fight_Live?)->Void)?) -> ListenerRegistration? {
		
		let docRef = Firestore.firestore().collection("fightsLive").document(id ?? "")
		return docRef.addSnapshotListener { documentSnapshot, error in
			
			if !(documentSnapshot?.metadata.hasPendingWrites ?? true), let fight = try?documentSnapshot?.data(as: BF_Fight_Live.self) {
				
				completion?(fight)
			}
		}
	}
	
	public static func listenDemands(_ completion:((BF_Fight_Live?)->Void)?) -> ListenerRegistration? {
		
		return Firestore.firestore().collection("fightsLive").whereField("opponent.uid", isEqualTo: BF_User.current?.uid ?? "").addSnapshotListener { querySnapshot, error in
			
			if !(querySnapshot?.metadata.hasPendingWrites ?? true), let fight = querySnapshot?.documents.compactMap({ try?$0.data(as: BF_Fight_Live.self) }).first, fight.state == .DemandWaiting {
				
				completion?(fight)
			}
		}
	}
}
