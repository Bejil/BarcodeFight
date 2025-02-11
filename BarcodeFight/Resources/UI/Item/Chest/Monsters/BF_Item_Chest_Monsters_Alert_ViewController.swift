//
//  BF_Item_Chest_Monsters_Alert_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 11/06/2024.
//

import Foundation
import UIKit

public class BF_Item_Chest_Monsters_Alert_ViewController : BF_Alert_ViewController {
	
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
					
					var monsters: [BF_Monster] = [.init(),.init(),.init()]
					monsters.append(Bool.random(probability: 0.5) ? .init(rank: .UR) : .init())
					monsters.append(Bool.random(probability: 0.15) ? .init(rank: .LR) : .init())
					monsters.forEach({
						
						$0.status.hp = $0.stats.hp
						$0.status.mp = $0.stats.mp
					})
					monsters = monsters.sort(.Rank).reversed()
					
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
							
							self?.close({
								
								let viewController:BF_Item_Chest_Monsters_ViewController = .init()
								viewController.monsters = monsters
								UI.MainController.present(BF_NavigationController(rootViewController: viewController), animated: true)
							})
						}
					}
				}
			}
			
			cancelButton = addCancelButton()
			
			super.present(as: style, completion)
		}
	}
}

extension BF_Item_Chest_Monsters_Alert_ViewController {
	
	public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		super.scrollViewDidScroll(scrollView)
		
		if let stackView = scrollView.subviews.first as? UIStackView {
			
			let page = Int(max(0.0, round(scrollView.contentOffset.x / scrollView.bounds.width)))
			
			UIView.animate {
				
				for i in 0..<stackView.arrangedSubviews.count {
					
					stackView.arrangedSubviews[i].transform = i == page ? .identity : .init(scaleX: 0.65, y: 0.65)
					stackView.arrangedSubviews[i].alpha = i == page ? 1.0 : 0.15
				}
			}
		}
	}
}
