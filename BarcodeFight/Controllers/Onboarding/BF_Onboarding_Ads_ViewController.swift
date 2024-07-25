//
//  BF_Onboarding_Ads_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 10/06/2024.
//

import Foundation
import UIKit

public class BF_Onboarding_Ads_ViewController : BF_ViewController {
	
	public lazy var placeholderView:BF_Placeholder_View = {
		
		$0.titleLabel.font = Fonts.Content.Title.H1.withSize(Fonts.Size+25)
		$0.title = String(key: "onboarding.ads.placeholder.title")
		$0.image = UIImage(named: "items_removeAds")
		$0.addLabel(String(key: "onboarding.ads.placeholder.content.0"))
		$0.addLabel(String(key: "onboarding.ads.placeholder.content.1"))
		$0.addButton(String(key: "onboarding.ads.placeholder.button")) { [weak self] _ in
			
			self?.dismiss({
				
				UI.MainController.present(BF_NavigationController(rootViewController: BF_Items_Shop_ViewController()), animated: true)
			})
		}
		return $0
		
	}(BF_Placeholder_View())
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.title = String(key: "onboarding.ads.title")
		
		view.addSubview(placeholderView)
		placeholderView.snp.makeConstraints { make in
			
			make.top.right.left.equalTo(view.safeAreaLayoutGuide)
			make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
		}
	}
}
