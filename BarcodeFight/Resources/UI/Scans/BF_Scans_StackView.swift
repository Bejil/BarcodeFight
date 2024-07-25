//
//  BF_Scans_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 25/08/2023.
//

import Foundation
import UIKit

public class BF_Scans_StackView : UIStackView {
	
	public var user:BF_User? {
		
		didSet {
			
			let scanAvailable = user?.scanAvailable ?? 0
			label.text = (scanAvailable > 99 ? "+" : "") + "\(scanAvailable)"
		}
	}
	private lazy var label:BF_Label = {
		
		$0.textAlignment = .center
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-2)
		$0.snp.makeConstraints { make in
			make.width.equalTo(1.5*UI.Margins)
		}
		return $0
		
	}(BF_Label())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .horizontal
		spacing = UI.Margins/3
		alignment = .center
		
		let imageView:BF_ImageView = .init(image: UIImage(named: "scan_icon"))
		imageView.contentMode = .scaleAspectFit
		imageView.snp.makeConstraints { make in
			make.size.equalTo(UI.Margins)
		}
		addArrangedSubview(imageView)
		
		addArrangedSubview(label)
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
