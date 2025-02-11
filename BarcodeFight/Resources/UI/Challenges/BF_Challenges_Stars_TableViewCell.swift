//
//  BF_Challenges_Stars_TableViewCell.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 26/08/2024.
//

import Foundation
import UIKit

public class BF_Challenges_Stars_TableViewCell : BF_TableViewCell {
	
	public override class var identifier: String {
		
		return "challengesStarsTableViewCellIdentifier"
	}
	public var challenge:BF_Challenge? {
		
		didSet {
			
			label.text = challenge?.name
			subLabel.text = challenge?.description
			currentIndex = 0
			
			if let lc_challenge = BF_User.current?.challenges.items.first(where: { $0.uid == challenge?.uid }),
			   let sortedDates = lc_challenge.dates?.sorted(),
			   let lastDate = sortedDates.last {
				
				if Calendar.current.isDateInYesterday(lastDate) || Calendar.current.isDateInToday(lastDate) {
					
					var consecutiveCount = 1
					var previousDate = lastDate
					
					for date in sortedDates.filter({ $0 != lastDate }).reversed() {
						
						if let expectedDate = Calendar.current.date(byAdding: .day, value: -1, to: previousDate),
						   Calendar.current.isDate(date, inSameDayAs: expectedDate) {
							
							consecutiveCount += 1
							previousDate = date
						}
						else {
							
							break
						}
					}
					
					currentIndex = min(consecutiveCount, Challenges.Max)
				}
			}
		}
	}
	private var currentIndex:Int = 0 {
		
		didSet {
			
			daysStackView.currentIndex = currentIndex
			
			button.isEnabled = currentIndex == Challenges.Max
			
			if button.isEnabled {
				
				buttonTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
					
					self?.button.pulse(.white)
				})
			}
			else {
				
				buttonTimer?.invalidate()
				buttonTimer = nil
			}
		}
	}
	private lazy var label:BF_Label = {
		
		$0.font = Fonts.Content.Title.H4
		return $0
		
	}(BF_Label())
	private lazy var subLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-1)
		return $0
		
	}(BF_Label())
	private lazy var daysStackView:BF_Challenges_Stars_StackView = .init()
	private var buttonTimer:Timer?
	private lazy var button:BF_Button = {
		
		$0.image = UIImage(named: "items_chestMonsters")?.scalePreservingAspectRatio(targetSize: .init(width: 2*UI.Margins, height: 2*UI.Margins))
		$0.setContentHuggingPriority(.init(1000), for: .horizontal)
		return $0
		
	}(BF_Button() { [weak self] button in
		
		button?.isLoading = true
		
		BF_Item.get { [weak self] items, error in
			
			button?.isLoading = false
			
			if let error {
				
				BF_Alert_ViewController.present(error)
			}
			else if let chest = items?.first(where: { $0.uid == Items.ChestMonsters }) {
				
				button?.isLoading = true
				
				BF_User.current?.items.append(chest)
				
				let lc_challenge = BF_User.current?.challenges.items.first(where: { $0.uid == self?.challenge?.uid })
				
				if let mostRecentDate = lc_challenge?.dates?.max() {
					
					lc_challenge?.dates = [mostRecentDate]
				}
				else {
					
					lc_challenge?.dates = []
				}
				
				BF_User.current?.update({ error in
					
					button?.isLoading = false
					
					if let error {
						
						BF_Alert_ViewController.present(error)
					}
					else {
						
						NotificationCenter.post(.updateChallenges)
						
						let alertController:BF_Item_Chest_Monsters_Alert_ViewController = .init()
						alertController.present()
					}
				})
			}
		}
	})
	
	deinit {
		
		buttonTimer?.invalidate()
		buttonTimer = nil
	}
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let contentStackView:UIStackView = .init(arrangedSubviews: [label,subLabel,daysStackView])
		contentStackView.axis = .vertical
		contentStackView.spacing = UI.Margins/2
		
		let stackView:UIStackView = .init(arrangedSubviews: [contentStackView,button])
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.spacing = UI.Margins
		contentView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
