//
//  BF_User_Opponent_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 15/05/2024.
//

import Foundation
import UIKit

public class BF_User_Opponent_StackView : UIStackView {
	
	public var user:BF_User? {
		
		didSet {
			
			imageView.user = user
			
			displayNameLabel.text = user?.displayName
			levelLabel.text = String(key: "account.infos.experience.level.label") + "\(user?.level.number ?? 0)"
			
			BF_User.getAll { [weak self] users, error in
				
				if let index = users?.sorted(by: { $0.ranking > $1.ranking }).firstIndex(where: { self?.user?.uid == $0.uid }) {
					
					self?.rankLabel.text = "\(index+1)" + String(key: "account.infos.ranking.label." + ((index+1 == 1) ? "0" : "1"))
				}
			}
			
			fightsStackView.fights = user?.fights
		}
	}
	public lazy var imageView:BF_User_ImageView = {
		
		$0.snp.makeConstraints { make in
			make.size.equalTo(4.5*UI.Margins)
		}
		return $0
		
	}(BF_User_ImageView())
	private lazy var displayNameLabel:BF_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.numberOfLines = 1
		return $0
		
	}(BF_Label())
	private lazy var levelLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-3)
		$0.setContentHuggingPriority(.init(1000), for: .horizontal)
		$0.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
		$0.backgroundColor = Colors.Content.Text.withAlphaComponent(0.1)
		$0.layer.cornerRadius = UI.Margins/4
		$0.contentInsets = .init(horizontal: 3, vertical: 1)
		$0.textAlignment = .center
		return $0
		
	}(BF_Label())
	public lazy var rankLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-3)
		$0.setContentHuggingPriority(.init(1000), for: .horizontal)
		$0.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
		$0.backgroundColor = Colors.Content.Text.withAlphaComponent(0.1)
		$0.layer.cornerRadius = UI.Margins/4
		$0.contentInsets = .init(horizontal: 3, vertical: 1)
		$0.textAlignment = .center
		return $0
		
	}(BF_Label())
	public lazy var fightsStackView:BF_Fights_StackView = .init()
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .horizontal
		spacing = UI.Margins
		alignment = .center
		addArrangedSubview(imageView)
		
		let labelsStackView:UIStackView = .init(arrangedSubviews: [displayNameLabel,levelLabel,rankLabel])
		labelsStackView.axis = .horizontal
		labelsStackView.spacing = UI.Margins/3
		labelsStackView.alignment = .center
		
		let detailsStackView:UIStackView = .init(arrangedSubviews: [labelsStackView,fightsStackView])
		detailsStackView.axis = .vertical
		detailsStackView.spacing = UI.Margins
		addArrangedSubview(detailsStackView)
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
