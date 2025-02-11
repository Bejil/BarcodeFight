//
//  BF_Monsters_Add_CollectionViewCell.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 14/05/2024.
//

import Foundation
import UIKit

public class BF_Monsters_Add_CollectionViewCell : BF_CollectionViewCell {
	
	public override class var identifier: String {
		
		return "monsterAddCollectionViewCellIdentifier"
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		let visualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .dark))
		visualEffectView.alpha = 0.15
		contentView.addSubview(visualEffectView)
		visualEffectView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		contentView.layer.cornerRadius = UI.CornerRadius/2
		contentView.clipsToBounds = true
		
		let titleLabel:BF_Label = .init("+")
		titleLabel.clipsToBounds = false
		titleLabel.layer.masksToBounds = false
		titleLabel.font = Fonts.Navigation.Title.Large.withSize(Fonts.Size+80)
		titleLabel.textColor = Colors.Content.Text.withAlphaComponent(0.75)
		titleLabel.textAlignment = .center
		titleLabel.snp.makeConstraints { make in
			make.height.equalTo(80)
		}
		
		let subtitleLabel:BF_Label = .init(String(key: "monsters.places.add.label"))
		subtitleLabel.textColor = Colors.Content.Text.withAlphaComponent(0.5)
		subtitleLabel.adjustsFontSizeToFitWidth = true
		subtitleLabel.minimumScaleFactor = 0.5
		subtitleLabel.textAlignment = .center
		
		let stackView:UIStackView = .init(arrangedSubviews: [titleLabel,subtitleLabel])
		stackView.axis = .vertical
		contentView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.top.equalToSuperview().inset(1.25*UI.Margins)
			make.right.bottom.left.equalToSuperview().inset(UI.Margins)
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
