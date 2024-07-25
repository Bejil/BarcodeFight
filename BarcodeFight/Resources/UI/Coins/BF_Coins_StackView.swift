//
//  BF_Coins_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 25/08/2023.
//

import Foundation
import UIKit

public class BF_Coins_StackView : UIStackView {
	
	public var user:BF_User? {
		
		didSet {
			
			label.text = "\(user?.coins ?? 0)"
		}
	}
	private lazy var label:BF_Label = {
	
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-2)
		return $0
		
	}(BF_Label())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .horizontal
		spacing = UI.Margins/3	
		alignment = .center
		
		let imageView:BF_ImageView = .init(image: UIImage(named: "items_coins"))
		imageView.contentMode = .scaleAspectFit
		addArrangedSubview(imageView)
		
		imageView.snp.makeConstraints { make in
			make.height.equalToSuperview()
			make.width.equalTo(self.snp.height)
		}
		
		addArrangedSubview(label)
		
		snp.makeConstraints { make in
			make.height.lessThanOrEqualTo(UI.Margins)
		}
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
