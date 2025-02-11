//
//  BF_Monsters_Full_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 10/09/2024.
//

import Foundation
import UIKit

public class BF_Monsters_Full_StackView : UIStackView {
	
	public var monster:BF_Monster? {
		
		didSet {
			
			particlesView.monster = monster
			
			if let picture = monster?.picture {
				
				pictureImageView.image = UIImage(named: picture)?.withHorizontallyFlippedOrientation()
			}
			
			rankLabel.text = monster?.stats.rank.readable
			elementView.element = monster?.element
			nameLabel.text = monster?.name
			detailsStackView.monster = monster
			descriptionLabel.text = monster?.description
			statsStackView.monster = monster
			elementsStackView.monster = monster
		}
	}
	private lazy var particlesView:BF_Monsters_Particules_View = {
		
//		$0.scale = 1.5
		return $0
		
	}(BF_Monsters_Particules_View())
	private lazy var pictureImageView:BF_Monsters_ImageView = {
		
		$0.snp.makeConstraints { make in
			make.height.equalTo(15*UI.Margins)
		}
		return $0
		
	}(BF_Monsters_ImageView())
	private lazy var rankLabel:BF_Label = {
		
		$0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		$0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
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
	private lazy var nameLabel:BF_Label = {
		
		$0.font = Fonts.Content.Title.H1
		$0.textAlignment = .center
		return $0
		
	}(BF_Label())
	private lazy var detailsStackView:BF_Monsters_Details_StackView = .init()
	private lazy var genreLabel:BF_Label = .init()
	private lazy var heightLabel:BF_Label = .init()
	private lazy var weightLabel:BF_Label = .init()
	private lazy var descriptionLabel:BF_Label = {
		
		$0.textAlignment = .center
		return $0
		
	}(BF_Label())
	private lazy var statsStackView:BF_Monsters_Stats_StackView = .init()
	private lazy var elementsStackView:BF_Monsters_Elements_StackView = .init()
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .vertical
		spacing = 1.5*UI.Margins
		
		addSubview(particlesView)
		
		addArrangedSubview(pictureImageView)
		
		particlesView.snp.makeConstraints { make in
			make.center.equalTo(pictureImageView)
			make.size.equalToSuperview()
		}
		
		let contentStackView:UIStackView = .init()
		contentStackView.axis = .vertical
		contentStackView.spacing = 2*UI.Margins
		
		let stackView:UIStackView = .init(arrangedSubviews: [rankLabel,elementView])
		stackView.axis = .horizontal
		stackView.spacing = UI.Margins
		stackView.alignment = .center
		
		let headStackView:UIStackView = .init(arrangedSubviews: [stackView])
		headStackView.axis = .vertical
		headStackView.alignment = .center
		contentStackView.addArrangedSubview(headStackView)
		
		contentStackView.addArrangedSubview(nameLabel)
		contentStackView.addArrangedSubview(detailsStackView)
		contentStackView.addArrangedSubview(descriptionLabel)
		
		let statsLabel:BF_Label = .init(String(key: "monsters.features.label"))
		statsLabel.font = Fonts.Content.Title.H4
		statsLabel.textAlignment = .center
		statsLabel.contentInsets.bottom = UI.Margins/2
		statsLabel.addLine(position: .bottom)
		contentStackView.addArrangedSubview(statsLabel)
		
		contentStackView.addArrangedSubview(statsStackView)
		
		contentStackView.addArrangedSubview(elementsStackView)
		
		addArrangedSubview(contentStackView)
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func didMoveToSuperview() {
		
		super.didMoveToSuperview()
		
		pictureImageView.animate(true)
	}
}
