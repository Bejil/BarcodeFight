//
//  BF_SegmentedControl.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 24/04/2024.
//

import Foundation
import UIKit

public class BF_SegmentedControl:UISegmentedControl {
	
	public override init(items: [Any]?) {
		
		super.init(items: items)
		
		apportionsSegmentWidthsByContent = true
		selectedSegmentTintColor = Colors.Button.Primary.Background
		setTitleTextAttributes([.foregroundColor: Colors.Content.Text.withAlphaComponent(0.75), .font: Fonts.Content.Text.Regular as Any], for:.normal)
		setTitleTextAttributes([.foregroundColor: Colors.Button.Primary.Content as Any, .font: Fonts.Content.Text.Bold as Any], for:.selected)
		snp.makeConstraints { make in
			make.height.equalTo(3 * UI.Margins)
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
