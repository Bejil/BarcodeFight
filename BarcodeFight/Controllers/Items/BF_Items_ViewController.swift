//
//  BF_Items_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 25/08/2023.
//

import Foundation
import UIKit

public class BF_Items_ViewController : BF_ViewController {
	
	private var items:[BF_Item]? {
		
		didSet {
			
			view.dismissPlaceholder()
			
			if items?.isEmpty ?? true {
				
				let placeholderView = view.showPlaceholder(.Empty)
				let button = placeholderView.addButton(String(key: "items.shop.button")) { [weak self] _ in
					
					self?.navigationController?.pushViewController(BF_Items_Shop_ViewController(), animated: true)
				}
				button.image = UIImage(named: "shop_icon")
			}
			
			tableView.reloadData()
		}
	}
	private lazy var tableView:BF_TableView = {
		
		$0.register(BF_Item_Object_TableViewCell.self, forCellReuseIdentifier: BF_Item_Object_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		$0.separatorInset = .zero
		$0.separatorColor = .white.withAlphaComponent(0.25)
		return $0
		
	}(BF_TableView())
	private lazy var bannerView = BF_Ads.shared.presentBanner(BF_Ads.Identifiers.Banner.Objects, self)
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.title = String(key: "items.title")
		
		let shopButton:BF_Button = .init(String(key: "items.shop.button")) { [weak self] _ in
			
			self?.navigationController?.pushViewController(BF_Items_Shop_ViewController(), animated: true)
		}
		shopButton.style = .transparent
		shopButton.isText = true
		shopButton.image = UIImage(named: "shop_icon")
		shopButton.titleFont = Fonts.Navigation.Button
		shopButton.configuration?.contentInsets = .zero
		shopButton.configuration?.imagePadding = UI.Margins/2
		
		navigationItem.rightBarButtonItem = .init(customView: shopButton)
		
		let stackView:UIStackView = .init(arrangedSubviews: [tableView])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
		
		if let bannerView {
			
			stackView.addArrangedSubview(bannerView)
		}
		
		NotificationCenter.add(.updateAccount) { [weak self] _ in
			
			self?.items = Array(Set(BF_User.current?.items ?? [])).sorted(by: { $0.uid ?? "" < $1.uid ?? "" })
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		launchRequest()
		
		bannerView?.isHidden = !BF_Ads.shared.shouldDisplayAd
	}
	
	private func launchRequest() {
		
		view.showPlaceholder(.Loading)
		
		BF_User.get({ [weak self] error in
			
			self?.view.dismissPlaceholder()
			
			if let error = error {
				
				self?.view.showPlaceholder(.Error,error) { [weak self] _ in
					
					self?.view.dismissPlaceholder()
					self?.launchRequest()
				}
			}
			else {
				
				NotificationCenter.post(.updateAccount)
			}
		})
	}
}

extension BF_Items_ViewController : UITableViewDelegate, UITableViewDataSource {
	
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
		
		let item = items?[indexPath.row]
		let itemId = item?.uid
		
		if [Items.Potions.Hp,Items.Potions.Mp,Items.Potions.Revive].contains(itemId) {
			
			let viewController:BF_Items_Monsters_ViewController = .init()
			viewController.items = BF_User.current?.items.filter({ $0.uid == itemId })
			
			if items?[indexPath.row].uid == Items.Potions.Revive {
				
				viewController.monsters = BF_User.current?.monsters.filter({ $0.isDead })
			}
			else if items?[indexPath.row].uid == Items.Potions.Hp {
				
				viewController.monsters = BF_User.current?.monsters.filter({ !$0.isDead && $0.status.hp != $0.stats.hp })
			}
			else if items?[indexPath.row].uid == Items.Potions.Mp {
				
				viewController.monsters = BF_User.current?.monsters.filter({ !$0.isDead && $0.status.mp != $0.stats.mp })
			}
			
			UI.MainController.present(BF_NavigationController(rootViewController: viewController), animated: true)
		}
		else if itemId == Items.ChestObjects {
			
			let alertController:BF_Item_Chest_Objects_Alert_ViewController = .init()
			alertController.present()
		}
		else if itemId == Items.ChestMonsters {
			
			let alertController:BF_Item_Chest_Monsters_Alert_ViewController = .init()
			alertController.present()
		}
	}
}
