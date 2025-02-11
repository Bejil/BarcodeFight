//
//  BF_Confettis.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 26/04/2024.
//

import Foundation
import SPConfetti

public class BF_Confettis {
	
	public static func start() {
		
		SPConfettiConfiguration.particlesConfig.birthRate = 30
		SPConfettiConfiguration.particlesConfig.colors = [Colors.Button.Primary.Background,Colors.Button.Secondary.Background]
		SPConfetti.startAnimating(.fullWidthToDown, particles: [.arc])
	}
	
	public static func stop() {
		
		SPConfetti.stopAnimating()
	}
}
