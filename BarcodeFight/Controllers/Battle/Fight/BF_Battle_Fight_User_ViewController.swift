//
//  BF_Battle_Fight_User_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 05/09/2023.
//

import Foundation
import UIKit

public class BF_Battle_Fight_User_ViewController : BF_Battle_Fight_ViewController {
	
	public override var experienceVictory: Int {
		
		return BF_Firebase.shared.config.int(.ExperienceFightVictory) * max(1,(enemyUser?.level.number ?? 0) - (BF_User.current?.level.number ?? 0))
	}
	public override var experienceDefeat: Int {
		
		return BF_Firebase.shared.config.int(.ExperienceFightDefeat)
	}
	public override var experienceDropout: Int {
		
		return BF_Firebase.shared.config.int(.ExperienceFightDropout)
	}
	private var needtoUpdateFight:Bool = true
	public var fight:BF_Fight_Live? {
		
		didSet {
			
			let starterPlayer = [fight?.creator,fight?.opponent].first(where: { $0?.isStarter ?? false })
			isPlayerTurn = starterPlayer??.uid == BF_User.current?.uid
			
			BF_Fight_Live_Manager.shared.stateListener = fight?.listen({ [weak self] fight in
				
				if let fight {
					
					if fight.state == .FightUpdateOpponentCurrentMonster,
						let player = [fight.creator,fight.opponent].first(where: { $0?.uid == self?.enemyUser?.uid }) {
						
						self?.needtoUpdateFight = false
						
						self?.enemyTeam = player?.monsters
						self?.enemyCurrentMonster = player?.currentMonster
						
						self?.needtoUpdateFight = true
						
						self?.scrollToCurrentEnemyMonster()
					}
					else if fight.state == .FightHitOpponentCurrentMonster, let action = fight.lastAction {
						
						self?.needtoUpdateFight = false
						
						self?.moveMonsters(attacker: action.attacker, target: action.target, isMagical: action.isMagical ?? false, isDodge: action.isDodge ?? false, isCritical: action.isCritical ?? false, hpToRemove: action.hpToRemove ?? 0.0, isBlocked: action.isBlocked ?? false, movement:true, completion: { [weak self] in
							
							let player = [fight.creator,fight.opponent].first(where: { $0?.uid == BF_User.current?.uid })
							self?.playerTeam = player??.monsters
							self?.playerCurrentMonster = player??.currentMonster?.isDead ?? true ? self?.playerTeam?.first(where: { !$0.isDead }) : player??.currentMonster
							
							let enemy = [fight.creator,fight.opponent].first(where: { $0?.uid == self?.enemyUser?.uid })
							self?.enemyTeam = enemy??.monsters
							self?.enemyCurrentMonster = enemy??.currentMonster?.isDead ?? true ? self?.enemyTeam?.first(where: { !$0.isDead }) : enemy??.currentMonster
							
							self?.needtoUpdateFight = true
							
							self?.scrollToCurrentPlayerMonster()
							self?.scrollToCurrentEnemyMonster()
							
							if !(self?.isPlayerTurn ?? false) {
								
								self?.playerTurn()
							}
						})
					}
					else if fight.state == .FightOpponentDropout {
						
						self?.showDimView(String(key: "fights.battle.opponent.dropout")) { [weak self] in
							
							self?.finishBattle(withState: .Victory)
						}
					}
				}
			})
		}
	}
	
	public override func loadView() {
		
		super.loadView()
		
		startToss()
	}
	
	public override func enemyTurn() {
		
		if enemyTeam?.allSatisfy({ $0.isDead }) ?? false || playerTeam?.allSatisfy({ $0.isDead }) ?? false {
			
			finishBattle(withState: enemyTeam?.allSatisfy({ $0.isDead }) ?? false ? .Victory : .Defeat)
		}
	}
	
	public override func moveMonsters(attacker: BF_Monster?, target: BF_Monster?, isMagical: Bool, isDodge: Bool, isCritical: Bool, hpToRemove: Double, isBlocked: Bool, movement:Bool, completion: (() -> Void)?) {
		
		super.moveMonsters(attacker: attacker, target: target, isMagical: isMagical, isDodge: isDodge, isCritical: isCritical, hpToRemove: hpToRemove, isBlocked: isBlocked, movement:movement, completion: completion)
		
		if needtoUpdateFight && target == enemyCurrentMonster {
			
			fight?.lastAction = .init()
			fight?.lastAction?.attacker = attacker
			fight?.lastAction?.target = target
			fight?.lastAction?.isMagical = isMagical
			fight?.lastAction?.isDodge = isDodge
			fight?.lastAction?.isCritical = isCritical
			fight?.lastAction?.hpToRemove = hpToRemove
			fight?.lastAction?.isBlocked = isBlocked
			fight?.state = .FightHitOpponentCurrentMonster
			
			[fight?.creator,fight?.opponent].first(where: { $0?.uid == enemyUser?.uid })??.monsters = enemyTeam
			[fight?.creator,fight?.opponent].first(where: { $0?.uid == enemyUser?.uid })??.currentMonster = target
			
			[fight?.creator,fight?.opponent].first(where: { $0?.uid == BF_User.current?.uid })??.monsters = playerTeam
			[fight?.creator,fight?.opponent].first(where: { $0?.uid == BF_User.current?.uid })??.currentMonster = attacker
			
			fight?.update(nil)
		}
	}
	
	private func updateMonsters(_ scrollView:UIScrollView) {
		
		let page = Int(max(0.0, round(scrollView.contentOffset.x / scrollView.bounds.width)))
		
		fight?.lastAction = nil
		
		if scrollView == playerMonstersScrollView {
			
			fight?.state = .FightUpdateOpponentCurrentMonster
			[fight?.creator,fight?.opponent].first(where: { $0?.uid == BF_User.current?.uid })??.monsters = playerTeam
			[fight?.creator,fight?.opponent].first(where: { $0?.uid == BF_User.current?.uid })??.currentMonster = playerTeam?[page]
		}
		
		fight?.update(nil)
	}
	
	public override func dismiss(_ completion: (() -> Void)? = nil) {
		
		BF_Fight_Live.deleteActives(nil)
		
		super.dismiss()
	}
	
	public override func finishBattle(withState state: BF_Fight.State) {
		
		super.finishBattle(withState: state)
		
		if state == .Dropout {
			
			fight?.state = .FightOpponentDropout
			fight?.update(nil)
		}
		else {
			
			BF_Challenge.increase(Challenges.Fights)
		}
	}
	
	public override func playerTurn() {
		
		super.playerTurn()
		
		if !isPause && !(enemyTeam?.allSatisfy({ $0.isDead }) ?? false || playerTeam?.allSatisfy({ $0.isDead }) ?? false) {
			
			showDimView(String(key: "fights.battle.isPlayerTurn"), 0.0)
		}
	}
}

extension BF_Battle_Fight_User_ViewController {
	
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		
		updateMonsters(scrollView)
	}
	
	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		
		if !decelerate {
			
			updateMonsters(scrollView)
		}
	}
	
	public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		needtoUpdateFight = false
		
		super.scrollViewDidScroll(scrollView)
		
		needtoUpdateFight = true
	}
}
