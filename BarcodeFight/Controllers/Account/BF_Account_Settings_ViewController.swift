//
//  BF_Account_Settings_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 07/08/2023.
//

import Foundation
import UIKit

public class BF_Account_Settings_ViewController : BF_ViewController {
	
	private var user:BF_User? {
		
		didSet {
			
			profilePictureImageView.user = user
			
			credentialsStackView.isHidden = BF_Account.shared.signInType != .Email
			
			displayNameDidChange = false
			displayNameTextField.text = BF_User.current?.displayName
			
			emailDidChange = false
			emailTextField.text = BF_Account.shared.user?.email
			
			passwordDidChange = false
			passwordTextField.text = BF_Account.shared.isLoggedIn ? String.randomPassword : nil
			passwordValidationStackView.isHidden = true
			passwordValidationStackView.password = nil
			
			button.isEnabled = false
		}
	}
	private lazy var credentialsStackView:UIStackView = {
		
		$0.axis = .vertical
		$0.spacing = UI.Margins
		
		$0.addArrangedSubview(emailTextField)
		var emailDidChange:Bool = false
		
		$0.addArrangedSubview(passwordTextField)
		var passwordDidChange:Bool = false
		
		$0.addArrangedSubview(passwordValidationStackView)
		
		return $0
		
	}(UIStackView())
	private lazy var profilePictureView:UIView = {
		
		$0.addSubview(profilePictureImageView)
		profilePictureImageView.snp.makeConstraints { make in
			make.center.height.equalToSuperview()
		}
		return $0
		
	}(UIView())
	private lazy var profilePictureImageView:BF_User_ImageView = {
		
		$0.isUserInteractionEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary) || UIImagePickerController.isSourceTypeAvailable(.camera)
		$0.snp.makeConstraints { make in
			make.size.equalTo(12*UI.Margins)
		}
		
		let libraryState = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
		let cameraState = UIImagePickerController.isSourceTypeAvailable(.camera)
		
		if libraryState || cameraState {
			
			let label:BF_Label = .init(String(key: "account.settings.picture.button"))
			label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
			label.textAlignment = .center
			label.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-2)
			label.textColor = .white
			$0.addSubview(label)
			label.snp.makeConstraints { make in
				make.width.bottom.centerX.equalToSuperview()
				make.height.equalToSuperview().multipliedBy(0.2)
			}
			$0.addGestureRecognizer(UITapGestureRecognizer(block: { gestureRecognizer in
				
				let alertController:BF_Alert_ViewController = .init()
				alertController.title = String(key: "account.settings.picture.alert.title")
				alertController.add(String(key: "account.settings.picture.alert.label"))
				
				if libraryState {
					
					alertController.addButton(title: String(key: "account.settings.picture.alert.library")) { [weak self] _ in
						
						alertController.close { [weak self] in
							
							self?.promptImagePicker(sourceType: .photoLibrary)
						}
					}
				}
				
				if cameraState {
					
					alertController.addButton(title: String(key: "account.settings.picture.alert.camera")) { [weak self] _ in
						
						alertController.close { [weak self] in
							
							self?.promptImagePicker(sourceType: .camera)
						}
					}
				}
				
				alertController.addCancelButton()
				alertController.present(as: .Sheet)
			}))
		}
		return $0
		
	}(BF_User_ImageView())
	private var displayNameDidChange:Bool = false
	private lazy var displayNameTextField:BF_TextField = {
		
		$0.isMandatory = true
		$0.placeholder = String(key: "account.settings.displayName.placeholder")
		$0.changeHandler = { [weak self] _ in
			
			self?.displayNameDidChange = true
			self?.updateButton()
		}
		return $0
		
	}(BF_TextField())
	private var emailDidChange:Bool = false
	private lazy var emailTextField:BF_TextField = {
		
		$0.isMandatory = true
		$0.type = .email
		$0.placeholder = String(key: "account.settings.email.placeholder")
		$0.changeHandler = { [weak self] _ in
			
			self?.emailDidChange = true
			self?.updateButton()
		}
		return $0
		
	}(BF_TextField())
	private var passwordDidChange:Bool = false
	private lazy var passwordTextField:BF_TextField = {
		
		$0.isMandatory = true
		$0.type = .password
		$0.placeholder = String(key: "account.settings.password.placeholder")
		$0.changeHandler = { [weak self] _ in
			
			self?.passwordDidChange = true
			self?.passwordValidationStackView.password = self?.passwordTextField.text
			self?.updateButton()
		}
		return $0
		
	}(BF_TextField())
	private lazy var passwordValidationStackView:BF_Account_PasswordValidation_StackView = .init()
	private lazy var button:BF_Button = .init(String(key: "account.settings.placeholder.button")) { [weak self] button in
		
		UIApplication.hideKeyboard()
		
		let updateClosure:((BF_Button?)->Void) = { button in
			
			button?.isLoading = true
			
			var errors:[Error?] = .init()
			let taskGroup = DispatchGroup()
			
			if self?.displayNameDidChange ?? false {
				
				taskGroup.enter()
				
				BF_User.current?.displayName = self?.displayNameTextField.text
				BF_User.current?.update { error in
					
					errors.append(error)
					taskGroup.leave()
				}
			}
			
			if self?.emailDidChange ?? false {
				
				taskGroup.enter()
				
				BF_Account.shared.update(email: self?.emailTextField.text) { error in
					
					errors.append(error)
					taskGroup.leave()
				}
			}
			
			if self?.passwordDidChange ?? false {
				
				taskGroup.enter()
				
				BF_Account.shared.update(password: self?.passwordTextField.text) { error in
					
					errors.append(error)
					taskGroup.leave()
				}
			}
			
			taskGroup.notify(queue: .main) {
				
				button?.isLoading = false
				
				if !errors.allSatisfy({ $0 == nil }) {
					
					BF_Alert_ViewController.present(BF_Error(String(key: "account.settings.reautenticate.update.alert.error")))
				}
				else {
					
					NotificationCenter.post(.updateAccount)
					BF_Toast_Manager.shared.addToast(title: String(key: "account.settings.reautenticate.update.toast.title"), subtitle: String(key: "account.settings.reautenticate.update.toast.subtitle"), style: .Success)
				}
			}
		}
		
		if self?.emailDidChange ?? false || self?.passwordDidChange ?? true {
			
			let alertController:BF_Alert_ViewController = .init()
			alertController.title = String(key: "account.settings.reautenticate.update.alert.title")
			alertController.add(String(key: "account.settings.reautenticate.update.alert.label"))
			
			let reauthenticatePasswordTextField:BF_TextField = .init()
			reauthenticatePasswordTextField.isMandatory = true
			reauthenticatePasswordTextField.type = .password
			reauthenticatePasswordTextField.placeholder = String(key: "account.settings.reautenticate.update.alert.password.placeholder")
			alertController.add(reauthenticatePasswordTextField)
			
			let reauthenticatePasswordValidationStackView:BF_Account_PasswordValidation_StackView = .init()
			alertController.add(reauthenticatePasswordValidationStackView)
			
			let button = alertController.addButton(title: String(key: "account.settings.reautenticate.update.alert.button")) { [weak self] reauthenticateButton in
				
				reauthenticateButton?.isLoading = true
				
				BF_Account.shared.reauthenticate(with: reauthenticatePasswordTextField.text) { [weak self] error in
					
					reauthenticateButton?.isLoading = false
					
					alertController.close() { [weak self] in
						
						if let error = error {
							
							BF_Alert_ViewController.present(error)
						}
						else {
							
							updateClosure(button)
						}
					}
				}
			}
			
			reauthenticatePasswordTextField.changeHandler = { _ in
				
				reauthenticatePasswordValidationStackView.password = reauthenticatePasswordTextField.text
				button.isEnabled = reauthenticatePasswordTextField.text?.isValidPassword ?? false
			}
			
			reauthenticatePasswordTextField.changeHandler?(reauthenticatePasswordTextField)
			
			alertController.addCancelButton()
			alertController.present()
		}
		else {
			
			updateClosure(button)
		}
	}
	private lazy var placeholderView:BF_Placeholder_View = {
		
		$0.isCentered = false
		$0.contentStackView.addArrangedSubview(profilePictureView)
		$0.addLabel(String(key: "account.settings.placeholder.label"))
		$0.contentStackView.addArrangedSubview(displayNameTextField)
		$0.contentStackView.addArrangedSubview(credentialsStackView)
		$0.contentStackView.addArrangedSubview(button)
		
		let deleteButton = $0.addButton(String(key: "account.settings.delete.button")) { button in
			
			let alertController:BF_Alert_ViewController = .init()
			alertController.title = String(key: "account.settings.delete.alert.title")
			alertController.add(UIImage(named: "placeholder_delete"))
			alertController.add(String(key: "account.settings.delete.alert.label"))
			let deleteAlertButton = alertController.addButton(title: String(key: "account.settings.delete.alert.button")) { deleteAlertButton in
				
				alertController.close() {
					
					let deleteClosure:((BF_Button?)->Void) = { button in
						
						button?.isLoading = true
						
						BF_Account.shared.delete { error in
							
							button?.isLoading = false
							
							if let error = error {
								
								BF_Alert_ViewController.present(error)
							}
							else {
								
								NotificationCenter.post(.updateAccount)
								NotificationCenter.post(.updateMonsters)
								NotificationCenter.post(.updateChallenges)
								
								BF_Toast_Manager.shared.addToast(title: String(key: "account.settings.reautenticate.delete.toast.title"), subtitle: String(key: "account.settings.reautenticate.delete.toast.subtitle"), style: .Success)
							}
						}
					}
					
					if BF_Account.shared.signInType == .Email {
						
						let alertController:BF_Alert_ViewController = .init()
						alertController.title = String(key: "account.settings.reautenticate.delete.alert.title")
						alertController.add(String(key: "account.settings.reautenticate.delete.alert.label"))
						
						let reauthenticatePasswordTextField:BF_TextField = .init()
						reauthenticatePasswordTextField.isMandatory = true
						reauthenticatePasswordTextField.type = .password
						reauthenticatePasswordTextField.placeholder = String(key: "account.settings.reautenticate.delete.alert.password.placeholder")
						alertController.add(reauthenticatePasswordTextField)
						
						let reauthenticatePasswordValidationStackView:BF_Account_PasswordValidation_StackView = .init()
						alertController.add(reauthenticatePasswordValidationStackView)
						
						let button = alertController.addButton(title: String(key: "account.settings.reautenticate.delete.alert.button")) { reauthenticateButton in
							
							reauthenticateButton?.isLoading = true
							
							BF_Account.shared.reauthenticate(with: reauthenticatePasswordTextField.text) { error in
								
								reauthenticateButton?.isLoading = false
								
								alertController.close() {
									
									if let error = error {
										
										BF_Alert_ViewController.present(error)
									}
									else {
										
										deleteClosure(button)
									}
								}
							}
						}
						
						reauthenticatePasswordTextField.changeHandler = { _ in
							
							reauthenticatePasswordValidationStackView.password = reauthenticatePasswordTextField.text
							button.isEnabled = reauthenticatePasswordTextField.text?.isValidPassword ?? false
						}
						
						reauthenticatePasswordTextField.changeHandler?(reauthenticatePasswordTextField)
						
						alertController.addCancelButton()
						alertController.present()
					}
					else if BF_Account.shared.signInType == .Apple {
						
						BF_Account.shared.reauthenticateWithApple { error in
							
							if let error = error {
								
								BF_Alert_ViewController.present(error)
							}
							else {
								
								deleteClosure(deleteAlertButton)
							}
						}
					}
					else if BF_Account.shared.signInType == .Google {
						
						BF_Account.shared.reauthenticateWithGoogle { error in
							
							if let error = error {
								
								BF_Alert_ViewController.present(error)
							}
							else {
								
								deleteClosure(deleteAlertButton)
							}
						}
					}
				}
			}
			deleteAlertButton.isDelete = true
			alertController.addCancelButton()
			alertController.present()
		}
		deleteButton.style = .transparent
		deleteButton.isDelete = true
		deleteButton.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size-2)
		deleteButton.configuration?.contentInsets = .zero
		return $0
		
	}(BF_Placeholder_View())
	private lazy var bannerView = BF_Ads.shared.presentBanner(BF_Ads.Identifiers.Banner.AccountSettings, self)
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.title = String(key: "account.settings.title")
		
		navigationItem.rightBarButtonItem = .init(title: String(key: "account.settings.signOut.button"), primaryAction: .init(handler: { _ in
			
			BF_Account.shared.signOut { error in
				
				if let error = error {
					
					BF_Alert_ViewController.present(error)
				}
				else {
					
					NotificationCenter.post(.updateAccount)
					NotificationCenter.post(.updateMonsters)
					NotificationCenter.post(.updateChallenges)
					
					BF_Toast_Manager.shared.addToast(title: String(key: "account.settings.signOut.toast.title"), subtitle: String(key: "account.settings.signOut.toast.subtitle"), style: .Success)
				}
			}
		}))
		
		let stackView:UIStackView = .init(arrangedSubviews: [placeholderView])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
		
		if let bannerView {
			
			stackView.addArrangedSubview(bannerView)
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		launchRequest()
		
		bannerView?.isHidden = !BF_Ads.shared.shouldDisplayAd
	}
	
	private func launchRequest() {
		
		view.showPlaceholder(.Loading)
		
		BF_User.get { [weak self] error in
			
			self?.view.dismissPlaceholder()
			
			if let error = error {
				
				self?.view.showPlaceholder(.Error,error) { [weak self] _ in
					
					self?.view.dismissPlaceholder()
					self?.launchRequest()
				}
			}
			else {
				
				NotificationCenter.post(.updateAccount)
				self?.user = BF_User.current
			}
		}
	}
	
	private func updateButton() {
		
		button.isEnabled =
		(displayNameDidChange && (displayNameTextField.text?.isValidDisplayName ?? false)) ||
		(emailDidChange && (emailTextField.text?.isValidEmail ?? false)) ||
		(passwordDidChange && (passwordTextField.text?.isValidPassword ?? false))
	}
	
	private func promptImagePicker(sourceType: UIImagePickerController.SourceType) {
		
		if UIImagePickerController.isSourceTypeAvailable(sourceType) {
			
			BF_Authorizations.shared.askIfNeeded(sourceType == .camera ? .camera : .photoLibrary) { [weak self] state in
				
				let imagePickerController: UIImagePickerController = .init()
				imagePickerController.sourceType = sourceType
				imagePickerController.delegate = self
				UI.MainController.present(imagePickerController, animated: true, completion: nil)
			}
		}
	}
}

extension BF_Account_Settings_ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		
		picker.presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
	public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		picker.presentingViewController?.dismiss(animated: true, completion: nil)
		
		profilePictureImageView.showLoadingIndicatorView()
		
		let image = (info[.originalImage] as? UIImage)?.scalePreservingAspectRatio(targetSize: .init(width: 150, height: 150))
		
		BF_User.update(profilePicture: image) { [weak self] error in
			
			self?.profilePictureImageView.dismissLoadingIndicatorView()
			
			if let error = error {
				
				BF_Alert_ViewController.present(error)
			}
			else{
				
				NotificationCenter.post(.updateAccount)
				self?.profilePictureImageView.image = image
			}
		}
	}
}
