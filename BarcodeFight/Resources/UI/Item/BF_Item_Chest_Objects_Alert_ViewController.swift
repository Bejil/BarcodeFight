//
//  BF_Item_Chest_Objects_Alert_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 26/04/2024.
//

import Foundation
import UIKit

public class BF_Item_Chest_Objects_Alert_ViewController : BF_Alert_ViewController {
	
	private var items:[BF_Item?]?
	
	public override func present(as style: BF_Alert_ViewController.Style = .Alert, _ completion: (() -> Void)? = nil) {
		
		if let chestItem = BF_User.current?.items.first(where: { $0.uid == Items.ChestObjects }) {
			
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
					
					BF_Item.getRewards { items, error in
						
						if let error = error {
							
							self?.close({
								
								BF_Alert_ViewController.present(error)
							})
						}
						else {
							
							self?.items = items
							
							if let index = BF_User.current?.items.firstIndex(of: chestItem) {
								
								BF_User.current?.items.remove(at: index)
							}
							
							BF_User.current?.setRewards(items) { [weak self] error in
								
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
									
									if let imageView = imageView {
										
										UIView.transition(with: imageView,
														  duration: 0.3,
														  options: .transitionCrossDissolve,
														  animations: { imageView.image = UIImage(named: "items_chestObjects_open") },
														  completion: nil)
									}
									
									self?.add(String(key: "chest.alert.content"))
									
									let itemsTableView:BF_TableView = .init()
									itemsTableView.register(BF_Item_Object_TableViewCell.self, forCellReuseIdentifier: BF_Item_Object_TableViewCell.identifier)
									itemsTableView.delegate = self
									itemsTableView.dataSource = self
									itemsTableView.isHeightDynamic = true
									itemsTableView.isUserInteractionEnabled = false
									itemsTableView.separatorInset = .zero
									itemsTableView.separatorColor = .white.withAlphaComponent(0.25)
									itemsTableView.isHidden = true
									self?.add(itemsTableView)
									
									let dismissButton = self?.addDismissButton()
									dismissButton?.isHidden = true
									
									BF_Confettis.start()
									
									UIView.animate { [weak self] in
										
										self?.titleLabel.isHidden = false
										itemsTableView.isHidden = false
										dismissButton?.isHidden = false
										
										self?.contentStackView.layoutIfNeeded()
									}
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

extension BF_Item_Chest_Objects_Alert_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return Array(Set(items?.compactMap({ $0 }) ?? [])).sorted(by: { $0.uid ?? "" < $1.uid ?? "" }).count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BF_Item_Object_TableViewCell.identifier, for: indexPath) as! BF_Item_Object_TableViewCell
		
		let item = Array(Set(items?.compactMap({ $0 }) ?? [])).sorted(by: { $0.uid ?? "" < $1.uid ?? "" })[indexPath.row]
		cell.item = item
		cell.count = items?.compactMap({ $0 }).filter({ $0.uid == item.uid }).count
		
		return cell
	}
}
