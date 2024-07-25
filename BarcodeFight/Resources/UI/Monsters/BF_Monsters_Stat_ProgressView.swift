//
//  BF_Monsters_Stat_ProgressView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 10/08/2023.
//

import Foundation
import UIKit

public class BF_Monsters_Stat_ProgressView : UIStackView {
	
	public lazy var height = UI.Margins {
		
		didSet {
			
			imageView.snp.makeConstraints { make in
				make.size.equalTo(1.5*height)
			}
			
			progressView.layer.cornerRadius = height/2
			progressView.layer.sublayers?.first?.cornerRadius = height/2
			progressView.snp.makeConstraints { make in
				make.height.equalTo(height)
			}
		}
	}
	public var progress:Float = 0.0 {
		
		didSet {
			
			progressView.setProgress(progress, animated: true)
		}
	}
	public var color:UIColor = Colors.Secondary {
		
		didSet {
			
			imageView.tintColor = color
			progressView.progressTintColor = color
		}
	}
	public var image:UIImage? {
		
		didSet {
			
			imageView.image = image
			imageView.isHidden = image == nil
		}
	}
	public var value:String? {
		
		didSet {
			
			label.isHidden = value?.isEmpty ?? true
			label.text = value
		}
	}
	private lazy var imageView:BF_ImageView = {
		
		$0.isHidden = image == nil
		$0.contentMode = .scaleAspectFit
		$0.snp.makeConstraints { make in
			make.size.equalTo(1.5*height)
		}
		return $0
		
	}(BF_ImageView(image: image))
	private lazy var progressView:UIProgressView = {
		
		$0.progressTintColor = color
		$0.progressViewStyle = .bar
		$0.trackTintColor = Colors.Content.Text.withAlphaComponent(0.1)
		$0.layer.cornerRadius = height/2
		$0.clipsToBounds = true
		$0.layer.sublayers?.first?.cornerRadius = height/2
		$0.subviews.first?.clipsToBounds = true
		$0.snp.makeConstraints { make in
			make.height.equalTo(height)
		}
		return $0
		
	}(UIProgressView())
	private lazy var label:BF_Label = {
		
		$0.isHidden = true
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		return $0
		
	}(BF_Label())
	
	convenience init() {
		
		self.init(frame: .zero)
		
		axis = .horizontal
		alignment = .center
		spacing = UI.Margins/3
		addArrangedSubview(imageView)
		addArrangedSubview(progressView)
		addArrangedSubview(label)
	}
}
