//
//  BF_Barcode_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 07/08/2023.
//

import Foundation
import UIKit

public class BF_Barcode_StackView: UIStackView {
	
	public var barcode:String? {
		
		didSet {
			
			if let barcode = barcode, let filter = CIFilter(name: "CICode128BarcodeGenerator") {
				
				let data = barcode.data(using: .ascii)
				filter.setValue(data, forKey: "inputMessage")
				
				if let ciImage = filter.outputImage {
					
					imageView.image =  UIImage(ciImage: ciImage)
				}
				else {
					
					imageView.image = UIImage(systemName: "barcode.viewfinder")
				}
			}
			else {
				
				imageView.image = UIImage(systemName: "barcode.viewfinder")
			}
			
			label.text = barcode ?? String(key: "monsters.barcode.unknown")
		}
	}
	private lazy var imageView:BF_ImageView = {
		
		$0.tintColor = Colors.Content.Text.withAlphaComponent(0.45)
		$0.contentMode = .scaleAspectFit
		return $0
		
	}(BF_ImageView())
	private lazy var label:UILabel = {
		
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-4)
		$0.textColor = .black
		$0.textAlignment = .center
		return $0
		
	}(UILabel())
	
	convenience init() {
		
		self.init(frame: .zero)
		
		backgroundColor = .white
		axis = .vertical
		spacing = -UI.Margins/2
		addArrangedSubview(imageView)
		addArrangedSubview(label)
		snp.makeConstraints { make in
			make.height.equalTo(5*UI.Margins)
		}
		isLayoutMarginsRelativeArrangement = true
		layoutMargins = .init(top: 0, left: 0, bottom: UI.Margins/2, right: 0)
	}
}
