//
//  BF_Fights_TableViewCell.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 05/06/2024.
//

import Foundation
import UIKit

public class BF_Fights_TableViewCell : BF_TableViewCell {
	
	public override class var identifier: String {
		
		return "fightsTableViewCellIdentifier"
	}
	public var fight:BF_Fight? {
		
		didSet {
			
			let player = [fight?.opponent,fight?.creator].compactMap({ $0 }).first(where: { $0.userId != BF_User.current?.uid })
			
			displayNameLabel.text = player?.displayName
			
			BF_User.get(player?.userId) { [weak self] user, _ in
				
				self?.userImageView.user = user
			}
			
			var string:String = ""
			
			if fight?.state == .Victory {
				
				stateImageView.image = UIImage(named: "victory_icon")
				string.append(String(key: "fights.victory.label"))
			}
			else if fight?.state == .Defeat {
				
				stateImageView.image = UIImage(named: "defeat_icon")
				string.append(String(key: "fights.defeat.label"))
			}
			else if fight?.state == .Dropout {
				
				stateImageView.image = UIImage(named: "dropout_icon")
				string.append(String(key: "fights.dropout.label"))
			}
			
			if let date = fight?.creationDate {
				
				let dateFormatter:DateFormatter = .init()
				dateFormatter.dateFormat = "dd/MM/yyyy"
				
				string.append(String(key: "fights.date") + dateFormatter.string(from: date))
			}
			
			stateLabel.text = string
		}
	}
	public lazy var userImageView:BF_User_ImageView = {
		
		$0.snp.makeConstraints { make in
			make.size.equalTo(2*UI.Margins)
		}
		return $0
		
	}(BF_User_ImageView())
	private lazy var displayNameLabel:BF_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.numberOfLines = 1
		return $0
		
	}(BF_Label())
	private lazy var stateImageView:BF_ImageView = {
		
		$0.contentMode = .scaleAspectFit
		$0.snp.makeConstraints { make in
			make.size.equalTo(2*UI.Margins)
		}
		return $0
		
	}(BF_ImageView())
	private lazy var stateLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-3)
		return $0
		
	}(BF_Label())
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		tintColor = Colors.Content.Text
		accessoryType = .detailButton
		
		let stateStackView:UIStackView = .init(arrangedSubviews: [stateImageView])
		stateStackView.axis = .vertical
		stateStackView.spacing = UI.Margins/3
		stateStackView.isLayoutMarginsRelativeArrangement = true
		stateStackView.layoutMargins.right = UI.Margins
		stateStackView.addLine(position: .trailing)
		
		let detailsStackView:UIStackView = .init(arrangedSubviews: [displayNameLabel,stateLabel])
		detailsStackView.axis = .vertical
		detailsStackView.spacing = UI.Margins/4
		
		let contentStackView:UIStackView = .init(arrangedSubviews: [userImageView,detailsStackView])
		contentStackView.axis = .horizontal
		contentStackView.spacing = UI.Margins
		contentStackView.alignment = .center
		
		let stackView:UIStackView = .init(arrangedSubviews: [stateStackView,contentStackView])
		stackView.axis = .horizontal
		stackView.spacing = UI.Margins
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
