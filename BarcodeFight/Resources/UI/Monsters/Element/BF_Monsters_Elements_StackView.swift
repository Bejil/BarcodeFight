//
//  BF_Monsters_Elements_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 17/08/2023.
//

import Foundation
import UIKit

public class BF_Monsters_Elements_StackView : UIStackView {
	
	public var monster:BF_Monster? {
		
		didSet {
			
			if let element = monster?.element {
				
				weaknessElementsStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
				advantageElementsStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
				
				BF_Monster.Element.allCases.forEach({
					
					if $0 > element {
						
						let view:BF_Monsters_Element_Button = .init()
						view.element = $0
						weaknessElementsStackView.addArrangedSubview(view)
					}
					
					if $0 < element {
						
						let view:BF_Monsters_Element_Button = .init()
						view.element = $0
						advantageElementsStackView.addArrangedSubview(view)
					}
				})
			}
		}
	}
	
	private lazy var weaknessElementsStackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.alignment = .center
		$0.spacing = -UI.Margins/3
		return $0
		
	}(UIStackView())
	private lazy var advantageElementsStackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.alignment = .center
		$0.spacing = -UI.Margins/3
		return $0
		
	}(UIStackView())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .horizontal
		alignment = .center
		distribution = .fillEqually
		
		let stackViewClosure:((UIStackView,String)->Void) = { [weak self] stackView, string in
			
			let view:UIView = .init()
			view.addSubview(stackView)
			stackView.snp.makeConstraints { make in
				make.top.bottom.centerX.equalToSuperview()
			}
			
			let keyLabel:BF_Label = .init(string)
			keyLabel.textAlignment = .center
			keyLabel.font = Fonts.Content.Text.Bold.withSize(Fonts.Size - 2)
			
			let stackView:UIStackView = .init(arrangedSubviews: [view,keyLabel])
			stackView.axis = .vertical
			stackView.spacing = UI.Margins/3
			self?.addArrangedSubview(stackView)
		}
		
		stackViewClosure(weaknessElementsStackView,String(key: "monsters.element.weakness.label"))
		stackViewClosure(advantageElementsStackView,String(key: "monsters.element.advantage.label"))
		
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
