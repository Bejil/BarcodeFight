//
//  BF_Battle_Fight_Fake_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 05/09/2023.
//

import Foundation
import UIKit

public class BF_Battle_Fight_Fake_ViewController : BF_Battle_Fight_ViewController {
	
	public override var experienceVictory: Int {
		
		return BF_Firebase.shared.config.int(.ExperienceFakeFightVictory)
	}
	public override var experienceDefeat: Int {
		
		return BF_Firebase.shared.config.int(.ExperienceFakeFightDefeat)
	}
	public override var experienceDropout: Int {
		
		return BF_Firebase.shared.config.int(.ExperienceFakeFightDropout)
	}
}
