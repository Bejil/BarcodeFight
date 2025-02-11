	//
	//  BF_Toast.swift
	//  BarcodeFight
	//
	//  Created by BLIN Michael on 14/08/2023.
	//

import Foundation
import UIKit

public class BF_Toast_Manager: NSObject {
	
	public enum Style {
		
		case Success
		case Warning
		case Error
		case None
	}
	
	public static let shared:BF_Toast_Manager = .init()
	private lazy var toastsStackView:UIStackView = {
		
		$0.axis = .vertical
		$0.alignment = .center
		$0.spacing = UI.Margins
		return $0
		
	}(UIStackView())
	
	public override init() {
		
		super.init()
		
		if let keyWindow = UIApplication.shared.connectedScenes
			.compactMap({ $0 as? UIWindowScene })
			.flatMap({ $0.windows })
			.first(where: { $0.isKeyWindow }) {
			
			keyWindow.addSubview(toastsStackView)
			
			toastsStackView.snp.makeConstraints { make in
				make.top.left.right.equalTo(keyWindow.safeAreaLayoutGuide).inset(UI.Margins)
			}
		}
	}
	
	public func addToast(title:String? = nil, subtitle:String? = nil, image:UIImage? = nil, style:Style? = .None, customView:UIView? = nil) {
		
		let stackView:UIStackView = .init()
		stackView.axis = .horizontal
		stackView.spacing = UI.Margins
		stackView.alignment = .center
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.layoutMargins = .init(horizontal: UI.Margins, vertical: 3*UI.Margins/4)
		stackView.layer.shadowOffset = .zero
		stackView.layer.shadowRadius = 1.5*UI.Margins
		stackView.layer.shadowOpacity = 0.25
		stackView.layer.masksToBounds = false
		stackView.layer.cornerRadius = (4*UI.Margins)/2.5
		stackView.layer.shadowColor = Colors.Content.Text.cgColor
		stackView.alpha = 0.0
		stackView.isHidden = true
		toastsStackView.insertArrangedSubview(stackView, at: toastsStackView.arrangedSubviews.count)
		toastsStackView.layoutIfNeeded()
		
		let visualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .regular))
		visualEffectView.layer.cornerRadius = (4*UI.Margins)/2.5
		visualEffectView.clipsToBounds = true
		stackView.addSubview(visualEffectView)
		visualEffectView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		var lc_image = image
		
		switch style {
			
		case .Success:
			BF_Audio.shared.playSuccess()
			UIApplication.feedBack(.Success)
			lc_image = UIImage(systemName: "hand.thumbsup.circle.fill")
		case .Warning:
			BF_Audio.shared.playError()
			UIApplication.feedBack(.Off)
			lc_image = UIImage(systemName: "exclamationmark.triangle.fill")
		case .Error:
			BF_Audio.shared.playError()
			UIApplication.feedBack(.Error)
			lc_image = UIImage(systemName: "xmark.circle.fill")
		default:
			BF_Audio.shared.playOn()
			UIApplication.feedBack(.On)
			lc_image = nil
		}
		
		if let lc_image {
			
			let imageView:BF_ImageView = .init(image: lc_image)
			imageView.tintColor = Colors.Content.Text
			imageView.contentMode = .scaleAspectFit
			imageView.snp.makeConstraints { make in
				make.size.equalTo(2*UI.Margins)
			}
			
			stackView.addArrangedSubview(imageView)
		}
		
		let contentStackView:UIStackView = .init()
		contentStackView.axis = .vertical
		contentStackView.spacing = UI.Margins/3
		stackView.addArrangedSubview(contentStackView)
		
		if let title {
			
			let titleLabel:BF_Label = .init(title)
			titleLabel.font = Fonts.Content.Title.H4
			contentStackView.addArrangedSubview(titleLabel)
		}
		
		if let subtitle {
			
			let subtitleLabel:BF_Label = .init(subtitle)
			subtitleLabel.font = Fonts.Content.Text.Regular
			contentStackView.addArrangedSubview(subtitleLabel)
		}
		
		if let customView {
			
			contentStackView.addArrangedSubview(customView)
		}
		
		func dismiss() {
			
			UIView.animate(0.3, {
				
				stackView.alpha = 0.0
				stackView.isHidden = true
				stackView.superview?.layoutIfNeeded()
				self.toastsStackView.layoutIfNeeded()
				
			}, {
				
				stackView.removeFromSuperview()
			})
		}
		
		let dismissGestureRecognier:UISwipeGestureRecognizer = .init { _ in
			
			dismiss()
		}
		dismissGestureRecognier.direction = .up
		stackView.addGestureRecognizer(dismissGestureRecognier)
		
		UIView.animate(0.3, {
			
			stackView.alpha = 1.0
			stackView.isHidden = false
			stackView.superview?.layoutIfNeeded()
			self.toastsStackView.layoutIfNeeded()
			
		}, {
			
			UIApplication.wait(4.0) {
				
				dismiss()
			}
		})
	}
}
