//
//  BF_Account_Social_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 05/08/2021.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices

public class BF_Account_Social_StackView: UIStackView {

	private var currentAppleSignInNonce:String?
	private lazy var appleSignInButton:ASAuthorizationAppleIDButton = {
		
		let button:ASAuthorizationAppleIDButton = .init(type: .default, style: .black)
		button.addAction(.init(handler: { [weak self] _ in
			
			self?.appleSignInButton.showLoadingIndicatorView()
			
			BF_Account.shared.signInWithApple { [weak self] error in
				
				self?.appleSignInButton.dismissLoadingIndicatorView()
				
				self?.loginHandler?(nil, error)
			}
			
		}), for: .touchUpInside)
		return button
	}()
	private var loginHandler:((AuthDataResult?,Error?)->Void)? = { authResult, error in
		
		if let error = error {
			
			BF_Alert_ViewController.present(error)
		}
	}
	
	convenience init() {
		
		self.init(frame: .zero)
		
		axis = .horizontal
		spacing = UI.Margins
		distribution = .fillEqually
		
		addArrangedSubview(appleSignInButton)
		
		let googleSignInButton:GIDSignInButton = .init()
		googleSignInButton.addAction(.init(handler: { [weak self] action in
			
			let button = action.sender as? GIDSignInButton
			button?.showLoadingIndicatorView()
			
			BF_Account.shared.signInWithGoogle { [weak self] error in
				
				button?.dismissLoadingIndicatorView()
				
				self?.loginHandler?(nil, error)
			}
			
		}), for: .touchUpInside)
		addArrangedSubview(googleSignInButton)
	}
}
