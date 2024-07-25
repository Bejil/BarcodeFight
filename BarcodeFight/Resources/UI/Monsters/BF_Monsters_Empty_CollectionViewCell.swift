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
