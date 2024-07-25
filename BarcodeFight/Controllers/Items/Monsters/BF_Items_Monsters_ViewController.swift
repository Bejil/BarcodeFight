//
//  BF_Items_Monsters_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 26/08/2023.
//

import Foundation
import UIKit

public class BF_Items_Monsters_ViewController : BF_Monsters_List_ViewController {
	
	public var items:[BF_Item]?
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.title = String(key: "items.monsters.title")
		
		NotificationCenter.add(.updateMonsters) { [weak self] _ in
			
			self?.collectionView.reloadData()
		}
	}
}

extension BF_Items_Monsters_ViewController {
	
	public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		if let index = BF_User.current?.items.firstIndex(where: { $0.uid == items?.first?.uid }) {
			
			if let monster = BF_User.current?.monsters.first(where: { $0.barcode == monsters?[indexPath.row].barcode }) {
				
				UIApplication.feedBack(.On)
				
				if items?.first?.uid == Items.Potions.Hp {
					
					monster.status.hp = monster.stats.hp
				}
				else if items?.first?.uid == Items.Potions.Mp {
					
					monster.status.mp = monster.stats.mp
				}
				else if items?.first?.uid == Items.Potions.Revive {
					
					monster.status.hp = Int(0.25 * Double(monster.stats.hp))
				}
				
				items?.removeFirst()
				BF_User.current?.items.remove(at: index)
				
				let alertController:BF_Alert_ViewController = .presentLoading()
				
				BF_User.current?.update({ [weak self] error in
					
					alertController.close { [weak self] in
						
						if let error = error {
							
							BF_Alert_ViewController.present(error)
						}
						else {
							
							UIApplication.feedBack(.Success)
							BF_Audio.shared.playSuccess()
							
							self?.monsters?.removeAll(where: { $0.barcode == monster.barcode })
							
							NotificationCenter.post(.updateAccount)
							NotificationCenter.post(.updateMonsters)
							
							if self?.items?.isEmpty ?? true || self?.monsters?.isEmpty ?? true {
								
								self?.dismiss()
							}
						}
					}
				})
			}
		}
	}
	
	public override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
		
		return nil
	}
}
