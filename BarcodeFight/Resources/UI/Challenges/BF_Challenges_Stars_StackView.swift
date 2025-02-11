//
//  BF_Challenges_Stars_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 24/01/2025.
//

import UIKit

public class BF_Challenges_Stars_StackView : UIStackView {
	
	public var currentIndex:Int = 0 {
		
		didSet {
			
			let imageViews = arrangedSubviews.compactMap({ $0 as? BF_ImageView })
			
			for i in 0..<currentIndex {
				
				UIApplication.wait(Double(i)*0.25) {
					
					let imageView = imageViews[i]
					
					UIView.transition(with: imageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
						
						imageView.image = UIImage(named: "star_on_icon")
						imageView.alpha = 1.0
						
					}, completion: nil)
					
					imageView.pulse(.white)
				}
			}
			
			daysLabel.text = "\(currentIndex)" + String(key: " jours consécutifs")
			
			if currentIndex != Challenges.Max {
				
				let daysLeft = Challenges.Max-currentIndex
				
				if daysLeft == 1 {
					
					daysLabel.text = (daysLabel.text ?? "") + String(key: ", plus qu'un !")
				}
				else {
					
					daysLabel.text = (daysLabel.text ?? "") + String(key: ", encore ") + "\(Challenges.Max-currentIndex)"
				}
			}
		}
	}
	private lazy var daysLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		return $0
		
	}(BF_Label())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .horizontal
		alignment = .center
		spacing = UI.Margins/5
		
		for i in 0..<Challenges.Max {
			
			let imageView:BF_ImageView = .init(image: UIImage(named: "star_off_icon"))
			imageView.alpha = 0.25
			imageView.contentMode = .scaleAspectFit
			imageView.snp.makeConstraints { make in
				make.size.equalTo(3*UI.Margins/4)
			}
			addArrangedSubview(imageView)
			
			if i == Challenges.Max-1 {
				
				setCustomSpacing(UI.Margins/2, after: imageView)
			}
		}
		
		addArrangedSubview(daysLabel)
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
