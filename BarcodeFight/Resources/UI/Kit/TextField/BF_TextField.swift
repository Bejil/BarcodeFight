//
//  BF_TextField.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 07/08/2023.
//

import Foundation
import MB_TextField
import UIKit

public class BF_TextField: MB_TextField {
	
	public override func setUp() {
		
		super.setUp()
		
		tintColor = Colors.TextField.Tint
		backgroundColor = .white
		textColor = .black
		invalidColor = Colors.TextField.Invalid
		mandatoryColor = Colors.TextField.Invalid
		borderColor = Colors.Content.Text.withAlphaComponent(0.1)
		placeholderColor = .black.withAlphaComponent(0.5)
		font = Fonts.Content.Text.Regular
		placeholderFont = Fonts.Content.Text.Regular
		mandatoryFont = Fonts.Content.Text.Bold
		inputAccessoryView = nil
		endHandler = { _ in
			
			UIApplication.hideKeyboard()
		}
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		layer.cornerRadius = frame.size.height/2.5
	}
}
