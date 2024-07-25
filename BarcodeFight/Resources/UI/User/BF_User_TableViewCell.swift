//
//  BF_User_TableViewCell.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 31/05/2024.
//

import Foundation
import UIKit

public class BF_User_TableViewCell : BF_TableViewCell {
	
	public override class var identifier: String {
		
		return "userTableViewCellIdentifier"
	}
	public var user:BF_User? {
		
		didSet {
			
			currentUserBackgroundView.isHidden = user?.uid != BF_User.current?.uid
			userStackView.user = user
			pointsLabel.text = "\(user?.ranking ?? 0) points"
		}
	}
	private lazy var currentUserBackgroundView:UIVisualEffectView = {
		
		$0.isHidden = true
		return $0
		
	}(UIVisualEffectView(effect: UIBlurEffect(style: .regular)))
	public lazy var rankLabel:BF_Label = {
		
		$0.font = Fonts.Content.Title.H1
		$0.setContentHuggingPriority(.init(1000), for: .horizontal)
		return $0
		
	}(BF_Label())
	private lazy var userStackView:BF_User_Opponent_StackView = {
		
		$0.imageView.snp.remakeConstraints { make in
			make.size.equalTo(2*UI.Margins)
		}
		$0.fightsStackView.isHidden = true
		$0.rankLabel.isHidden = true
		return $0
		
	}(BF_User_Opponent_StackView())
	private lazy var pointsLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-3)
		$0.setContentHuggingPriority(.init(1000), for: .horizontal)
		$0.backgroundColor = Colors.Content.Text.withAlphaComponent(0.1)
		$0.layer.cornerRadius = UI.Margins/4
		$0.contentInsets = .init(horizontal: 3, vertical: 1)
		$0.textAlignment = .center
		return $0
		
	}(BF_Label())
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		tintColor = Colors.Content.Text
		accessoryType = .detailButton
		
		insertSubview(currentUserBackgroundView, at: 0)
		currentUserBackgroundView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let stackView:UIStackView = .init(arrangedSubviews: [rankLabel,userStackView,pointsLabel])
		stackView.axis = .horizontal
		stackView.spacing = UI.Margins
		stackView.setCustomSpacing(UI.Margins/2, after: userStackView)
		stackView.alignment = .center
		contentView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
