//
//  BF_Monsters_Empty_CollectionViewCell.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 14/05/2024.
//

import Foundation
import UIKit

public class BF_Monsters_Empty_CollectionViewCell : BF_CollectionViewCell {
	
	public override class var identifier: String {
		
		return "monsterEmptyCollectionViewCellIdentifier"
	}
	private lazy var shapeLayer:CAShapeLayer = {
		
		$0.strokeColor = Colors.Content.Text.withAlphaComponent(0.15).cgColor
		$0.lineDashPattern = [UI.Margins/2 as NSNumber, UI.Margins/3 as NSNumber]
		$0.frame = layer.bounds
		$0.lineWidth = UI.Margins/3
		$0.fillColor = nil
		$0.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
		return $0
		
	}(CAShapeLayer())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		contentView.layer.cornerRadius = UI.CornerRadius/2
		contentView.clipsToBounds = true
		contentView.layer.addSublayer(shapeLayer)
		
		let imageView:BF_ImageView = .init(image: UIImage(named: "scan_icon")?.noir)
		imageView.alpha = 0.85
		imageView.contentMode = .scaleAspectFit
		imageView.snp.makeConstraints { make in
			make.height.equalTo(65)
		}
		
		let subtitleLabel:BF_Label = .init(String(key: "monsters.placeholder.button"))
		subtitleLabel.textColor = Colors.Content.Text.withAlphaComponent(0.5)
		subtitleLabel.adjustsFontSizeToFitWidth = true
		subtitleLabel.minimumScaleFactor = 0.5
		subtitleLabel.textAlignment = .center
		
		let stackView:UIStackView = .init(arrangedSubviews: [imageView,subtitleLabel])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		contentView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.top.equalToSuperview().inset(1.25*UI.Margins)
			make.right.bottom.left.equalToSuperview().inset(UI.Margins)
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		shapeLayer.frame = contentView.layer.bounds
		shapeLayer.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
	}
}
