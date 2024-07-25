//
//  Bool_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 21/08/2023.
//

import Foundation

extension Bool {
	
	public static func random(probability: Double) -> Bool {
		
		if probability == 0.0 {
			
			return false
		}
		else if probability <= 1.0 {
			
			var systemRandomNumberGenerator = SystemRandomNumberGenerator()
			return Double.random(in: 0.0...1.0, using: &systemRandomNumberGenerator) <= probability
		}
		
		return Bool.random()
	}
	
}
