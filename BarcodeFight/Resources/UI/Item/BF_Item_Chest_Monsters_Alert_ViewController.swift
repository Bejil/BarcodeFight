//
//  BF_Item_Chest_Monsters_Alert_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 11/06/2024.
//

import Foundation
import UIKit

public class BF_Item_Chest_Monsters_Alert_ViewController : BF_Alert_ViewController {
	
	private lazy var monstersStackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.alignment = .fill
		return $0
		
	}(UIStackView())
	private lazy var monstersScrollView:UIScrollView = {
		
		$0.delegate = self
		$0.clipsToBounds = false
		$0.isPagingEnabled = true
		$0.showsHorizontalScrollIndicator = false
		$0.addSubview(monstersStackView)
		monstersStackView.snp.makeConstraints { make in
			make.edges.height.equalToSuperview()
		}
		return $0
		
	}(UIScrollView())
	
	public override func present(as style: BF_Alert_ViewController.Style = .Alert, _ completion: (() -> Void)? = nil) {
		
		if let chestItem = BF_User.current?.items.first(where: { $0.uid == Items.ChestMonsters }) {
			
			title = chestItem.name
			
			var imageView:BF_ImageView? = nil
			
			if let picture = chestItem.picture {
				
				imageView = add(UIImage(named: picture))
			}
			
			let descriptionLabel = add(chestItem.description)
			
			var cancelButton:BF_Button? = nil
			
			addButton(title: String(key: "chest.alert.button")) { [weak self] button in
				
				UIView.animate {
					
					self?.titleLabel.isHidden = true
					descriptionLabel.isHidden = true
					button?.isHidden = true
					cancelButton?.isHidden = true
					
					self?.contentStackView.layoutIfNeeded()
				}
				
				button?.isLoading = true
				
				var pulseTimer:Timer? = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
					
					UIApplication.feedBack(.On)
					imageView?.pulse(.clear)
				})
				
				var jiggleTimer:Timer? = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { _ in
					
					imageView?.jiggle()
					self?.containerView.jiggle()
				})
				
				UIApplication.wait(3.0) { [weak self] in
					
					var monsters: [BF_Monster] = []
					
					while true {
						
						monsters = ((0..<5).map { _ in
							
							let monster:BF_Monster = .init()
							monster.status.hp = monster.stats.hp
							monster.status.mp = monster.stats.mp
							return monster
						}).sort(.Rank).reversed()
						
						if monsters.contains(where: { $0.stats.rank == .UR || $0.stats.rank == .LR }) {
							
							break
						}
					}
					
					if let index = BF_User.current?.items.firstIndex(of: chestItem) {
						
						BF_User.current?.items.remove(at: index)
					}
					
					BF_User.current?.update { [weak self] error in
						
						pulseTimer?.invalidate()
						pulseTimer = nil
						
						jiggleTimer?.invalidate()
						jiggleTimer = nil
						
						if let error = error {
							
							self?.close({
								
								BF_Alert_ViewController.present(error)
							})
						}
						else {
							
							UIApplication.feedBack(.Success)
							
							NotificationCenter.post(.updateAccount)
							
							self?.title = String(key: "chest.alert.title")
							
							if let label = self?.add(String(key: "chest.alert.content")) {
								
								self?.contentStackView.setCustomSpacing(2*UI.Margins, after: label)
							}
							
							if let monstersScrollView = self?.monstersScrollView, let monstersStackView = self?.monstersStackView {
								
								let monsterView:UIView = .init()
								monsterView.isHidden = true
								monsterView.addSubview(monstersScrollView)
								monstersScrollView.snp.makeConstraints { make in
									make.top.bottom.centerX.equalToSuperview()
									make.width.equalToSuperview().multipliedBy(0.65)
									make.height.equalTo(250)
								}
								self?.add(monsterView)
								
								monsters.forEach({ monster in
									
									let stackView:BF_Monsters_StackView = .init()
									stackView.monster = monster
									
									let button:BF_Button = .init(String(key: "monsters.add.button")) { [weak self] button in
										
										monster.add({ [weak self] in
											
											UIView.animate {
												
												button?.superview?.alpha = 0.0
												button?.superview?.isHidden = true
												button?.superview?.layoutIfNeeded()
											}
											
											if monstersStackView.arrangedSubviews.allSatisfy({ $0.isHidden }) {
												
												self?.close()
											}
										})
									}
									
									let monsterStackView:UIStackView = .init(arrangedSubviews: [stackView,button])
									monsterStackView.axis = .vertical
									monsterStackView.spacing = UI.Margins
									monstersStackView.addArrangedSubview(monsterStackView)
									monsterStackView.snp.makeConstraints { make in
										make.size.equalTo(monstersScrollView)
									}
								})
								
								monstersScrollView.delegate?.scrollViewDidScroll?(monstersScrollView)
								
								BF_Confettis.start()
								
								let button = self?.addCancelButton()
								button?.isHidden = true
								
								UIView.animate { [weak self] in
									
									self?.titleLabel.isHidden = false
									imageView?.isHidden = true
									monsterView.isHidden = false
									button?.isHidden = false
									
									self?.contentStackView.layoutIfNeeded()
								}
							}
						}
					}
				}
			}
			
			cancelButton = addCancelButton()
			dismissHandler = {
				
				BF_Confettis.stop()
			}
			
			super.present(as: style, completion)
		}
	}
}

extension BF_Item_Chest_Monsters_Alert_ViewController {
	
	public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		super.scrollViewDidScroll(scrollView)
		
		if scrollView == monstersScrollView {
			
			let page = Int(max(0.0, round(scrollView.contentOffset.x / scrollView.bounds.width)))
			
			UIView.animate {
				
				for i in 0..<self.monstersStackView.arrangedSubviews.count {
					
					self.monstersStackView.arrangedSubviews[i].transform = i == page ? .identity : .init(scaleX: 0.65, y: 0.65)
					self.monstersStackView.arrangedSubviews[i].alpha = i == page ? 1.0 : 0.15
				}
			}
		}
	}
}
