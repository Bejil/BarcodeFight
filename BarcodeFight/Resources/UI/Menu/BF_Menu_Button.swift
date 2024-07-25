//
//  BF_Menu_Button.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 02/05/2024.
//

import Foundation
import UIKit

public class BF_Menu_Button : BF_Button {
	
	public override var isEnabled: Bool {
		
		didSet {
			
			alpha = isEnabled ? 1.0 : 0.5
		}
	}
	public lazy var backgroundView:UIView = {
		
		$0.isUserInteractionEnabled = false
		$0.backgroundColor = backgroundColor
		return $0
		
	}(UIView())
	public lazy var iconImageView:BF_ImageView = {
		
		$0.isUserInteractionEnabled = false
		$0.contentMode = .scaleAspectFit
		return $0
		
	}(BF_ImageView())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		style = .transparent
		snp.makeConstraints { make in
			make.size.equalTo(4*UI.Margins)
		}
		
		addSubview(backgroundView)
		backgroundView.snp.makeConstraints { make in
			make.size.equalToSuperview().multipliedBy(0.9)
			make.center.equalToSuperview()
		}
		
		addSubview(iconImageView)
		iconImageView.snp.makeConstraints { make in
			make.size.equalToSuperview().multipliedBy(0.95)
			make.center.equalToSuperview()
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		backgroundView.layer.cornerRadius = frame.size.width/2.5
	}
}
