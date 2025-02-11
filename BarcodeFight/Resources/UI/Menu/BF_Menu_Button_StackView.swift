//
//  BF_Menu_Button_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 23/01/2025.
//

import Foundation
import UIKit

public class BF_Menu_Button_StackView : UIStackView {
	
	public var isEnabled: Bool = true {
		
		didSet {
			
			alpha = isEnabled ? 1.0 : 0.5
			isUserInteractionEnabled = isEnabled
		}
	}
	public var color:UIColor? {
		
		didSet {
			
			button.backgroundView.backgroundColor = color
		}
	}
	public var image:UIImage? {
		
		didSet {
			
			button.iconImageView.image = image
		}
	}
	public var title:String? {
		
		didSet {
			
			label.text = title
		}
	}
	private lazy var button:BF_Menu_Button = .init()
	public var handler:((BF_Button?)->Void)? {
		
		didSet {
			
			button.action = handler
		}
	}
	private lazy var label:BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-4)
		$0.adjustsFontSizeToFitWidth = true
		$0.minimumScaleFactor = 0.5
		$0.textAlignment = .center
		$0.alpha = 0.75
		return $0
		
	}(BF_Label())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .vertical
		spacing = UI.Margins/3
		addArrangedSubview(button)
		addArrangedSubview(label)
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
