//
//  BF_Items_Alert_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 15/07/2024.
//

import Foundation
import UIKit

public class BF_Items_Alert_ViewController : BF_Alert_ViewController {
	
	public var monster:BF_Monster? {
		
		didSet {
			
			items = Array(Set(BF_User.current?.items ?? [])).sorted(by: { $0.uid ?? "" < $1.uid ?? "" }).filter({
				
				guard let uid = $0.uid, let monster else { return false }
				
				return [Items.Potions.Hp, Items.Potions.Mp, Items.Potions.Revive].contains(uid) &&
				((uid == Items.Potions.Revive && monster.isDead) ||
				 (uid == Items.Potions.Hp && monster.status.hp > 0 && monster.status.hp < monster.stats.hp) ||
				 (uid == Items.Potions.Mp && monster.status.mp < monster.stats.mp))
			})
			
			if items?.isEmpty ?? true {
				
				add(UIImage(named: "placeholder_empty"))
				add(String(key: "items.monsters.alert.placeholder"))
				addDismissButton()
			}
			else {
				
				add(String(key: "items.monsters.alert.content"))
				add(tableView)
				addCancelButton()
			}
		}
	}
	public var completion:((BF_Item?)->Void)?
	private var items:[BF_Item]? {
		
		didSet {
			
			tableView.reloadData()
		}
	}
	private lazy var tableView:BF_TableView = {
		
		$0.register(BF_Item_Object_TableViewCell.self, forCellReuseIdentifier: BF_Item_Object_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		$0.separatorInset = .zero
		$0.separatorColor = .white.withAlphaComponent(0.25)
		$0.isHeightDynamic = true
		return $0
		
	}(BF_TableView())
	
	public override func loadView() {
		
		super.loadView()
		
		title = String(key: "items.monsters.alert.title")
	}
}

extension BF_Items_Alert_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return items?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BF_Item_Object_TableViewCell.identifier, for: indexPath) as! BF_Item_Object_TableViewCell
		
		let item = items?[indexPath.row]
		cell.item = item
		cell.count = BF_User.current?.items.compactMap({ $0 }).filter({ $0.uid == item?.uid }).count
		
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		close { [weak self] in
			
			self?.completion?(self?.items?[indexPath.row])
		}
	}
}
