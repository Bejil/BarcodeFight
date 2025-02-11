//
//  BF_Challenges_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 28/08/2024.
//

import Foundation
import UIKit

public class BF_Challenges_ViewController : BF_ViewController {
	
	private var challenges:[BF_Challenge]? {
		
		didSet {
			
			tableView.reloadData()
		}
	}
	private lazy var tableView:BF_TableView = {
		
		$0.register(BF_Challenges_TableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: BF_Challenges_TableViewHeaderView.identifier)
		$0.register(BF_Challenges_Stars_TableViewCell.self, forCellReuseIdentifier: BF_Challenges_Stars_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		$0.separatorInset = .zero
		$0.separatorColor = .white.withAlphaComponent(0.25)
		return $0
		
	}(BF_TableView())
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.title = String(key: "challenges.title")
		
		view.addSubview(tableView)
		tableView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
		
		launchRequest()
		
		NotificationCenter.add(.updateChallenges) { [weak self] _ in
			
			self?.launchRequest()
		}
	}
	
	private func launchRequest() {
		
		view.showPlaceholder(.Loading)
		
		BF_Challenge.get { [weak self] challenges, error in
			
			self?.view.dismissPlaceholder()
			
			if let error {
				
				self?.view.showPlaceholder(.Error, error) { [weak self] placeholder in
					
					self?.view.dismissPlaceholder()
					self?.launchRequest()
				}
			}
			else {
				
				self?.challenges = challenges?.filter({ !($0.uid == Challenges.Story && BF_User.current?.currentStoryPoint == 90) })
			}
		}
	}
}

extension BF_Challenges_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		
		return 2
	}
	
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let view:BF_Challenges_TableViewHeaderView = .init(reuseIdentifier: BF_Challenges_TableViewHeaderView.identifier)
		view.label.text = String(key: "challenges.section.\(section)")
		return view
	}
	
	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		
		if (section == 0 && (challenges?.pending.count ?? 0) == 0) ||
			(section == 1 && (challenges?.done.count ?? 0) == 0){
			
			return 0.0
		}
		
		return UITableView.automaticDimension
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if section == 0 {
			
			return challenges?.pending.count ?? 0
		}
		else if section == 1 {
			
			return challenges?.done.count ?? 0
		}
		
		return 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BF_Challenges_Stars_TableViewCell.identifier, for: indexPath) as! BF_Challenges_Stars_TableViewCell
		
		if indexPath.section == 0 {
			
			cell.challenge = challenges?.pending[indexPath.row]
		}
		else if indexPath.section == 1 {
			
			cell.challenge = challenges?.done[indexPath.row]
		}
		
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
#if DEBUG
		
		var challenge:BF_Challenge? = nil
		
		if indexPath.section == 0 {
			
			challenge = challenges?.pending[indexPath.row]
		}
		else if indexPath.section == 1 {
			
			challenge = challenges?.done[indexPath.row]
		}
		
		let dateFormatter:DateFormatter = .init()
		dateFormatter.dateFormat = "dd/MM/yyyy"
		
		let dates = BF_User.current?.challenges.items.first(where: { $0.uid == challenge?.uid })?.dates?.compactMap({ dateFormatter.string(from: $0) })
		
		if let dates = dates, !dates.isEmpty {
			
			let alertController:BF_Alert_ViewController = .init()
			
			dates.forEach({
				
				alertController.add($0)
			})
			
			alertController.addDismissButton()
			alertController.present(as: .Sheet)
		}
		
#endif
	}
}

