//
//  BF_Battle_Team_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 19/08/2023.
//

import Foundation
import UIKit

public class BF_Battle_Team_ViewController : BF_Monsters_List_Select_ViewController {
	
	public override var maxNumber:Int {
		
		return BF_Firebase.shared.config.int(.FightMonstersCount)
	}
}
