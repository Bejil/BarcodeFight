//
//  BF_Monsters_Element_Button.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 11/08/2023.
//

import Foundation
import UIKit

public class BF_Monsters_Element_Button : UIButton {
	
	public var element:BF_Monster.Element? {
		
		didSet {
			
			if let elementReadable = element?.readable, let color = element?.color {
				
				menu = .init(children: [
					
					UIAction(title: elementReadable, image: element?.image?.withTintColor(color, renderingMode: .alwaysOriginal), handler: { _ in
						
					})
				])
			}
			
			layer.borderColor = element == .Neutral ? Colors.Content.Text.cgColor : nil
			layer.borderWidth = element == .Neutral ? 0.5 : 0.0
			
			backgroundColor = element?.color ?? .clear
			
			elementImageView.image = element?.image
			elementImageView.tintColor = element == .Lightness ? .black : .white
		}
	}
	private lazy var elementImageView:BF_ImageView = {
		
		$0.tintColor = .white
		$0.contentMode = .scaleAspectFit
		return $0
		
	}(BF_ImageView())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		showsMenuAsPrimaryAction = true
		
		let height = 1.25*UI.Margins
		layer.cornerRadius = height/2
		snp.makeConstraints { make in
			make.size.equalTo(height)
		}
		addSubview(elementImageView)
		elementImageView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins/7)
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
