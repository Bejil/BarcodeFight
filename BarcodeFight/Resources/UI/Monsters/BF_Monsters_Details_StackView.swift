//
//  BF_Monsters_Details_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 09/09/2024.
//

import Foundation
import UIKit

public class BF_Monsters_Details_StackView : UIStackView {
	
	public var monster:BF_Monster? {
		
		didSet {
			
			genreLabel.text = monster?.genre.readable
			heightLabel.text = monster?.stats.readableHeight
			weightLabel.text = monster?.stats.readableWeight
		}
	}
	private lazy var genreLabel:BF_Label = .init()
	private lazy var heightLabel:BF_Label = .init()
	private lazy var weightLabel:BF_Label = .init()
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .horizontal
		alignment = .center
		distribution = .fillEqually
		
		let stackViewClosure:((BF_Label,String)->Void) = { [weak self] label, string in
			
			label.font = Fonts.Content.Title.H4
			label.textColor = Colors.Content.Text.withAlphaComponent(0.5)
			label.textAlignment = .center
			
			let keyLabel:BF_Label = .init(string)
			keyLabel.textAlignment = .center
			keyLabel.font = Fonts.Content.Text.Bold.withSize(Fonts.Size - 2)
			
			let stackView:UIStackView = .init(arrangedSubviews: [label,keyLabel])
			stackView.axis = .vertical
			self?.addArrangedSubview(stackView)
		}
		
		stackViewClosure(genreLabel,String(key: "monsters.genre.label"))
		stackViewClosure(heightLabel,String(key: "monsters.stats.height.label"))
		stackViewClosure(weightLabel,String(key: "monsters.stats.weight.label"))
		
		arrangedSubviews.forEach({
			
			if $0 != arrangedSubviews.first {
				
				$0.addLine(position: .leading)
			}
			
			if $0 != arrangedSubviews.last {
				
				$0.addLine(position: .trailing)
			}
		})
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
