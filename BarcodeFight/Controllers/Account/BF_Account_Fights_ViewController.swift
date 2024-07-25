//
//  BF_Account_Fights_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 05/06/2024.
//

import Foundation
import UIKit

public class BF_Account_Fights_ViewController : BF_ViewController {
	
	private var fights:[BF_Fight]? {
		
		didSet {
			
			tableView.reloadData()
			
			let state = fights?.isEmpty ?? true
			
			navigationItem.rightBarButtonItem?.isHidden = state
			
			if state {
				
				view.showPlaceholder(.Empty)
			}
		}
	}
	private lazy var tableView:BF_TableView = {
		
		$0.register(BF_Fights_TableViewCell.self, forCellReuseIdentifier: BF_Fights_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		$0.separatorInset = .zero
		$0.separatorColor = .white.withAlphaComponent(0.25)
		return $0
		
	}(BF_TableView())
	private lazy var bannerView = BF_Ads.shared.presentBanner(BF_Ads.Identifiers.Banner.Fights, self)
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.title = String(key: "account.fights.title")
		navigationItem.rightBarButtonItem = .init(title: String(key: "account.fights.sort.button"), menu: .init(title: String(key: "account.fights.sort.title"), children: [
			
			UIAction(title:String(key: "account.fights.sort.date"), handler: { [weak self] _ in
				
				self?.fights?.sort(by: { $0.creationDate > $1.creationDate })
			}),
			UIAction(title:String(key: "account.fights.sort.victory"), handler: { [weak self] _ in
				
				self?.fights?.sort(by: { $0.state == .Victory && $1.state != .Victory })
			}),
			UIAction(title:String(key: "account.fights.sort.defeat"), handler: { [weak self] _ in
				
				self?.fights?.sort(by: { $0.state == .Defeat && $1.state != .Defeat })
			}),
			UIAction(title:String(key: "account.fights.sort.dropout"), handler: { [weak self] _ in
				
				self?.fights?.sort(by: { $0.state == .Dropout && $1.state != .Dropout })
			})
		]))
		
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
		
		fights = BF_User.current?.fights.filter({
			
			let players = [$0.creator,$0.opponent]
			
			if players.allSatisfy({ $0.userId != nil }), let uid = BF_User.current?.uid, players.compactMap({ $0.userId }).contains(uid) {
				
				return true
			}
			
			return false
			
		}).sorted(by: { $0.creationDate > $1.creationDate })
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		bannerView?.isHidden = !BF_Ads.shared.shouldDisplayAd
	}	
}

extension BF_Account_Fights_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return fights?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BF_Fights_TableViewCell.identifier, for: indexPath) as! BF_Fights_TableViewCell
		cell.fight = fights?[indexPath.row]
		return cell
	}
	
	public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		
		tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		if let fight = fights?[indexPath.row] {
			
			let player = [fight.opponent,fight.creator].compactMap({ $0 }).first(where: { $0.userId != BF_User.current?.uid })
			
			let alertController:BF_Alert_ViewController = .presentLoading()
			
			BF_User.get(player?.userId) { user, error in
				
				alertController.close {
					
					if let error {
						
						BF_Alert_ViewController.present(error)
					}
					else {
						
						let alertController:BF_Alert_ViewController = .init()
						alertController.titleLabel.isHidden = true
						
						let userStackView:BF_User_Opponent_StackView = .init()
						userStackView.user = user
						alertController.add(userStackView)
						alertController.contentStackView.setCustomSpacing(2*UI.Margins, after: userStackView)
						
						if user?.uid != BF_User.current?.uid {
							
							alertController.addButton(title: String(key: "account.fights.fight.button"), subtitle: String(key: "fights.alert.cost.0") + "\(BF_Firebase.shared.config.int(.RubiesFightCost))" + String(key: "fights.alert.cost.1"), image: UIImage(named: "items_rubies")?.resize(25)) { [weak self] _ in
								
								alertController.close { [weak self] in
									
									self?.dismiss({
										
										BF_Fight.new(user)
									})
								}
							}
						}
						
						alertController.addDismissButton()
						alertController.present()
					}
				}
			}
		}
	}
}
