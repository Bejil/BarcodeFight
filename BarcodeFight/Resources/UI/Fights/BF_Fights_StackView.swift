//
//  BF_Fights_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 17/08/2023.
//

import Foundation
import UIKit

public class BF_Fights_StackView : UIStackView {
	
	public var fights:[BF_Fight]? {
		
		didSet {
			
			victoriesLabel.text = String(fights?.victories.count ?? 0)
			defeatsLabel.text = String(fights?.defeats.count ?? 0)
			dropoutsLabel.text = String(fights?.dropouts.count ?? 0)
		}
	}
	private lazy var victoriesLabel:BF_Label = .init()
	private lazy var defeatsLabel:BF_Label = .init()
	private lazy var dropoutsLabel:BF_Label = .init()
	
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
		
		stackViewClosure(victoriesLabel,String(key: "fights.victories.label"))
		stackViewClosure(defeatsLabel,String(key: "fights.defeats.label"))
		stackViewClosure(dropoutsLabel,String(key: "fights.dropouts.label"))
		
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
