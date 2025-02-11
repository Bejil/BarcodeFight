//
//  BF_Account_DisplayName_Alert_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 22/05/2023.
//

import Foundation
import UIKit

public class BF_Account_DisplayName_Alert_ViewController : BF_Alert_ViewController {
	
	public override func loadView() {
		
		super.loadView()
		
		backgroundView.isUserInteractionEnabled = false
		title = String(key: "account.settings.displayName.alert.title")
		add(String(key: "account.settings.displayName.alert.label"))
		
		let textField:BF_TextField = .init()
		textField.placeholder = String(key: "account.settings.displayName.alert.placeholder")
		add(textField)
		
		let button = addButton(title: String(key: "account.settings.displayName.alert.button")) { [weak self] button in
			
			button?.isLoading = true
			
			BF_User.current?.displayName = textField.text
			BF_User.current?.update { error in
				
				button?.isLoading = false
				
				self?.close() {
					
					if let error = error {
						
						BF_Alert_ViewController.present(error)
					}
					else {
						
						NotificationCenter.post(.updateAccount)
						BF_Toast_Manager.shared.addToast(title: String(key: "account.settings.displayName.toast.title"), subtitle: String(key: "account.settings.displayName.toast.subtitle"), style: .Success)
					}
				}
			}
		}
		button.isEnabled = false
		
		textField.changeHandler = { textField in
			
			button.isEnabled = textField?.text?.isValidDisplayName ?? false
		}
	}
}
