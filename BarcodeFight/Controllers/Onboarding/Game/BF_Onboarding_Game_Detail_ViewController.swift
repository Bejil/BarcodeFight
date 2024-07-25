//
//  BF_Onboarding_Game_Detail_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 24/05/2024.
//

import Foundation
import UIKit

public class BF_Onboarding_Game_Detail_ViewController : BF_ViewController {
	
	public var index:Int?
	public lazy var placeholderView:BF_Placeholder_View = {
		
		$0.titleLabel.font = Fonts.Content.Title.H1.withSize(Fonts.Size+25)
		return $0
		
	}(BF_Placeholder_View())
	
	public override func loadView() {
		
		super.loadView()
		
		view.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
		
		view.addSubview(placeholderView)
		placeholderView.snp.makeConstraints { make in
			
			make.top.right.left.equalTo(view.safeAreaLayoutGuide)
			make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
		}
	}
}
