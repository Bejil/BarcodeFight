//
//  BF_Monsters_CollectionViewCell.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 09/08/2023.
//

import Foundation
import UIKit

public class BF_Monsters_CollectionViewCell : BF_CollectionViewCell {
	
	public override class var identifier: String {
		
		return "monsterCollectionViewCellIdentifier"
	}
	public var monster:BF_Monster? {
		
		didSet {
			
			stackView.monster = monster
		}
	}
	private lazy var visualEffectView:UIVisualEffectView = {
		
		$0.alpha = 0.15
		return $0
		
	}(UIVisualEffectView(effect: UIBlurEffect.init(style: .regular)))
	private lazy var stackView:BF_Monsters_Min_StackView = {
		
		$0.isUserInteractionEnabled = false
		return $0
		
	}(BF_Monsters_Min_StackView())
	public var menu:UIMenu? {
		
		get{
			
			var children:[UIMenuElement] = .init()
			
			children.append(UIAction(title: String(key: "monsters.object.action"), image: UIImage(systemName: "bag")) { [weak self] _ in
				
				self?.object()
			})
			children.append(UIAction(title: String(key: "monsters.delete.action"), image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
				
				self?.delete()
			})
			
			return .init(children: children)
		}
	}
	public override var isSelected: Bool {
		
		didSet {
			
			UIView.animate(0.15) {
				
				self.visualEffectView.alpha = self.isSelected ? 1.0 : 0.15
			}
		}
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		contentView.layer.cornerRadius = UI.CornerRadius/2
		contentView.clipsToBounds = true
		
		contentView.addSubview(visualEffectView)
		visualEffectView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		contentView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalTo(contentView.safeAreaLayoutGuide).inset(UI.Margins)
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	private func delete() {
		
		BF_Monsters_Delete_Alert_ViewController([monster].compactMap({ $0 })).present()
	}
	
	private func object() {
		
		let alertController:BF_Items_Alert_ViewController = .init()
		alertController.monster = monster
		alertController.completion = { [weak self] item in
			
			if let item, let index = BF_User.current?.items.firstIndex(of: item) {
				
				UIApplication.feedBack(.On)
				
				if item.uid == Items.Potions.Hp {
					
					self?.monster?.status.hp = self?.monster?.stats.hp ?? 0
				}
				else if item.uid == Items.Potions.Mp {
					
					self?.monster?.status.mp = self?.monster?.stats.mp ?? 0
				}
				else if item.uid == Items.Potions.Revive {
					
					self?.monster?.status.hp = Int(0.25 * Double((self?.monster?.stats.hp ?? 0)))
				}
				
				BF_User.current?.items.remove(at: index)
				
				BF_Alert_ViewController.presentLoading() { alertController in
					
					BF_User.current?.update({ error in
						
						alertController?.close {
							
							if let error = error {
								
								BF_Alert_ViewController.present(error)
							}
							else {
								
								NotificationCenter.post(.updateAccount)
								NotificationCenter.post(.updateMonsters)
								
								UIApplication.feedBack(.Success)
								BF_Audio.shared.playSuccess()
							}
						}
					})
				}
			}
		}
		alertController.present(as: .Sheet)
	}
}
