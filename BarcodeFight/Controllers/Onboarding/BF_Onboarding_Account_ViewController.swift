//
//  BF_Onboarding_Account_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 20/03/2023.
//

import Foundation
import UIKit

public class BF_Onboarding_Account_ViewController : BF_ViewController {
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.title = String(key: "onboarding.placeholder.title")
		
		let placeholderView:BF_Placeholder_View = view.showPlaceholder()
		placeholderView.title = String(key: "onboarding.placeholder.title")
		placeholderView.image = UIImage(named: "placeholder_welcome")
		placeholderView.addLabel(String(key: "onboarding.placeholder.label"))
		
		let signInButton:BF_Button = .init(String(key: "onboarding.placeholder.signIn.button")) { [weak self] _ in
			
			self?.navigationController?.pushViewController(BF_Account_SignIn_ViewController(), animated: true)
		}
		signInButton.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size)
		signInButton.style = .tinted
		
		let signUpButton:BF_Button = .init(String(key: "onboarding.placeholder.signUp.button")) { [weak self] _ in
			
			self?.navigationController?.pushViewController(BF_Account_SignUp_ViewController(), animated: true)
		}
		signUpButton.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size)
		
		let stackView:UIStackView = .init(arrangedSubviews: [signInButton,signUpButton])
		stackView.axis = .horizontal
		stackView.spacing = UI.Margins
		stackView.alignment = .fill
		placeholderView.contentStackView.addArrangedSubview(stackView)
		
		placeholderView.contentStackView.addArrangedSubview(BF_Account_Social_StackView())
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		navigationController?.setNavigationBarHidden(true, animated: true)
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		navigationController?.setNavigationBarHidden(false, animated: true)
	}
}
