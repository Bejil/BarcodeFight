//
//  BF_Monsters_List_Select_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 13/05/2024.
//

import Foundation
import UIKit

public class BF_Monsters_List_Select_ViewController : BF_Monsters_List_ViewController {
	
	public var maxNumber:Int {
		
		return 1
	}
	public var handler:(([BF_Monster]?)->Void)?
	public override var monsters: [BF_Monster]? {
		
		didSet {
			
			isEditing = true
			
			updateSelectedMonsters()
		}
	}
	public var selectedMonsters:[BF_Monster]? {
		
		didSet {
			
			updateSelectedMonsters()
		}
	}
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.title = String(key: "battle.team.title")
		
		let buttonView:UIView = .init()
		
		let visualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .regular))
		buttonView.addSubview(visualEffectView)
		visualEffectView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		buttonView.layer.masksToBounds = true
		buttonView.layer.cornerRadius = UI.CornerRadius
		
		let button:BF_Button = .init(String(key: "battle.team.button")) { [weak self] _ in
			
			self?.validateAction()
		}
		buttonView.addSubview(button)
		button.snp.makeConstraints { make in
			make.edges.equalTo(buttonView.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		stackView.addArrangedSubview(buttonView)
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		isEditing = true
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		updateSelectedMonsters()
	}
	
	public override func updateNavigationItems() {
		
		super.updateNavigationItems()
		
		sortBarButtonItem.isEnabled = (monsters?.count ?? 0 > 1)
	}
	
	private func updateSelectedMonsters() {
		
		(0..<(monsters?.count ?? 0)).map({ IndexPath(item: $0, section: 0) }).forEach({ indexPath in
			
			if let cell = collectionView.cellForItem(at: indexPath) as? BF_Monsters_CollectionViewCell, let monster = cell.monster {
				
				if selectedMonsters?.contains(monster) ?? false {
					
					collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
				}
				else {
					collectionView.deselectItem(at: indexPath, animated: true)
				}
			}
		})
	}
	
	private func validateAction() {
		
		if collectionView.indexPathsForSelectedItems?.isEmpty ?? true {
			
			BF_Alert_ViewController.present(BF_Error(String(key: "battle.team.empty.error")))
		}
		else {
			
			let selectedMonsters = collectionView.indexPathsForSelectedItems?.compactMap({ monsters?[$0.item] })
			
			dismiss { [weak self] in
				
				self?.handler?(selectedMonsters)
			}
		}
	}
}

extension BF_Monsters_List_Select_ViewController {
	
	public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		super.collectionView(collectionView, didSelectItemAt: indexPath)
		
		if collectionView.isEditing {
			
			if maxNumber == 1 {
				
				collectionView.indexPathsForSelectedItems?.filter({ $0 != indexPath }).forEach({
					
					collectionView.deselectItem(at: $0, animated: true)
				})
				
				validateAction()
			}
			else if collectionView.indexPathsForSelectedItems?.count ?? 0 > maxNumber {
				
				collectionView.deselectItem(at: indexPath, animated: true)
				
				BF_Alert_ViewController.present(BF_Error(String(key: "battle.team.error")))
			}
		}
	}
}
