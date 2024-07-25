//
//  BF_Account_SignIn_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 10/05/2023.
//

import Foundation
import UIKit

public class BF_Account_SignIn_ViewController : BF_ViewController {
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.title = String(key: "onboarding.signIn.title")
		
		let placeholderView = view.showPlaceholder()
		placeholderView.isCentered = false
		placeholderView.title = String(key: "onboarding.signIn.title")
		placeholderView.image = UIImage(named: "placeholder_welcome")
		placeholderView.addLabel(String(key: "onboarding.signIn.label"))
		
		let emailTextField:BF_TextField = .init()
		emailTextField.isMandatory = true
		emailTextField.type = .email
		
		if UIApplication.isDebug {
			
			emailTextField.text = "michou855@hotmail.com"
		}
		
		emailTextField.placeholder = String(key: "onboarding.signIn.email.placeholder")
		placeholderView.contentStackView.addArrangedSubview(emailTextField)
		
		let passwordTextField:BF_TextField = .init()
		passwordTextField.isMandatory = true
		passwordTextField.type = .password
		
		if UIApplication.isDebug {
			
			passwordTextField.text = "Mich211326#"
		}
		
		passwordTextField.placeholder = String(key: "onboarding.signIn.password.placeholder")
		placeholderView.contentStackView.addArrangedSubview(passwordTextField)
		placeholderView.contentStackView.setCustomSpacing(placeholderView.contentStackView.spacing/2, after: passwordTextField)
		
		let resetPasswordButton:BF_Button = .init(String(key: "onboarding.signIn.password.reset.button")) { _ in
			
			let alertController:BF_Alert_ViewController = .init()
			alertController.title = String(key: "onboarding.signIn.password.reset.alert.title")
			alertController.add(String(key: "onboarding.signIn.password.reset.alert.content"))
			
			let resetEmailTextField:BF_TextField = .init()
			resetEmailTextField.isMandatory = true
			resetEmailTextField.type = .email
			resetEmailTextField.placeholder = String(key: "onboarding.signIn.password.reset.alert.email.placeholder")
			resetEmailTextField.text = emailTextField.text
			alertController.add(resetEmailTextField)
			
			let button = alertController.addButton(title: String(key: "onboarding.signIn.password.reset.alert.button")) { button in
				
				button?.isLoading = true
				
				BF_Account.shared.sendPasswordReset(for: resetEmailTextField.text) { error in
					
					button?.isLoading = false
					
					alertController.close() {
						
						if let error = error {
							
							BF_Alert_ViewController.present(error)
						}
						else {
							
							BF_Toast.shared.present(title: String(key: "onboarding.signIn.password.reset.alert.toast.title"), subtitle: String(key: "onboarding.signIn.password.reset.alert.toast.subtitle"), style: .Success)
						}
					}
				}
			}
			button.isEnabled = emailTextField.text?.isValidEmail ?? false
			
			resetEmailTextField.changeHandler = { _ in
				
				button.isEnabled = resetEmailTextField.text?.isValidEmail ?? false
			}
			
			alertController.addCancelButton()
			alertController.present()
		}
		resetPasswordButton.snp.removeConstraints()
		resetPasswordButton.style = .transparent
		resetPasswordButton.configuration?.contentInsets = .zero
		resetPasswordButton.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size-4)
		resetPasswordButton.configuration?.titleAlignment = .trailing
		placeholderView.contentStackView.addArrangedSubview(resetPasswordButton)
		
		let button = placeholderView.addButton(String(key: "onboarding.signIn.button")) { button in
			
			button?.isLoading = true
			
			BF_Account.shared.signIn(with: emailTextField.text, and: passwordTextField.text) { error in
				
				button?.isLoading = false
				
				if let error = error {
					
					BF_Alert_ViewController.present(error)
				}
				else {
					
					BF_Toast.shared.present(title: String(key: "onboarding.signIn.success.toast.title"), subtitle: String(key: "onboarding.signIn.success.toast.subtitle"), style: .Success)
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
			
			validationClosure()
		}
		
		placeholderView.contentStackView.addArrangedSubview(BF_Account_Social_StackView())
	}
}
