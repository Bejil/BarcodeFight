//
//  BF_Monster_AnnotationView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 22/07/2024.
//

import Foundation
import MapKit

public class BF_Monster_AnnotationView : MKAnnotationView {
	
	public class var identifier: String {
		
		return "monsterAnnotationView"
	}
	public override var annotation: MKAnnotation? {
		
		didSet {
			
			monster = (annotation as? BF_Monster_PointAnnotation)?.monster
		}
	}
	public var monster:BF_Monster? {
		
		didSet {
			
			monsterStackView.monster = monster
		}
	}
	private lazy var monsterStackView:BF_Monsters_StackView = {
		
		$0.nameLabel.isHidden = true
		$0.hpProgressView.isHidden = true
		$0.mpProgressView.isHidden = true
		return $0
		
	}(BF_Monsters_StackView())
	
	public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		
		canShowCallout = true
		
		addSubview(monsterStackView)
		monsterStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		frame = .init(origin: .zero, size: .init(width: 5*UI.Margins, height: 5*UI.Margins))
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public func present(){
		
		alpha = 0.0
		transform = .init(scaleX: 0.01, y: 0.01)
		
		UIView.animate {
			
			self.alpha = 1.0
			self.transform = .identity
		}
	}
}
