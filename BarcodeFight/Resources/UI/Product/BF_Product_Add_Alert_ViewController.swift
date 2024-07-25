//
//  BF_Product_Add_Alert_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 19/07/2024.
//

import Foundation
import UIKit

public class BF_Product_Add_Alert_ViewController : BF_Alert_ViewController {
	
	public var completion:((String?,UIImage?)->Void)?
	private lazy var nameTextField:BF_TextField = {
		
		$0.placeholder = String(key: "monsters.product.add.alert.placeholder")
		return $0
		
	}(BF_TextField())
	private lazy var imageView:BF_ImageView = {
		
		$0.isHidden = true
		$0.contentMode = .scaleAspectFit
		$0.snp.makeConstraints { make in
			make.size.height.equalTo(200)
		}
		return $0
		
	}(BF_ImageView())
	private var button:BF_Button?
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = String(key: "monsters.product.add.alert.title")
		add(String(key: "monsters.product.add.alert.content"))
		add(imageView)
		
		let libraryState = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
		let cameraState = UIImagePickerController.isSourceTypeAvailable(.camera)
		
		if libraryState || cameraState {
			
			let buttonsStackView:UIStackView = .init()
			buttonsStackView.axis = .horizontal
			buttonsStackView.spacing = UI.Margins
			buttonsStackView.distribution = .fillEqually
			buttonsStackView.alignment = .center
			add(buttonsStackView)
			
			if libraryState {
				
				let button:BF_Button = .init(String(key: "monsters.product.add.alert.library")) { [weak self] _ in
					
					self?.promptImagePicker(sourceType: .photoLibrary)
				}
				buttonsStackView.addArrangedSubview(button)
			}
			
			if cameraState {
				
				let button:BF_Button = .init(String(key: "monsters.product.add.alert.camera")) { [weak self] _ in
					
					self?.promptImagePicker(sourceType: .camera)
				}
				buttonsStackView.addArrangedSubview(button)
			}
		}
		
		add(nameTextField)
		
		button = addButton(title: String(key: "monsters.product.add.alert.button")) { [weak self] _ in
			
			self?.close({
				
				self?.completion?(self?.nameTextField.text,self?.imageView.image)
			})
		}
		button?.isEnabled = false
		
		nameTextField.changeHandler = { [weak self] _ in
			
			self?.updateButton()
		}
		
		addCancelButton()
	}
	
	required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
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
	
	private func updateButton() {
		
		button?.isEnabled = !(nameTextField.text?.isEmpty ?? true) && imageView.image != nil
	}
}

extension BF_Product_Add_Alert_ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		
		picker.presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
	public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		picker.presentingViewController?.dismiss(animated: true, completion: nil)
		
		let image = (info[.originalImage] as? UIImage)?.scalePreservingAspectRatio(targetSize: .init(width: 150, height: 150))
		imageView.image = image
		
		updateButton()
		
		UIView.animate { [weak self] in
			
			self?.imageView.isHidden = false
			self?.imageView.superview?.layoutIfNeeded()
		}
	}
}

