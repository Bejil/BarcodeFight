//
//  BF_Monsters_Min_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 22/08/2023.
//

import Foundation
import UIKit

public class BF_Monsters_Min_StackView : UIStackView {
	
	public var monster:BF_Monster? {
		
		didSet {
			
			particlesView.monster = monster
			
			rankLabel.text = monster?.stats.rank.readable
			elementView.element = monster?.element
			pictureImageView.monster = monster
			nameLabel.text = monster?.name
			
			hpProgressView.progress = Float(monster?.status.hp ?? Int(BF_Monster.Stats.range.lowerBound))/Float(monster?.stats.hp ?? Int(BF_Monster.Stats.range.upperBound))
			mpProgressView.progress = Float(monster?.status.mp ?? Int(BF_Monster.Stats.range.lowerBound))/Float(monster?.stats.mp ?? Int(BF_Monster.Stats.range.upperBound))
		}
	}
	private lazy var rankLabel:BF_Label = {
		
		$0.backgroundColor = Colors.Content.Text.withAlphaComponent(0.45)
		$0.textColor = .white
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-3)
		$0.layer.cornerRadius = UI.Margins/4
		$0.textAlignment = .center
		$0.contentInsets = .init(horizontal: 2)
		$0.snp.makeConstraints { make in
			make.height.equalTo(1.25*UI.Margins)
		}
		return $0
		
	}(BF_Label())
	private lazy var elementView:BF_Monsters_Element_Button = .init()
	private lazy var pictureImageView:BF_Monsters_ImageView = {
		
		$0.setContentHuggingPriority(.init(1), for: .vertical)
		$0.setContentCompressionResistancePriority(.init(1), for: .vertical)
		return $0
		
	}(BF_Monsters_ImageView())
	public lazy var nameLabel:BF_Label = {
		
		$0.font = Fonts.Content.Title.H4.withSize(Fonts.Size+2)
		$0.textAlignment = .center
		$0.setContentHuggingPriority(.init(1000), for: .vertical)
		return $0
		
	}(BF_Label())
	public lazy var hpProgressView:BF_Monsters_Stat_ProgressView = {
		
		$0.color = Colors.Monsters.Stats.Hp
		$0.height = UI.Margins/3
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	public lazy var limitProgressView:BF_Monsters_Stat_ProgressView = {
		
		$0.color = Colors.Button.Delete.Background
		$0.height = UI.Margins/3
		$0.isHidden = true
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	public lazy var mpProgressView:BF_Monsters_Stat_ProgressView = {
		
		$0.color = Colors.Monsters.Stats.Mp
		$0.height = UI.Margins/3
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	public lazy var particlesView:BF_Monsters_Particules_View = {
		
		$0.scale = 5.0
		return $0
		
	}(BF_Monsters_Particules_View())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .vertical
		spacing = UI.Margins/2
		
		addSubview(particlesView)
		
		let stackView:UIStackView = .init(arrangedSubviews: [rankLabel,elementView])
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.distribution = .equalSpacing
		addArrangedSubview(stackView)
		setCustomSpacing(0, after: stackView)
		
		addArrangedSubview(pictureImageView)
		
		particlesView.snp.makeConstraints { make in
			make.center.equalTo(pictureImageView)
			make.size.equalToSuperview()
		}
		
		addArrangedSubview(nameLabel)
		
		addArrangedSubview(hpProgressView)
		setCustomSpacing(UI.Margins/5, after: hpProgressView)
		
		addArrangedSubview(mpProgressView)
		setCustomSpacing(UI.Margins/5, after: mpProgressView)
		
		addArrangedSubview(limitProgressView)
		
		addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] _ in
			
			let alertController:BF_Monsters_Alert_ViewController = .init()
			alertController.monster = self?.monster
			alertController.present()
		}))
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public func flip() {
		
		pictureImageView.image = pictureImageView.image?.withHorizontallyFlippedOrientation()
	}
}
