//
//  BF_Monsters_Alert_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 09/09/2024.
//

import Foundation
import UIKit

public class BF_Monsters_Alert_ViewController : BF_Alert_ViewController {
	
	public var monster:BF_Monster? {
		
		didSet {
			
			stackView.monster = monster
		}
	}
	private lazy var stackView:BF_Monsters_Full_StackView = .init()
	public var dismissButton:BF_Button?
	
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		titleLabel.removeFromSuperview()
		
		add(stackView)
		
		dismissButton = addDismissButton()
	}
	
	required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
