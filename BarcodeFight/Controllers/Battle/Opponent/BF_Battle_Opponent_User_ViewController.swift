//
//  BF_Battle_Opponent_User_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 18/08/2023.
//

import Foundation
import UIKit

public class BF_Battle_Opponent_User_ViewController : BF_Battle_Opponent_ViewController {
	
	private var fightDelay:Int = BF_Firebase.shared.config.int(.LiveOpponentDelay)
	private var fightTimer:Timer?
	public var fight:BF_Fight_Live? {
		
		didSet {
			
			startButton.isEnabled = false
			
			fightTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
				
				self?.fightDelay -= 1
				self?.startButton.title = String(key: "fights.opponent.user.start.button.timer") + "\(Int(self?.fightDelay ?? 0))s"
				
				if self?.fightDelay == 0 {
					
					let startClosure:(()->Void) = { [weak self] in
						
						self?.resetFightTimer()
						
						self?.startButton.title = String(key: "fights.opponent.user.start.button.loading")
						self?.startButton.isLoading = true
						
						if BF_User.current?.uid == self?.fight?.creator.uid {
							
							let isStarter = Bool.random()
							self?.fight?.creator.isStarter = isStarter
							self?.fight?.opponent?.isStarter = !isStarter
							self?.fight?.state = .InitialTurnUpdate
							self?.fight?.update { [weak self] _ in
								
								self?.startFightAfterToss(self?.fight)
							}
						}
					}
					
					if UI.MainController.isKind(of: BF_Battle_Team_ViewController.self) {
						
						UI.MainController.dismiss(animated: true, completion: startClosure)
					}
					else {
						
						startClosure()
					}
				}
			})
		}
	}
	public override var opponent:BF_User? {
		
		didSet {
			
			opponentUserStackView.user = opponent
		}
	}
	private lazy var opponentUserStackView:BF_User_Opponent_StackView = {
		
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins.bottom = UI.Margins
		$0.addLine(position: .bottom)
		return $0
		
	}(BF_User_Opponent_StackView())
	public override var teamMonsters: [BF_Monster]? {
		
		didSet {
			
			if oldValue != nil {
				
				fight?.state = .OpponentUpdated
				[fight?.creator,fight?.opponent].first(where: { $0?.uid == BF_User.current?.uid })??.monsters = teamMonsters
				fight?.update(nil)
			}
		}
	}
	
	deinit {
		
		resetFightTimer()
	}
	
	public override func loadView() {
		
		super.loadView()
		
		opponentStackView.insertArrangedSubview(opponentUserStackView, at: 1)
		
		BF_Fight_Live_Manager.shared.stateListener = fight?.listen({ [weak self] fight in
			
			if fight?.state == .OpponentUpdated {
				
				if fight?.creator.uid == BF_User.current?.uid {
					
					self?.opponentMonsters = fight?.opponent?.monsters
				}
				else {
					
					self?.opponentMonsters = fight?.creator.monsters
				}
			}
			else if fight?.state == .Cancelled {
				
				self?.dismiss({
					
					BF_Alert_ViewController.present(BF_Error(String(key: "fights.opponent.user.cancelled.error")))
				})
			}
			else if fight?.state == .InitialTurnUpdate {
				
				self?.startFightAfterToss(fight)
			}
		})
	}
	
	private func startFightAfterToss(_ fight:BF_Fight_Live?) {
		
		dismiss({ [weak self] in
			
			let viewController:BF_Battle_Fight_User_ViewController = .init()
			viewController.playerTeam = self?.teamMonsters
			viewController.enemyUser = self?.opponent
			viewController.enemyTeam = self?.opponentMonsters
			viewController.fight = fight
			viewController.victoryHandler = self?.victoryHandler
			UI.MainController.present(BF_NavigationController(rootViewController: viewController), animated: true)
		})
	}
	
	public override func close() {
		
		BF_Alert_ViewController.presentLoading() { alertController in
			
			BF_Fight_Live.deleteActives {
				
				alertController?.close {
					
					super.close()
				}
			}
		}
	}
	
	private func resetFightTimer() {
		
		fightTimer?.invalidate()
		fightTimer = nil
	}
}
