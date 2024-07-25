//
//  BF_Account_SignUp_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 10/05/2023.
//

import Foundation
import UIKit

public class BF_Account_SignUp_ViewController : BF_ViewController {
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.title = String(key: "onboarding.signUp.title")
		
		let placeholderView = view.showPlaceholder()
		placeholderView.isCentered = false
		placeholderView.title = String(key: "onboarding.signUp.title")
		placeholderView.image = UIImage(named: "placeholder_welcome")
		placeholderView.addLabel(String(key: "onboarding.signUp.label"))
		
		let emailTextField:BF_TextField = .init()
		emailTextField.isMandatory = true
		emailTextField.type = .email
		
		if UIApplication.isDebug {
			
			emailTextField.text = "michou855@hotmail.com"
		}
		
		emailTextField.placeholder = String(key: "onboarding.signUp.email.placeholder")
		placeholderView.contentStackView.addArrangedSubview(emailTextField)
		
		let passwordTextField:BF_TextField = .init()
		passwordTextField.isMandatory = true
		passwordTextField.type = .password
		
		if UIApplication.isDebug {
			
			passwordTextField.text = "Mich211326#"
		}
		
		passwordTextField.placeholder = String(key: "onboarding.signUp.password.placeholder")
		placeholderView.contentStackView.addArrangedSubview(passwordTextField)
		
		let passwordValidationStackView:BF_Account_PasswordValidation_StackView = .init()
		placeholderView.contentStackView.addArrangedSubview(passwordValidationStackView)
		
		let button = placeholderView.addButton(String(key: "onboarding.signUp.button")) { button in
			
			button?.isLoading = true
			
			BF_Account.shared.createUser(with: emailTextField.text, and: passwordTextField.text) { error in
				
				button?.isLoading = false
				
				if let error = error {
					
					BF_Alert_ViewController.present(error)
				}
				else {
					
					BF_Toast.shared.present(title: String(key: "onboarding.signUp.success.toast.title"), subtitle: String(key: "onboarding.signUp.success.toast.subtitle"), style: .Success)
				}
			}
		}
		
		let validationClosure:(()->Void) = {
			
			button.isEnabled = (emailTextField.text?.isValidEmail) ?? false && (passwordTextField.text?.isValidPassword ?? false)
		}
		
		validationClosure()
		
		emailTextField.changeHandler = { _ in
			
			validationClosure()
		}
		
		passwordTextField.changeHandler = { _ in
			
			passwordValidationStackView.password = passwordTextField.text
			validationClosure()
		}
		
		placeholderView.contentStackView.addArrangedSubview(BF_Account_Social_StackView())
	}
}
