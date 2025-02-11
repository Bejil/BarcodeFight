//
//  BF_Rubies_Alert_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 16/01/2025.
//

import Foundation
import UIKit

public class BF_Rubies_Alert_ViewController : BF_Alert_ViewController {
	
	private var timer:Timer? = nil
	
	deinit {
		
		timer?.invalidate()
		timer = nil
	}
	
	public override func loadView() {
		
		super.loadView()
		
		title = String(key: "rubies.alert.title")
		add(UIImage(named: "items_rubies"))
		
		let count = BF_User.current?.rubies ?? 0
		
		if count == 0 {
			
			add(String(key: "rubies.alert.content.empty"))
		}
		else {
			
			add(String(format: String(key: "rubies.alert.content.default"), count))
		}
		
		add(String(key: "rubies.alert.content.loading"))
		
		let label:BF_Label = .init(BF_Ruby.shared.string)
		label.font = Fonts.Content.Title.H3
		label.textAlignment = .center
		add(label)
		
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
			
			label.text = BF_Ruby.shared.string
		}
		
		addButton(title: String(key: "rubies.alert.button.shop"), image: UIImage(named: "items_rubies")) { [weak self] _ in
			
			self?.close {
				
				UI.MainController.present(BF_NavigationController(rootViewController: BF_Items_Shop_ViewController()), animated: true)
			}
		}
		
		addButton(title: String(key: "rubies.alert.button.ad.title"), subtitle: String(key: "rubies.alert.button.ad.subtitle")) { [weak self] button in
			
			button?.isLoading = true
			
			BF_Ads.shared.presentRewardedInterstitial(BF_Ads.Identifiers.FullScreen.FreeRuby) { [weak self] in
				
				self?.close {
					
					BF_Alert_ViewController.presentLoading() { alertController in
						
						BF_User.current?.rubies += 1
						BF_User.current?.update({ error in
							
							alertController?.close {
								
								if let error {
									
									BF_User.current?.rubies -= 1
									BF_Alert_ViewController.present(error)
								}
								else {
									
									NotificationCenter.post(.updateAccount)
									
									let alertController:BF_Alert_ViewController = .init()
									alertController.title = String(key: "rubies.success.alert.title")
									alertController.add(UIImage(named: "items_rubies"))
									alertController.add(String(key: "rubies.success.alert.content"))
									alertController.addDismissButton()
									alertController.present()
								}
							}
						})
					}
				}
			}
		}
		
		addDismissButton()
	}
}
