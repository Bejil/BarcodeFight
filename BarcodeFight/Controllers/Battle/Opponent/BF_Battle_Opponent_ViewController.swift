//
//  BF_Battle_Opponent_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 18/08/2023.
//

import Foundation
import UIKit

public class BF_Battle_Opponent_ViewController : BF_ViewController {
	
	public var victoryHandler:(()->Void)?
	public var opponent:BF_User?
	public var opponentMonsters:[BF_Monster]? {
		
		didSet {
			
			opponentMonstersStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
			 
			opponentMonsters?.sort(.Rank).forEach({
				
				let stackView:BF_Monsters_StackView = .init()
				stackView.monster = $0
				stackView.flip()
				opponentMonstersStackView.addArrangedSubview(stackView)
			})
			
			UIView.animate {
				
				self.opponentMonstersStackView.isHidden = self.opponentMonstersStackView.arrangedSubviews.isEmpty
				self.opponentMonstersStackView.alpha = self.opponentMonstersStackView.isHidden ? 0.0 : 1.0
				self.opponentMonstersStackView.superview?.layoutIfNeeded()
			}
		}
	}
	public lazy var opponentStackView = createStackView(title: String(key: "fights.opponent.enemy.title"), monstersStackView: opponentMonstersStackView)
	private lazy var opponentMonstersStackView:UIStackView = createMonstersStackView()
	public var teamMonsters:[BF_Monster]? {
		
		didSet {
			
			teamMonstersStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
			
			teamMonsters?.forEach({
				
				let stackView:BF_Monsters_StackView = .init()
				stackView.monster = $0
				teamMonstersStackView.addArrangedSubview(stackView)
			})
			
			UIView.animate {
				
				self.teamMonstersStackView.isHidden = self.teamMonstersStackView.arrangedSubviews.isEmpty
				self.teamMonstersStackView.alpha = self.teamMonstersStackView.isHidden ? 0.0 : 1.0
				self.teamMonstersStackView.superview?.layoutIfNeeded()
			}
		}
	}
	private lazy var teamMonstersStackView:UIStackView = createMonstersStackView()
	public lazy var startButton:BF_Button = .init(String(key: "fights.opponent.start.button")) { [weak self] _ in
		
		self?.startFight()
	}
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.title = String(key: "fights.opponent.title")
		
		let placeholderView:BF_Placeholder_View = .init()
		placeholderView.isCentered = false
			
		placeholderView.contentStackView.addArrangedSubview(opponentStackView)
		
		let teamStackView = createStackView(title: String(key: "fights.opponent.team.title"), subtitle: String(key: "fights.opponent.team.subtitle"), monstersStackView: teamMonstersStackView)
		placeholderView.contentStackView.addArrangedSubview(teamStackView)
		
		let editButton:BF_Button = .init(String(key: "fights.opponent.team.edit.button")) { [weak self] _ in
			
			if let monsters = BF_User.current?.monsters {
				
				let viewController:BF_Battle_Team_ViewController = .init()
				viewController.monsters = monsters.filter({ !$0.isDead })
				viewController.selectedMonsters = (self?.teamMonstersStackView.arrangedSubviews as? [BF_Monsters_StackView])?.compactMap({ $0.monster })
				viewController.handler = { [weak self] selectedMonsters in
					
					self?.teamMonsters = selectedMonsters
				}
				UI.MainController.present(BF_NavigationController(rootViewController: viewController), animated: true)
			}
		}
		editButton.style = .tinted
		teamStackView.addArrangedSubview(editButton)
		
		let startButtonView:UIView = .init()
		
		let visualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .regular))
		startButtonView.addSubview(visualEffectView)
		visualEffectView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		startButtonView.layer.masksToBounds = true
		startButtonView.layer.cornerRadius = UI.CornerRadius
		
		startButtonView.addSubview(startButton)
		startButton.snp.makeConstraints { make in
			make.edges.equalTo(startButtonView.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		let stackView:UIStackView = .init(arrangedSubviews: [placeholderView,startButtonView])
		stackView.axis = .vertical
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.top.right.left.equalTo(view.safeAreaLayoutGuide)
			make.bottom.equalToSuperview()
		}
		
		teamMonsters = BF_User.current?.playerTeam
	}
	
	private func startFight() {
		
		dismiss({ [weak self] in
			
			let viewController:BF_Battle_Fight_Fake_ViewController = .init()
			viewController.playerTeam = self?.teamMonsters
			viewController.enemyUser = self?.opponent
			viewController.enemyTeam = self?.opponentMonsters
			viewController.victoryHandler = self?.victoryHandler
			UI.MainController.present(viewController, animated: true)
		})
	}
	
	private func createStackView(title:String, subtitle:String? = nil, monstersStackView:UIStackView) -> UIStackView {
		
		let stackView:UIStackView = .init()
		stackView.axis = .vertical
		stackView.spacing = 1.5*UI.Margins
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.layoutMargins = .init(UI.Margins)
		stackView.layoutMargins.bottom = 2*UI.Margins
		stackView.layer.cornerRadius = UI.CornerRadius
		stackView.clipsToBounds = true
		
		let teamVisualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .dark))
		stackView.addSubview(teamVisualEffectView)
		teamVisualEffectView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let titleLabel:BF_Label = .init(title)
		titleLabel.font = Fonts.Content.Title.H4
		titleLabel.contentInsets.bottom = UI.Margins/2
		titleLabel.textAlignment = .center
		titleLabel.addLine(position: .bottom)
		stackView.addArrangedSubview(titleLabel)
			
		if let subtitle = subtitle {
			
			let subtitleLabel:BF_Label = .init(subtitle)
			subtitleLabel.textAlignment = .center
			stackView.addArrangedSubview(subtitleLabel)
		}
		
		stackView.addArrangedSubview(monstersStackView)
		
		return stackView
	}
	
	private func createMonstersStackView() -> UIStackView {
		
		let stackView:UIStackView = .init()
		stackView.axis = .horizontal
		stackView.spacing = 1.5*UI.Margins
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.layoutMargins = .init(horizontal: UI.Margins)
		stackView.snp.makeConstraints { make in
			make.height.equalTo(9.5*UI.Margins)
		}
		return stackView
	}
}
