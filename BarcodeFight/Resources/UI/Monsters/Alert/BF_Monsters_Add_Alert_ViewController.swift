//
//  BF_Monsters_Add_Alert_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 10/09/2024.
//

import Foundation
import UIKit

public class BF_Monsters_Add_Alert_ViewController : BF_Monsters_Alert_ViewController {
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		backgroundView.isUserInteractionEnabled = false
		dismissButton?.removeFromSuperview()
		
		addButton(sticky: true, title: String(key: "monsters.add.button")) { _ in
			
		}
		addCancelButton(sticky: true)
	}
	
	required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
