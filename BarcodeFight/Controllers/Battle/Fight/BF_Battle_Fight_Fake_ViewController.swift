//
//  BF_Battle_Fight_Fake_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 05/09/2023.
//

import Foundation
import UIKit

public class BF_Battle_Fight_Fake_ViewController : BF_Battle_Fight_ViewController {
	
	public var isStoryFight:Bool?
	public override var experienceVictory: Int {
		
		return BF_Firebase.shared.config.int(.ExperienceFakeFightVictory) * (isStoryFight ?? false ? max(1,(BF_User.current?.currentStoryPoint ?? 0) / 3) : 1)
	}
	public override var experienceDefeat: Int {
		
		return BF_Firebase.shared.config.int(.ExperienceFakeFightDefeat)
	}
	public override var experienceDropout: Int {
		
		return BF_Firebase.shared.config.int(.ExperienceFakeFightDropout)
	}
	
	public override func loadView() {
		
		super.loadView()
		
		showTutorial(false) { [weak self] in
			
			UIApplication.wait { [weak self] in
				
				self?.startToss()
			}
		}
	}
	
	public override func finishBattle(withState state: BF_Fight.State) {
		
		if !(isStoryFight ?? true) && state != .Dropout {
			
			BF_Challenge.increase(Challenges.Fights)
		}
		
		super.finishBattle(withState: state)
	}
}
