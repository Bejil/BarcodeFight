//
//  BF_Stepper.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 17/08/2023.
//

import Foundation
import UIKit

public class BF_Stepper : UIStepper {
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		setDecrementImage(UIImage(systemName: "minus.circle.fill")?.withTintColor(Colors.Button.Primary.Background, renderingMode: .alwaysOriginal), for: .normal)
		setIncrementImage(UIImage(systemName: "plus.circle.fill")?.withTintColor(Colors.Button.Primary.Background, renderingMode: .alwaysOriginal), for: .normal)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
