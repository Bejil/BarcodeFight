//
//  BF_Rubies_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 25/08/2023.
//

import Foundation
import UIKit

public class BF_Rubies_StackView : UIStackView {
	
	public var user:BF_User? {
		
		didSet {
			
			let rubies = user?.rubies ?? 0
			label.text = rubies > 999 ? "+999" : "\(rubies)"
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
		
		let imageView:BF_ImageView = .init(image: UIImage(named: "items_rubies"))
		imageView.contentMode = .scaleAspectFit
		imageView.snp.makeConstraints { make in
			make.size.equalTo(UI.Margins)
		}
		addArrangedSubview(imageView)
		
		addArrangedSubview(label)
		
		addGestureRecognizer(UITapGestureRecognizer(block: { _ in
			
			UIApplication.feedBack(.On)
			
			let alertController:BF_Rubies_Alert_ViewController = .init()
			alertController.present(as: .Sheet)
		}))
		
		NotificationCenter.add(.updateAccount) { [weak self] _ in
			
			self?.user = BF_User.current
		}
		
		defer {
			
			user = BF_User.current
		}
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
