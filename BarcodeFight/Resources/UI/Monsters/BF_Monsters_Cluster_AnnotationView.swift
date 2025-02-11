//
//  BF_Monsters_Cluster_AnnotationView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 25/07/2024.
//

import Foundation
import MapKit

public class BF_Monsters_Cluster_AnnotationView : MKAnnotationView {
	
	private lazy var label:BF_Label = {
		
		$0.font = Fonts.Content.Title.H2
		$0.textColor = .white
		$0.textAlignment = .center
		$0.numberOfLines = 1
		return $0
		
	}(BF_Label())
	
	public override var annotation: (any MKAnnotation)? {
		
		didSet {
			
			label.text = "\((annotation as? MKClusterAnnotation)?.memberAnnotations.count ?? 0)"
		}
	}
	
	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		
		tintColor = Colors.Secondary
		canShowCallout = true
		rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
		
		let size = 5*UI.Margins
		
		frame = .init(origin: .zero, size: .init(width: size, height: size))
		layer.cornerRadius = size/2
		backgroundColor = Colors.Primary
		layer.borderWidth = UI.Margins/3
		layer.borderColor = UIColor.white.cgColor
		
		addSubview(label)
		label.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
