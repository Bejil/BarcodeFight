//
//  BF_Account_Ranking_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 31/05/2024.
//

import Foundation
import UIKit

public class BF_Account_Ranking_ViewController : BF_ViewController {
	
	private var users:[BF_User]? {
		
		didSet {
			
			view.dismissPlaceholder()
			
			if users?.isEmpty ?? true {
				
				view.showPlaceholder(.Empty)
			}
			
			tableView.reloadData()
			tableView.delegate?.scrollViewDidScroll?(tableView)
		}
	}
	private lazy var tableView:BF_TableView = {
		
		$0.register(BF_User_TableViewCell.self, forCellReuseIdentifier: BF_User_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		$0.separatorInset = .zero
		$0.separatorColor = .white.withAlphaComponent(0.25)
		return $0
		
	}(BF_TableView())
	private lazy var bannerView = BF_Ads.shared.presentBanner(BF_Ads.Identifiers.Banner.Ranking, self)
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.title = String(key: "account.ranking.title")
		navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "mappin.and.ellipse"), primaryAction: .init(handler: { [weak self] _ in
			
			self?.scrollToCurrent()
		}))
		navigationItem.rightBarButtonItem?.isHidden = true
		
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
		
		launchRequest()
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		bannerView?.isHidden = !BF_Ads.shared.shouldDisplayAd
	}
	
	private func launchRequest() {
		
		view.showPlaceholder(.Loading)
		
		BF_User.getAll { [weak self] users, error in
			
			self?.view.dismissPlaceholder()
			
			if let error {
				
				self?.view.showPlaceholder(.Error, error) { [weak self] _ in
					
					self?.view.dismissPlaceholder()
					
					self?.launchRequest()
				}
			}
			
			self?.users = users?.sorted(by: { $0.ranking > $1.ranking })
		}
	}
}

extension BF_Account_Ranking_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return users?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BF_User_TableViewCell.identifier, for: indexPath) as! BF_User_TableViewCell
		cell.rankLabel.text = "\(indexPath.row+1)"
		cell.user = users?[indexPath.row]
		return cell
	}
	
	public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		
		tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		let user = users?[indexPath.row]
		
		let alertController:BF_Alert_ViewController = .init()
		alertController.titleLabel.isHidden = true
		
		let userStackView:BF_User_Opponent_StackView = .init()
		userStackView.user = user
		alertController.add(userStackView)
		alertController.contentStackView.setCustomSpacing(2*UI.Margins, after: userStackView)

		if user?.uid != BF_User.current?.uid {
			
			alertController.addButton(title: String(key: "account.ranking.fight.button"), subtitle: String(key: "fights.alert.cost.0") + "\(BF_Firebase.shared.config.int(.RubiesFightCost))" + String(key: "fights.alert.cost.1"), image: UIImage(named: "items_rubies")?.resize(25)) { [weak self] _ in
				
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
	
	private func scrollToCurrent() {
		
		if let index = users?.firstIndex(where: { $0.uid == BF_User.current?.uid }) {
			
			tableView.scrollToRow(at: .init(row: index, section: 0), at: .middle, animated: true)
		}
	}
}

extension BF_Account_Ranking_ViewController {
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		if let index = users?.firstIndex(where: { $0.uid == BF_User.current?.uid }) {
			
			navigationItem.rightBarButtonItem?.isHidden = tableView.indexPathsForVisibleRows?.compactMap({ $0.row }).contains(index) ?? false
		}
	}
}
