//
//  BF_Monsters_Delete_Alert_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 09/08/2023.
//

import Foundation
import UIKit

public class BF_Monsters_Delete_Alert_ViewController : BF_Alert_ViewController {
	
	convenience init(_ monsters:[BF_Monster]?) {
		
		self.init()
		
		title = String(key: "monsters.alert.delete.title")
		add(UIImage(named: "placeholder_delete"))
		add(String(key: "monsters.alert.delete.label.0"))
		add(String(key: "monsters.alert.delete.label.1"))
		
		let button = addButton(title: String(key: "monsters.alert.delete.button")) { [weak self] button in
			
			button?.isLoading = true
			
			BF_User.current?.monsters = BF_User.current?.monsters.filter({ !(monsters?.contains($0) ?? false) }) ?? .init()
			BF_User.current?.update { [weak self] error in
				
				button?.isLoading = false
				
				self?.close {
					
					if let error = error {
						
						BF_Alert_ViewController.present(error)
					}
					else {
						
						NotificationCenter.post(.updateAccount)
						NotificationCenter.post(.updateMonsters)
						
						BF_Toast_Manager.shared.addToast(title: String(key: "monsters.alert.delete.success.toast.title"), subtitle: String(key: "monsters.alert.delete.success.toast.subtitle"), style: .Success)
					}
				}
			}
		}
		button.isDelete = true
		addCancelButton()
	}
}
