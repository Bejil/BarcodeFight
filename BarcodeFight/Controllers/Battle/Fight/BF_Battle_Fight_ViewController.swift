//
//  BF_Battle_Fight_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 21/08/2023.
//

import Foundation
import UIKit

public class BF_Battle_Fight_ViewController : BF_ViewController {
	
	public var victoryHandler:(()->Void)?
	public var playerTeam: [BF_Monster]? {
		
		didSet {
			
			fight.creator.monstersIds = playerTeam?.compactMap({ $0.uid })
			
			playerMonstersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
			
			playerTeam?.forEach({
				
				let stackView:BF_Monsters_Min_StackView = .init()
				stackView.particlesView.removeFromSuperview()
				stackView.limitProgressView.isHidden = false
				stackView.monster = $0
				stackView.isLayoutMarginsRelativeArrangement = true
				stackView.layoutMargins = .init(horizontal: 1.5*UI.Margins)
				playerMonstersStackView.addArrangedSubview(stackView)
				stackView.snp.makeConstraints { make in
					make.size.equalTo(self.playerMonstersScrollView)
				}
			})
			
			if oldValue == nil {
				
				playerCurrentMonster = playerTeam?.first
				scrollToCurrentPlayerMonster()
			}
		}
	}
	public var playerCurrentMonster:BF_Monster? {
		
		didSet {
			
			UIView.animate {
				
				(self.playerMonstersStackView.arrangedSubviews as? [BF_Monsters_Min_StackView])?.forEach({
					
					let isCurrent = $0.monster == self.playerCurrentMonster
					
					$0.alpha = !isCurrent ? 0.1 : 1.0
					$0.transform = isCurrent ? .identity : .init(scaleX: 0.75, y: 0.75)
				})
			}
			
			isPlayerTurn = { isPlayerTurn }()
			updateBackgroundGradient()
		}
	}
	public var enemyUser:BF_User? {
		
		didSet {
			
			fight.opponent.displayName = enemyUser?.displayName
			fight.opponent.userId = enemyUser?.uid
			
			enemyUserStackView.user = enemyUser
			enemyUserStackView.alpha = enemyUser == nil ? 0.0 : 1.0
		}
	}
	public var enemyTeam: [BF_Monster]? {
		
		didSet {
			
			fight.opponent.monstersIds = enemyTeam?.compactMap({ $0.uid })
			
			enemyMonstersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
			
			enemyTeam?.forEach({
				
				let stackView:BF_Monsters_Min_StackView = .init()
				stackView.particlesView.removeFromSuperview()
				stackView.limitProgressView.isHidden = false
				stackView.monster = $0
				stackView.isLayoutMarginsRelativeArrangement = true
				stackView.layoutMargins = .init(horizontal: 1.5*UI.Margins)
				enemyMonstersStackView.addArrangedSubview(stackView)
				stackView.snp.makeConstraints { make in
					make.size.equalTo(self.enemyMonstersScrollView)
				}
			})
			
			if oldValue == nil {
				
				enemyCurrentMonster = enemyTeam?.first
				scrollToCurrentEnemyMonster()
			}
		}
	}
	public var enemyCurrentMonster:BF_Monster? {
		
		didSet {
			
			UIView.animate {
				
				(self.enemyMonstersStackView.arrangedSubviews as? [BF_Monsters_Min_StackView])?.forEach({
					
					let isCurrent = $0.monster == self.enemyCurrentMonster
					
					$0.alpha = !isCurrent ? 0.1 : 1.0
					$0.transform = isCurrent ? .identity : .init(scaleX: 0.75, y: 0.75)
				})
			}
			
			updateBackgroundGradient()
		}
	}
	private lazy var playerMonstersParticulesView:BF_Monsters_Particules_View = .init()
	private lazy var playerStackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.alignment = .bottom
		$0.spacing = UI.Margins
		
		let bottomButtonsStackView:UIStackView = .init(arrangedSubviews: [playerNormalAttackButton,playerMagicalAttackButton])
		bottomButtonsStackView.axis = .horizontal
		bottomButtonsStackView.alignment = .center
		bottomButtonsStackView.spacing = UI.Margins
		
		let topButtonsStackView:UIStackView = .init(arrangedSubviews: [playerLimitButton,playerObjectButton])
		topButtonsStackView.axis = .horizontal
		topButtonsStackView.alignment = .center
		topButtonsStackView.spacing = UI.Margins
		
		let buttonsStackView:UIStackView = .init(arrangedSubviews: [topButtonsStackView,bottomButtonsStackView])
		buttonsStackView.axis = .vertical
		buttonsStackView.alignment = .trailing
		buttonsStackView.spacing = UI.Margins
		$0.addArrangedSubview(buttonsStackView)
		
		return $0
		
	}(UIStackView(arrangedSubviews: [playerMonstersScrollView]))
	public lazy var playerMonstersScrollView:UIScrollView = {
		
		$0.delegate = self
		$0.clipsToBounds = false
		$0.isPagingEnabled = true
		$0.showsHorizontalScrollIndicator = false
		$0.addSubview(playerMonstersStackView)
		playerMonstersStackView.snp.makeConstraints { make in
			make.edges.height.equalToSuperview()
		}
		return $0
		
	}(UIScrollView())
	public lazy var playerMonstersStackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.alignment = .fill
		return $0
		
	}(UIStackView())
	private lazy var playerNormalAttackButton:BF_Menu_Button = {
		
		let size = 4.5*UI.Margins
		$0.snp.remakeConstraints { make in
			make.size.equalTo(size)
		}
		$0.isEnabled = false
		$0.backgroundView.backgroundColor = Colors.Button.Secondary.Background
		$0.iconImageView.image = UIImage(named: "battle_icon")
		return $0
		
	}(BF_Menu_Button() { [weak self] _ in
		
		self?.playerAttacks(withMagic:false, isLimit: false, movement:true)
	})
	private lazy var playerMagicalAttackButton:BF_Menu_Button = {
		
		let size = 4.5*UI.Margins
		$0.snp.remakeConstraints { make in
			make.size.equalTo(size)
		}
		$0.isEnabled = false
		$0.backgroundView.backgroundColor = Colors.Button.Secondary.Background
		$0.iconImageView.image = UIImage(named: "magic_icon")
		return $0
		
	}(BF_Menu_Button() { [weak self] _ in
		
		self?.playerAttacks(withMagic:true, isLimit: false, movement:true)
	})
	private lazy var playerObjectButton:BF_Menu_Button = {
		
		let size = 4.5*UI.Margins
		$0.snp.remakeConstraints { make in
			make.size.equalTo(size)
		}
		$0.isEnabled = false
		$0.backgroundView.backgroundColor = Colors.Button.Primary.Background
		$0.iconImageView.image = UIImage(named: "items_icon")
		return $0
		
	}(BF_Menu_Button() { [weak self] _ in
		
		let alertController:BF_Items_Alert_ViewController = .init()
		alertController.monster = self?.playerCurrentMonster
		alertController.completion = { [weak self] item in
			
			if let item, let index = BF_User.current?.items.firstIndex(of: item) {
				
				UIApplication.feedBack(.On)
				
				if item.uid == Items.Potions.Hp {
					
					self?.playerCurrentMonster?.status.hp = self?.playerCurrentMonster?.stats.hp ?? 0
				}
				else if item.uid == Items.Potions.Mp {
					
					self?.playerCurrentMonster?.status.mp = self?.playerCurrentMonster?.stats.mp ?? 0
				}
				else if item.uid == Items.Potions.Revive {
					
					self?.playerCurrentMonster?.status.hp = Int(0.25 * Double((self?.playerCurrentMonster?.stats.hp ?? 0)))
				}
				
				BF_User.current?.items.remove(at: index)
				
				BF_Alert_ViewController.presentLoading() { [weak self] alertController in
					
					BF_User.current?.update({ [weak self] error in
						
						alertController?.close { [weak self] in
							
							if let error = error {
								
								BF_Alert_ViewController.present(error)
							}
							else {
								
								(self?.playerMonstersStackView.arrangedSubviews as? [BF_Monsters_Min_StackView])?.first(where: { $0.monster == self?.playerCurrentMonster })?.monster = self?.playerCurrentMonster
								
								UIApplication.feedBack(.Success)
								BF_Audio.shared.playSuccess()
								
								self?.isPlayerTurn = false
								self?.enemyTurn()
							}
						}
					})
				}
			}
		}
		alertController.present(as: .Sheet)
	})
	private lazy var playerLimitButton:BF_Menu_Button = {
		
		let size = 4.5*UI.Margins
		$0.snp.remakeConstraints { make in
			make.size.equalTo(size)
		}
		$0.backgroundView.backgroundColor = Colors.Button.Secondary.Background
		$0.iconImageView.image = UIImage(named: "qte_icon")
		
		limitButtonTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
			
			self?.playerLimitButton.pulse(Colors.Button.Secondary.Background)
		})
		
		return $0
		
	}(BF_Menu_Button(){ _ in
		
		let viewController:BF_Battle_Fight_QTE_ViewController = .init()
		viewController.completionHandler = { [weak self] in
			
			if let monsterView = (self?.playerMonstersStackView.arrangedSubviews as? [BF_Monsters_Min_StackView])?.first(where: { $0.monster == self?.playerCurrentMonster }) {
				
				monsterView.limitProgressView.progress = 0.0
				
				self?.enemyTurn()
			}
		}
		viewController.hitHandler = { [weak self] in
			
			UIApplication.feedBack(.On)
			self?.playerAttacks(withMagic:false, isLimit: true, movement:true)
		}
		UI.MainController.present(viewController, animated: true)
	})
	private var limitButtonTimer:Timer?
	private lazy var enemyStackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.alignment = .top
		$0.spacing = UI.Margins
		return $0
		
	}(UIStackView(arrangedSubviews: [enemyUserStackView,enemyMonstersScrollView]))
	public lazy var enemyUserStackView:BF_User_Opponent_StackView = {
		
		$0.fightsStackView.isHidden = true
		$0.alpha = 0.0
		return $0
		
	}(BF_User_Opponent_StackView())
	private lazy var enemyMonstersParticulesView:BF_Monsters_Particules_View = .init()
	public lazy var enemyMonstersScrollView:UIScrollView = {
		
		$0.layer.zPosition = enemyUserStackView.layer.zPosition - 1
		$0.isScrollEnabled = false
		$0.delegate = self
		$0.clipsToBounds = false
		$0.isPagingEnabled = true
		$0.showsHorizontalScrollIndicator = false
		$0.addSubview(enemyMonstersStackView)
		enemyMonstersStackView.snp.makeConstraints { make in
			make.edges.height.equalToSuperview()
		}
		return $0
		
	}(UIScrollView())
	public lazy var enemyMonstersStackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.alignment = .fill
		$0.addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] _ in
			
			UIApplication.feedBack(.On)
			self?.playerAttacks(withMagic:false, isLimit: false, movement:true)
		}))
		$0.isUserInteractionEnabled = false
		return $0
		
	}(UIStackView())
	public var isPause:Bool = false
	public var isPlayerTurn:Bool = Bool.random() {
		
		didSet {
			
			playerMonstersScrollView.isScrollEnabled = isPlayerTurn
			enemyMonstersStackView.isUserInteractionEnabled = isPlayerTurn && !(playerCurrentMonster?.isDead ?? false) && !(enemyTeam?.allSatisfy({ $0.isDead }) ?? false || playerTeam?.allSatisfy({ $0.isDead }) ?? false)
			playerNormalAttackButton.isEnabled = isPlayerTurn && !(playerCurrentMonster?.isDead ?? false) && !(enemyTeam?.allSatisfy({ $0.isDead }) ?? false || playerTeam?.allSatisfy({ $0.isDead }) ?? false)
			playerMagicalAttackButton.isEnabled = playerNormalAttackButton.isEnabled && playerCurrentMonster?.status.mp ?? 0 > 0
			playerObjectButton.isEnabled = isPlayerTurn
			
			if let monsterView = (playerMonstersStackView.arrangedSubviews as? [BF_Monsters_Min_StackView])?.first(where: { $0.monster == playerCurrentMonster }), monsterView.limitProgressView.progress == 1.0 {
				
				playerLimitButton.isHidden = false
				
				let viewController:BF_Tutorial_ViewController = .init()
				viewController.key = .battleLimitTutorial
				viewController.items = [
					BF_Tutorial_ViewController.Item(sourceView: playerLimitButton,
													title: String(key: "tutorial.battle.6.title"),
													subtitle: String(key: "tutorial.battle.6.subtitle"),
													button: String(key: "tutorial.battle.6.button"))
				]
				viewController.present()
			}
			else {
				
				playerLimitButton.isHidden = true
			}
		}
	}
	private lazy var backgroundGradient:CAGradientLayer = {
		
		$0.locations = [0.0,1.0]
		$0.startPoint = .init(x: 0.6, y: 0.0)
		$0.endPoint = .init(x: 0.4, y: 1.0)
		return $0
		
	}(CAGradientLayer())
	public var items:[BF_Item]?
	public var experienceVictory:Int {
		
		return 0
	}
	public var experienceDefeat:Int {
		
		return 0
	}
	public var experienceDropout:Int {
		
		return 0
	}
	private var fight:BF_Fight = .init()
	private lazy var soundButton:BF_Button = {
		
		$0.style = .transparent
		$0.isText = true
		$0.image = UIImage(named: "settings_icon")
		$0.titleFont = Fonts.Navigation.Button
		$0.configuration?.contentInsets = .zero
		$0.configuration?.imagePadding = UI.Margins/2
		$0.showsMenuAsPrimaryAction = true
		$0.menu = soundMenu
		return $0
		
	}(BF_Button(String(key: "fights.audio.button")))
	private var soundMenu:UIMenu {
		
		let isSoundsEnabled = BF_User.current?.isSoundsEnabled ?? true
		let isMusicEnabled = BF_User.current?.isMusicEnabled ?? true
		
		return .init(children: [
			
			UIAction(title: String(key: "account.infos.audio.sounds"), subtitle: String(key: isSoundsEnabled ? "account.infos.audio.sounds.on" : "account.infos.audio.sounds.off"), image: UIImage(systemName: isSoundsEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"), handler: { [weak self] _ in
				
				BF_User.current?.isSoundsEnabled = !isSoundsEnabled
				BF_User.current?.update { [weak self] error in
					
					if let error {
						
						BF_Alert_ViewController.present(error)
					}
					else {
						
						self?.soundButton.menu = self?.soundMenu
					}
				}
			}),
			UIAction(title: String(key: "account.infos.audio.musics"), subtitle: String(key: isMusicEnabled ? "account.infos.audio.musics.on" : "account.infos.audio.musics.off"), image: UIImage(systemName: isMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"), handler: { [weak self] _ in
				
				BF_User.current?.isMusicEnabled = !isMusicEnabled
				BF_User.current?.update { [weak self] error in
					
					if let error {
						
						BF_Alert_ViewController.present(error)
					}
					else {
						
						!isMusicEnabled ? BF_Audio.shared.playMain() : BF_Audio.shared.stop()
						self?.soundButton.menu = self?.soundMenu
					}
				}
			})
		])
	}
	private lazy var firstCloudsScrollView:UIScrollView = {
		
		$0.isUserInteractionEnabled = false
		$0.clipsToBounds = false
		return $0
		
	}(UIScrollView())
	private lazy var secondCloudsScrollView:UIScrollView = {
		
		$0.isUserInteractionEnabled = false
		$0.clipsToBounds = false
		return $0
		
	}(UIScrollView())
	private var originalMonsterViewPosition:CGPoint?
	
	deinit {
		
		limitButtonTimer?.invalidate()
		limitButtonTimer = nil
	}
	
	public override func loadView() {
		
		super.loadView()
		
		BF_Audio.shared.playBattle()
		
		overrideUserInterfaceStyle = .light
		
		isModal = true
		
		view.layer.addSublayer(backgroundGradient)
		
		let backgroundImageView:UIImageView = .init(image: UIImage(named: "background"))
		backgroundImageView.contentMode = .scaleAspectFill
		backgroundImageView.alpha = 0.35
		view.addSubview(backgroundImageView)
		backgroundImageView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let versusImageView:UIImageView = .init(image: UIImage(named: "versus"))
		versusImageView.contentMode = .scaleAspectFit
		versusImageView.alpha = 0.5
		view.addSubview(versusImageView)
		versusImageView.snp.makeConstraints { make in
			make.size.equalToSuperview().multipliedBy(0.75)
			make.center.equalToSuperview()
		}
		
		view.addSubview(firstCloudsScrollView)
		firstCloudsScrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		firstCloudsScrollView.layoutIfNeeded()
		var image = UIImage(named: "clouds")?.resize(firstCloudsScrollView.frame.size.width)
		firstCloudsScrollView.backgroundColor = UIColor(patternImage: image!)
		
		view.addSubview(secondCloudsScrollView)
		secondCloudsScrollView.snp.makeConstraints { make in
			make.width.top.bottom.equalToSuperview()
			make.right.equalTo(view.snp.left)
		}
		secondCloudsScrollView.layoutIfNeeded()
		image = UIImage(named: "clouds")?.resize(secondCloudsScrollView.frame.size.width)
		secondCloudsScrollView.backgroundColor = UIColor(patternImage: image!)
		
		view.addSubview(enemyMonstersParticulesView)
		view.addSubview(playerMonstersParticulesView)
		
		let stackView:UIStackView = .init(arrangedSubviews: [enemyStackView,.init(),playerStackView])
		stackView.axis = .vertical
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide)
			make.right.bottom.left.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		enemyMonstersParticulesView.snp.makeConstraints { make in
			make.size.equalToSuperview().multipliedBy(1.5)
			make.center.equalTo(enemyMonstersScrollView)
		}
		
		playerMonstersParticulesView.snp.makeConstraints { make in
			make.size.equalToSuperview().multipliedBy(1.5)
			make.center.equalTo(playerMonstersScrollView)
		}
		
		enemyUserStackView.snp.makeConstraints { make in
			make.width.equalTo(self.view.snp.width).multipliedBy(0.5)
		}
		
		enemyMonstersScrollView.snp.makeConstraints { make in
			make.height.equalTo(self.view.snp.height).multipliedBy(0.2)
		}
		
		playerMonstersScrollView.snp.makeConstraints { make in
			make.height.equalTo(self.view.snp.height).multipliedBy(0.3)
		}
		
		let tutorialButton:BF_Button = .init(String(key: "fights.tutorial.button")) { [weak self] _ in
			
			self?.showTutorial(true,nil)
		}
		tutorialButton.style = .transparent
		tutorialButton.isText = true
		tutorialButton.image = UIImage(named: "help_icon")
		tutorialButton.titleFont = Fonts.Navigation.Button
		tutorialButton.configuration?.contentInsets = .zero
		tutorialButton.configuration?.imagePadding = UI.Margins/2
		
		navigationItem.rightBarButtonItems = [.init(customView: tutorialButton), .init(customView: soundButton)]
		
		UIApplication.wait { [weak self] in
			
			if let weakSelf = self {
				
				UIView.animate(withDuration: 30.0, delay: 0.0, options: [.repeat, .curveEaseInOut], animations: {
					
					weakSelf.firstCloudsScrollView.frame = weakSelf.firstCloudsScrollView.frame.offsetBy(dx: -1 * weakSelf.firstCloudsScrollView.frame.size.width, dy: 0.0)
					weakSelf.secondCloudsScrollView.frame = weakSelf.secondCloudsScrollView.frame.offsetBy(dx: -1 * weakSelf.secondCloudsScrollView.frame.size.width, dy: 0.0)
					
				}, completion: nil)
			}
		}
		
		let panGestureRecognizer:UIPanGestureRecognizer = .init(block: { [weak self] gestureRecognizer in
			
			let currentPoint = gestureRecognizer.location(in: self?.view)
			
			let monsterView = (self?.playerMonstersStackView.arrangedSubviews as? [BF_Monsters_Min_StackView])?.first(where: {
				
				let subviewPoint = self?.view.convert(currentPoint, to: $0)
				return $0.monster == self?.playerCurrentMonster && $0.bounds.contains(subviewPoint ?? .zero)
			})
			
			if !(monsterView?.monster?.isDead ?? true) {
				
				if gestureRecognizer.state == .began {
					
					self?.originalMonsterViewPosition = monsterView?.center
				}
				else if gestureRecognizer.state == .changed {
					
					if let translation = (gestureRecognizer as? UIPanGestureRecognizer)?.translation(in: self?.view) {
						
						monsterView?.center = CGPoint(x: (monsterView?.center.x ?? 0.0) + translation.x, y: (monsterView?.center.y ?? 0.0) + translation.y)
						(gestureRecognizer as? UIPanGestureRecognizer)?.setTranslation(.zero, in: self?.view)
						
						if let enemyMonsterView = (self?.enemyMonstersStackView.arrangedSubviews as? [BF_Monsters_Min_StackView])?.first(where: { $0.monster == self?.enemyCurrentMonster }),
						   let monsterFrameInSuperview = monsterView?.convert(monsterView?.bounds ?? .zero, to: self?.view) {
							
							let enemyFrameInSuperview = enemyMonsterView.convert(enemyMonsterView.bounds, to: self?.view)
							
							let divider = 4.5
							
							let halvedMonsterFrame = CGRect(
								x: monsterFrameInSuperview.origin.x+(monsterFrameInSuperview.size.width/(2*divider)),
								y: monsterFrameInSuperview.origin.y+(monsterFrameInSuperview.size.height/(2*divider)),
								width: monsterFrameInSuperview.size.width/divider,
								height: monsterFrameInSuperview.size.height/divider
							)
							
							let halvedEnemyFrame = CGRect(
								x: enemyFrameInSuperview.origin.x+(enemyFrameInSuperview.size.width/(2*divider)),
								y: enemyFrameInSuperview.origin.y+(enemyFrameInSuperview.size.height/(2*divider)),
								width: enemyFrameInSuperview.size.width/divider,
								height: enemyFrameInSuperview.size.height/divider
							)
							
							if halvedMonsterFrame.intersects(halvedEnemyFrame) {
								
								UIApplication.feedBack(.On)
								self?.playerAttacks(withMagic:false, isLimit: false, movement:false)
								
								gestureRecognizer.isEnabled = false
								gestureRecognizer.isEnabled = true
							}
						}
					}
				}
				else {
					
					UIApplication.wait(0.1) { [weak self] in
						
						gestureRecognizer.delegate = nil
						
						UIView.animate(0.3, { [weak self] in
							
							if let monsterView = monsterView, let index = self?.playerMonstersStackView.arrangedSubviews.firstIndex(of: monsterView) {
								
								monsterView.frame.origin.x = CGFloat(index) * monsterView.frame.size.width
								monsterView.frame.origin.y = 0
							}
							
						}, { [weak self] in
							
							self?.originalMonsterViewPosition = nil
							gestureRecognizer.delegate = self
						})
					}
				}
			}
		})
		panGestureRecognizer.delegate = self
		view.addGestureRecognizer(panGestureRecognizer)
	}
	
	public override func viewDidLayoutSubviews() {
		
		super.viewDidLayoutSubviews()
		
		backgroundGradient.frame = view.frame
	}
	
	public override func dismiss(_ completion: (() -> Void)? = nil) {
		
		BF_Audio.shared.playMain()
		
		super.dismiss {
			
			completion?()
			
			BF_Ads.shared.presentInterstitial(BF_Ads.Identifiers.FullScreen.AfterFight)
		}
	}
	
	public override func close() {
		
		isPause = true
		
		let alertController:BF_Alert_ViewController = .init()
		alertController.title = String(key: "fights.battle.dropout.alert.title")
		alertController.add(UIImage(named: "dropout_icon"))
		alertController.add(String(key: "fights.battle.dropout.alert.content.0"))
		alertController.add(String(key: "fights.battle.dropout.alert.content.1"))
		let button = alertController.addButton(title: String(key: "fights.battle.dropout.alert.button")) { [weak self] _ in
			
			alertController.close { [weak self] in
				
				self?.finishBattle(withState: .Dropout)
			}
		}
		button.isDelete = true
		alertController.addCancelButton()
		alertController.dismissHandler = { [weak self] in
			
			self?.isPause = false
		}
		alertController.present()
	}
	
	public func showTutorial(_ force:Bool, _ completion:(()->Void)?) {
		
		let sourceViews = [
			nil,
			(playerMonstersStackView.arrangedSubviews as? [BF_Monsters_Min_StackView])?.first(where: { $0.monster == playerCurrentMonster }),
			(enemyMonstersStackView.arrangedSubviews as? [BF_Monsters_Min_StackView])?.first(where: { $0.monster == enemyCurrentMonster }),
			playerNormalAttackButton,
			playerMagicalAttackButton,
			playerObjectButton
		]
		
		let viewController:BF_Tutorial_ViewController = .init()
		viewController.key = .battleTutorial
		viewController.force = force
		viewController.items = sourceViews.compactMap({
			
			if let index = sourceViews.firstIndex(of: $0) {
				
				return BF_Tutorial_ViewController.Item(sourceView: $0,
												title: String(key: "tutorial.battle.\(index).title"),
												subtitle: String(key: "tutorial.battle.\(index).subtitle"),
												button: String(key: "tutorial.battle.\(index).button"))
			}
			
			return nil
		})
		viewController.completion = completion
		viewController.present()
	}
	
	public func startToss() {
		
		let viewController:BF_Toss_ViewController = .init()
		viewController.isAuto = true
		viewController.endState = isPlayerTurn
		viewController.completion = { [weak self] in
			
			self?.showDimView(String(key: self?.isPlayerTurn ?? false ? "fights.battle.toss.player" : "fights.battle.toss.enemy")) { [weak self] in
				
				let isPlayerTurn = self?.isPlayerTurn ?? false
				
				self?.playerNormalAttackButton.isEnabled = isPlayerTurn && !(self?.playerCurrentMonster?.isDead ?? false)
				self?.playerMagicalAttackButton.isEnabled = self?.playerNormalAttackButton.isEnabled ?? false && self?.playerCurrentMonster?.status.mp ?? 0 > 0
				self?.playerObjectButton.isEnabled = isPlayerTurn
				
				isPlayerTurn ? self?.playerTurn() : self?.enemyTurn()
			}
		}
		UI.MainController.present(viewController, animated: true)
	}
	
	public func playerTurn() {
		
		if enemyTeam?.allSatisfy({ $0.isDead }) ?? false || playerTeam?.allSatisfy({ $0.isDead }) ?? false {
			
			finishBattle(withState: enemyTeam?.allSatisfy({ $0.isDead }) ?? false ? .Victory : .Defeat)
		}
		else if !isPause {
			
			isPlayerTurn = true
		}
	}
	
	private func playerAttacks(withMagic:Bool, isLimit:Bool, movement:Bool) {
		
		attack(attacker: playerCurrentMonster, target: enemyCurrentMonster, isMagical: withMagic, movement:movement) { [weak self] in
			
			if self?.enemyCurrentMonster?.isDead ?? false {
				
				UIApplication.wait(1.0) { [weak self] in
					
					self?.enemyCurrentMonster = self?.enemyTeam?.first(where: { !$0.isDead })
					self?.scrollToCurrentEnemyMonster()
					
					if !isLimit {
						
						self?.isPlayerTurn = false
						self?.enemyTurn()
					}
				}
			}
			else {
				
				if !isLimit {
					
					UIApplication.wait { [weak self] in
						
						self?.isPlayerTurn = false
						self?.enemyTurn()
					}
				}
			}
		}
	}
	
	public func enemyTurn() {
		
		if enemyTeam?.allSatisfy({ $0.isDead }) ?? false || playerTeam?.allSatisfy({ $0.isDead }) ?? false {
			
			finishBattle(withState: enemyTeam?.allSatisfy({ $0.isDead }) ?? false ? .Victory : .Defeat)
		}
		else if !isPause {
			
			UIApplication.wait { [weak self] in
				
				self?.attack(attacker: self?.enemyCurrentMonster, target: self?.playerCurrentMonster, isMagical: Bool.random() && self?.enemyCurrentMonster?.status.mp ?? 0 > 0, movement:true) { [weak self] in
					
					if self?.playerCurrentMonster?.isDead ?? false {
						
						UIApplication.wait(1.0) { [weak self] in
							
							self?.playerCurrentMonster = self?.playerTeam?.first(where: { !$0.isDead })
							self?.scrollToCurrentPlayerMonster()
							self?.playerTurn()
						}
					}
					else {
						
						UIApplication.wait { [weak self] in
							
							self?.playerTurn()
						}
					}
				}
			}
		}
	}
	
	private func attack(attacker: BF_Monster?, target: BF_Monster?, isMagical:Bool, movement:Bool, completion:(()->Void)?) {
		
		let attackerLuk = Double(attacker?.stats.luk ?? Int(BF_Monster.Stats.range.lowerBound))
		let attackerLukPercent = attackerLuk/BF_Monster.Stats.range.upperBound
		let attackerAtk = Double(attacker?.stats.atk ?? Int(BF_Monster.Stats.range.lowerBound))
		
		let targetLuk = Double(target?.stats.luk ?? Int(BF_Monster.Stats.range.lowerBound))
		let targetLukPercent = targetLuk/BF_Monster.Stats.range.upperBound
		let targetDef = Double(target?.stats.def ?? Int(BF_Monster.Stats.range.lowerBound))
		
		let isCritical = Bool.random(probability: Double(attackerLukPercent/10))
		let isBlocked = Bool.random(probability: Double(targetLukPercent/20))
		let isDodge = !isBlocked && Bool.random(probability: Double(targetLukPercent/20))
		
		let isElementStrong = attacker?.element ?? .Neutral > target?.element ?? .Neutral
		let isElementWeak = attacker?.element ?? .Neutral < target?.element ?? .Neutral
		var elementVariation = isElementStrong ? 1.2 : isElementWeak ? 0.8 : 1.0
		
		if isMagical {
			
			elementVariation *= 1.25
		}
		
		let hpToRemove = isBlocked || isDodge ? 0.0 : (((attackerAtk * (attackerAtk/(attackerAtk + targetDef))) * (isCritical ? 1.5 : 1.0)) * Double.random(in: 0.9...1.1) * elementVariation/2.0)
		
		if isMagical {
			
			attacker?.status.mp = max(0,(attacker?.status.mp ?? 0) - Int(hpToRemove))
		}
		
		target?.status.hp =  max(0,(target?.status.hp ?? 0) - Int(hpToRemove))
		
		playerTeam?.first(where: { $0 == attacker })?.status = attacker?.status ?? .init()
		playerTeam?.first(where: { $0 == target })?.status = target?.status ?? .init()
		
		enemyTeam?.first(where: { $0 == attacker })?.status = attacker?.status ?? .init()
		enemyTeam?.first(where: { $0 == target })?.status = target?.status ?? .init()
		
		moveMonsters(attacker: attacker, target: target, isMagical: isMagical, isDodge: isDodge, isCritical: isCritical, hpToRemove:hpToRemove, isBlocked: isBlocked, movement: movement, completion: completion)
	}
	
	public func moveMonsters(attacker: BF_Monster?, target: BF_Monster?, isMagical:Bool, isDodge:Bool, isCritical:Bool, hpToRemove:Double, isBlocked:Bool, movement:Bool, completion:(()->Void)?) {
		
		if let playerMonstersViews = playerMonstersStackView.arrangedSubviews as? [BF_Monsters_Min_StackView],
		   let enemyMonstersViews = enemyMonstersStackView.arrangedSubviews as? [BF_Monsters_Min_StackView],
		   let attackerView = (playerMonstersViews+enemyMonstersViews).first(where: { $0.monster == attacker }),
		   let targetView = (playerMonstersViews+enemyMonstersViews).first(where: { $0.monster == target }) {
			
			targetView.layer.zPosition = attackerView.layer.zPosition - 1
			
			let initialAttackerCenter = attackerView.center
			let targetCenter = targetView.superview?.convert(targetView.center, to: attackerView.superview) ?? initialAttackerCenter
			
			UIView.animate(movement ? 0.3 : 0.0) {
				
				if movement {
					
					attackerView.center = targetCenter
				}
				
			} _: {
				
				let attackerIsPlayer = playerMonstersViews.contains(where: { $0.monster == attacker })
				
				attackerView.monster = attacker
				targetView.monster = target
				
				if !(targetView.monster?.isDead ?? false) {
					
					let maxHP = Float(target?.stats.hp ?? 1)
					let currentHP = Float(target?.status.hp ?? 1)
					let hpPercentage = Float(hpToRemove) / maxHP
					let defenseFactor = Float(target?.stats.def ?? 0) / 100.0
					let luckFactor = 1.0 + (Float(target?.stats.luk ?? 0) / 100.0) // Reduced the luck factor impact
					let remainingHPFactor = 1.0 + (((maxHP - currentHP) / maxHP) / 15.0) // Increased the divisor to slow the impact
					
					let scalingFactor: Float = 15.0 // Increased the scaling factor to slow progress
					let limitPercentage = (hpPercentage * defenseFactor * luckFactor * remainingHPFactor) / scalingFactor
					
					targetView.limitProgressView.progress = min(1.0, targetView.limitProgressView.progress + limitPercentage)
				}
				else {
					
					targetView.limitProgressView.progress = 0.0
				}
				
				attackerIsPlayer ? targetView.flip() : attackerView.flip()
				
				attackerView.pulse(isMagical ? attacker?.element.color ?? Colors.Primary : Colors.Primary)
				
				if !isDodge {
					
					let isElementStrong = attacker?.element ?? .Neutral > target?.element ?? .Neutral
					targetView.pulse(isMagical || isElementStrong ? attacker?.element.color ?? Colors.Content.Text : Colors.Content.Text)
				}
				
				let infoLabel:BF_Label = .init()
				infoLabel.text = String(key: isDodge ? "fights.battle.dodge" : isBlocked ? "fights.battle.blocked" : isCritical ? "fights.battle.critical" : "\(Int(hpToRemove))")
				infoLabel.font = Fonts.Content.Title.H3
				infoLabel.textAlignment = .center
				infoLabel.adjustsFontSizeToFitWidth = true
				infoLabel.minimumScaleFactor = 0.25
				infoLabel.textColor = .white
				infoLabel.layer.shadowColor = UIColor.black.cgColor
				infoLabel.layer.shadowRadius = 2
				infoLabel.layer.shadowOffset = .init(width: 1, height: 1)
				infoLabel.layer.shadowOpacity = 0.75
				infoLabel.transform = .init(scaleX: 1.75, y: 1.75)
				infoLabel.layer.masksToBounds = false
				targetView.addSubview(infoLabel)
				infoLabel.snp.makeConstraints { make in
					make.centerX.equalToSuperview()
					make.top.equalToSuperview().inset(UI.Margins/2)
				}
				
				targetView.layoutIfNeeded()
				
				infoLabel.snp.updateConstraints { make in
					make.top.equalToSuperview().inset(-UI.Margins)
				}
				
				UIView.animate(1,{
					
					infoLabel.transform = .identity
					targetView.layoutIfNeeded()
					
				},{
					
					UIView.animate(0.3) {
						
						infoLabel.transform = .init(scaleX: 1.75, y: 1.75)
						infoLabel.alpha = 0.0
						
					} _: {
						
						infoLabel.removeFromSuperview()
					}
				})
				
				if isDodge {
					
					let dodgeImage = UIImage(named: "dodge_\(Int.random(in: 0...3))")
					
					let dodgeImageView:UIImageView = .init(image: dodgeImage)
					
					if !attackerIsPlayer {
						
						dodgeImageView.image = dodgeImageView.image?.withHorizontallyFlippedOrientation()
					}
					
					dodgeImageView.contentMode = .scaleAspectFit
					targetView.insertSubview(dodgeImageView, at: 0)
					dodgeImageView.snp.makeConstraints { make in
						
						make.size.centerY.equalToSuperview()
						
						if attackerIsPlayer {
							
							make.left.equalTo(targetView.snp.centerX)
						}
						else {
							
							make.right.equalTo(targetView.snp.centerX)
						}
					}
					dodgeImageView.alpha = 0.0
					
					let duration = 0.5
					
					UIView.animate(2.0*duration/3.0) {
						
						dodgeImageView.alpha = Double.random(in: 0.75...1.0)
						
					} _: {
						
						UIView.animate(duration/3.0) {
							
							dodgeImageView.alpha = 0.0
							
						} _: {
							
							dodgeImageView.removeFromSuperview()
						}
					}
					
					UIView.animate(duration) {
						
						dodgeImageView.transform = .init(scaleX: 1.5, y: 1.5).translatedBy(x: (attackerIsPlayer ? 1 : -1) * 2*UI.Margins, y: 0)
						
					} _: {
						
						dodgeImageView.removeFromSuperview()
					}
				}
				else if !isBlocked {
					
					let hitImageView:UIImageView = .init(image: UIImage(named: "hit_\(Int.random(in: 0...16))"))
					hitImageView.contentMode = .scaleAspectFit
					targetView.addSubview(hitImageView)
					hitImageView.snp.makeConstraints { make in
						make.center.size.equalToSuperview()
					}
					hitImageView.transform = .init(scaleX: 0.01, y: 0.01)
					hitImageView.alpha = 0.0
					
					let duration = 0.3
					
					UIView.animate(2.0*duration/3.0) {
						
						hitImageView.alpha = Double.random(in: 0.75...1.0)
						
					} _: {
						
						UIView.animate(duration/3.0) {
							
							hitImageView.alpha = 0.0
						}
					}
					
					UIView.animate(duration) {
						
						hitImageView.transform = .init(scaleX: 2.5, y: 2.5).translatedBy(x: (attackerIsPlayer ? 1 : -1) * 2*UI.Margins, y: -Double.random(in: UI.Margins/2...2*UI.Margins))
						
					} _: {
						
						hitImageView.removeFromSuperview()
					}
				}
				
				UIView.animate(0.1) {
					
					let targetTranslation = (attackerIsPlayer ? 1 : -1)*UI.Margins
					targetView.transform = .init(translationX: 2 * targetTranslation, y: !isDodge ? -targetTranslation : 0)
					
				} _: {
					
					UIView.animate(0.1) {
						
						targetView.transform = .identity
					}
				}
				
				UIView.animate(movement ? 0.3 : 0.0) {
					
					if movement {
						
						attackerView.center = initialAttackerCenter
					}
					
				} _: {
					
					completion?()
				}
				
				if target?.isDead ?? false {
					
					BF_Audio.shared.playDeath()
				}
				
				if isDodge {
					
					BF_Audio.shared.playDodge()
				}
				else if !isBlocked {
					
					BF_Audio.shared.playImpact()
				}
				
				UIApplication.feedBack(isDodge || isBlocked ? .Error : .Success)
			}
		}
	}
	
	public func scrollToCurrentPlayerMonster() {
		
		let index = (playerMonstersStackView.arrangedSubviews as? [BF_Monsters_Min_StackView])?.firstIndex(where: { $0.monster == playerCurrentMonster }) ?? 0
		playerMonstersScrollView.setContentOffset(.init(x: playerMonstersScrollView.frame.size.width * CGFloat(index), y: 0), animated: true)
		isPlayerTurn = { isPlayerTurn }()
	}
	
	public func scrollToCurrentEnemyMonster() {
		
		let index = (enemyMonstersStackView.arrangedSubviews as? [BF_Monsters_Min_StackView])?.firstIndex(where: { $0.monster == enemyCurrentMonster }) ?? 0
		enemyMonstersScrollView.setContentOffset(.init(x: enemyMonstersScrollView.frame.size.width * CGFloat(index), y: 0), animated: true)
	}
	
	private func updateBackgroundGradient() {
		
		backgroundGradient.removeAllAnimations()
		backgroundGradient.colors = [(enemyCurrentMonster?.element.color ?? .clear).cgColor, (playerCurrentMonster?.element.color ?? .clear).cgColor]
		
		let backgroundGradientColorAnimation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
		backgroundGradientColorAnimation.duration = 1.0
		backgroundGradient.add(backgroundGradientColorAnimation, forKey: "backgroundGradientColorAnimation")
		
		playerMonstersParticulesView.monster = playerCurrentMonster
		enemyMonstersParticulesView.monster = enemyCurrentMonster
	}
	
	public func showDimView(_ text:String?, _ endPause:TimeInterval = 0.5, _ completion:(()->Void)? = nil) {
		
		view.isUserInteractionEnabled = false
		
		let dimView:UIView = .init()
		dimView.alpha = 0.0
		view.addSubview(dimView)
		dimView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let dimBackgroundView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .dark))
		dimView.addSubview(dimBackgroundView)
		dimBackgroundView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let dimLabel:BF_Label = .init()
		dimLabel.font = Fonts.Content.Title.H1.withSize(Fonts.Size+30)
		dimLabel.textColor = .white
		dimLabel.text = text
		dimLabel.textAlignment = .center
		dimLabel.alpha = 0.0
		dimLabel.transform = .init(scaleX: 10.0, y: 10.0)
		dimView.addSubview(dimLabel)
		dimLabel.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(2*UI.Margins)
		}
		
		UIView.animate(withDuration: 0.5, animations: {
			
			dimView.alpha = 1.0
			dimLabel.alpha = 1.0
			dimLabel.transform = .identity
			
		}) { _ in
			
			UIApplication.wait(endPause) {
				
				UIView.animate(0.3,{
					
					dimView.alpha = 0.0
					dimLabel.alpha = 0.0
					
				}, {
					
					dimLabel.removeFromSuperview()
					dimView.removeFromSuperview()
					
					self.view.isUserInteractionEnabled = true
					
					completion?()
				})
			}
		}
	}
	
	public func finishBattle(withState state:BF_Fight.State) {
		
		navigationItem.leftBarButtonItem = nil
		navigationItem.rightBarButtonItems = nil
		
		isPause = true
		isPlayerTurn = false
		
		UIView.animate {
			
			self.enemyMonstersParticulesView.alpha = 0.0
			self.enemyStackView.isHidden = true
			self.enemyStackView.alpha = 0.0
			self.enemyStackView.superview?.layoutIfNeeded()
			
			self.playerMonstersParticulesView.alpha = 0.0
			self.playerStackView.isHidden = true
			self.playerStackView.alpha = 0.0
			self.playerStackView.superview?.layoutIfNeeded()
		}
		
		showDimView(String(key: state == .Victory ? "fights.battle.finish.victory" : state == .Dropout ? "fights.battle.finish.dropout" : "fights.battle.finish.defeat"), 3.0) { [weak self] in
			
			self?.rewardAndPenalize(for: state)
		}
	}
	
	public func rewardAndPenalize(for state:BF_Fight.State) {
		
		if state == .Victory {
			
			BF_Alert_ViewController.presentLoading() { [weak self] alertController in
				
				BF_Item.getRewards { [weak self] rewards, error in
					
					alertController?.close { [weak self] in
						
						self?.items = rewards
						
						let alertController:BF_Alert_ViewController = .init()
						alertController.backgroundView.isUserInteractionEnabled = false
						alertController.add(UIImage(named: "victory_icon"))
						alertController.title = String(key: "fights.battle.finish.victory.alert.title")
						alertController.add(String(key: "fights.battle.finish.victory.alert.label.0"))
						alertController.add(String(key: "fights.battle.finish.victory.alert.label.1"))
						
						let itemsTableView:BF_TableView = .init()
						itemsTableView.register(BF_Item_TableViewCell.self, forCellReuseIdentifier: BF_Item_TableViewCell.identifier)
						itemsTableView.delegate = self
						itemsTableView.dataSource = self
						itemsTableView.separatorInset = .zero
						itemsTableView.separatorColor = .white.withAlphaComponent(0.25)
						itemsTableView.isHeightDynamic = true
						itemsTableView.isUserInteractionEnabled = false
						itemsTableView.isHidden = self?.items?.isEmpty ?? true
						alertController.add(itemsTableView)
						
						alertController.addButton(title: String(key: "fights.battle.finish.victory.alert.button")) { [weak self] button in
							
							button?.isLoading = true
							
							self?.reward(BF_User.current, with: self?.playerTeam, and: rewards, { [weak self] error in
								
								button?.isLoading = false
								
								if let error = error {
									
									BF_Alert_ViewController.present(error)
								}
								else {
									
									NotificationCenter.post(.updateAccount)
									NotificationCenter.post(.updateMonsters)
									
									alertController.close { [weak self] in
										
										self?.dismiss({ [weak self] in
											
											self?.victoryHandler?()
										})
									}
								}
							})
						}
						alertController.dismissHandler = {
							
							BF_Confettis.stop()
						}
						alertController.present {
							
							BF_Confettis.start()
						}
					}
				}
			}
		}
		else if state == .Defeat {
			
			let alertController:BF_Alert_ViewController = .init()
			alertController.backgroundView.isUserInteractionEnabled = false
			alertController.add(UIImage(named: "defeat_icon"))
			alertController.title = String(key: "fights.battle.finish.defeat.alert.title")
			alertController.add(String(key: "fights.battle.finish.defeat.alert.label.0"))
			alertController.addButton(title: String(key: "fights.battle.finish.defeat.alert.button")) { [weak self] button in
				
				button?.isLoading = true
				
				self?.penalise(BF_User.current, with: self?.playerTeam, for: state) { [weak self] error in
					
					button?.isLoading = false
					
					if let error = error {
						
						BF_Alert_ViewController.present(error)
					}
					else {
						
						NotificationCenter.post(.updateAccount)
						NotificationCenter.post(.updateMonsters)
						
						alertController.close { [weak self] in
							
							self?.dismiss()
						}
					}
				}
			}
			
			alertController.present()
		}
		else if state == .Dropout {
			
			let alertController:BF_Alert_ViewController = .init()
			alertController.backgroundView.isUserInteractionEnabled = false
			alertController.title = String(key: "fights.battle.finish.dropout.alert.title")
			alertController.add(String(key: "fights.battle.finish.dropout.alert.label.0"))
			alertController.addButton(title: String(key: "fights.battle.finish.dropout.alert.button")) { [weak self] button in
				
				button?.isLoading = true
				
				self?.penalise(BF_User.current, with: self?.playerTeam, for: state) { [weak self] error in
					
					button?.isLoading = false
					
					if let error = error {
						
						BF_Alert_ViewController.present(error)
					}
					else {
						
						NotificationCenter.post(.updateAccount)
						NotificationCenter.post(.updateMonsters)
						
						alertController.close { [weak self] in
							
							self?.dismiss()
						}
					}
				}
			}
			
			alertController.present()
		}
	}
	
	private func reward(_ user:BF_User?, with team:[BF_Monster]?, and items:[BF_Item]?, _ completion:((Error?)->Void)?) {
		
		if user?.id != nil {
			
			fight.state = .Victory
			
			team?.forEach({ monster in
				
				monster.fights.append(fight)
				
				if let index = user?.monsters.firstIndex(of: monster) {
					
					user?.monsters[index] = monster
				}
			})
			
			user?.fights.append(fight)
			
			user?.setRewards(items, { [weak self] error in
				
				user?.updateAndAddExperience(self?.experienceVictory ?? 0, { [weak self] error in
					
					if let error {
						
						user?.experience -= self?.experienceVictory ?? 0
						
						BF_Alert_ViewController.present(error)
					}
					
					completion?(error)
				})
			})
		}
		else {
			
			completion?(nil)
		}
	}
	
	private func penalise(_ user:BF_User?, with team:[BF_Monster]?, for state:BF_Fight.State, _ completion:((Error?)->Void)?) {
		
		if user?.id != nil {
			
			fight.state = state
			
			team?.forEach({ monster in
				
				monster.fights.append(fight)
				
				if let index = user?.monsters.firstIndex(of: monster) {
					
					user?.monsters[index] = monster
				}
			})
			
			user?.fights.append(fight)
			
			user?.updateAndAddExperience(state == .Dropout ? experienceDropout : experienceDefeat, { [weak self] error in
				
				if error != nil {
					
					user?.experience -= state == .Dropout ? self?.experienceDropout ?? 0 : self?.experienceDefeat ?? 0
				}
				
				completion?(error)
			})
		}
		else {
			
			completion?(nil)
		}
	}
}

extension BF_Battle_Fight_ViewController : UIScrollViewDelegate {
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		let page = Int(max(0.0, round(scrollView.contentOffset.x / scrollView.bounds.width)))
		
		if scrollView == playerMonstersScrollView {
			
			playerCurrentMonster = playerTeam?[page]
		}
		else if scrollView == enemyMonstersScrollView {
			
			enemyCurrentMonster = enemyTeam?[page]
		}
	}
}

extension BF_Battle_Fight_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return items?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BF_Item_TableViewCell.identifier, for: indexPath) as! BF_Item_TableViewCell
		cell.item = items?[indexPath.row]
		cell.button.isHidden = true
		return cell
	}
}

extension BF_Battle_Fight_ViewController {
	
	public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		
		return isPlayerTurn
	}
}
