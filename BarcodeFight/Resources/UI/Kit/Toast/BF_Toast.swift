	//
	//  BF_Toast.swift
	//  BarcodeFight
	//
	//  Created by BLIN Michael on 14/08/2023.
	//

import Foundation
import UIKit

public class BF_Toast : UIStackView {
	
	public enum Style {
		
		case Success
		case Warning
		case Error
		case None
	}
	
	public static let shared:BF_Toast = .init()
	private lazy var imageView:BF_ImageView = {
		
		$0.contentMode = .scaleAspectFit
		$0.snp.makeConstraints { make in
			make.size.equalTo(2*UI.Margins)
		}
		return $0
		
	}((BF_ImageView()))
	private lazy var titleLabel:BF_Label = {
		
		$0.font = Fonts.Content.Title.H4
		return $0
		
	}(BF_Label())
	private lazy var subtitleLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular
		return $0
		
	}(BF_Label())
	
	public override init(frame: CGRect) {
		
		super.init(frame: .zero)
		
		let visualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .regular))
		visualEffectView.layer.cornerRadius = (4*UI.Margins)/2.5
		visualEffectView.clipsToBounds = true
		addSubview(visualEffectView)
		visualEffectView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		axis = .horizontal
		spacing = UI.Margins
		alignment = .center
		isLayoutMarginsRelativeArrangement = true
		layoutMargins = .init(horizontal: UI.Margins, vertical: UI.Margins/2)
		
		layer.shadowOffset = .zero
		layer.shadowRadius = 1.5*UI.Margins
		layer.shadowOpacity = 0.25
		layer.masksToBounds = false
		layer.cornerRadius = (4*UI.Margins)/2.5
		layer.shadowColor = Colors.Content.Text.cgColor
		
		addArrangedSubview(imageView)
		
		let textStackView:UIStackView = .init(arrangedSubviews: [titleLabel,subtitleLabel])
		textStackView.axis = .vertical
		addArrangedSubview(textStackView)
		
		let swipeGestureRecognizer:UISwipeGestureRecognizer = .init { [weak self] _ in
			
			self?.dismiss()
		}
		swipeGestureRecognizer.direction = .up
		addGestureRecognizer(swipeGestureRecognizer)
		
		registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
			
			self.layer.shadowColor = Colors.Content.Text.cgColor
		})
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public func present(title:String, subtitle:String? = nil, image:UIImage? = nil, style:Style? = .None) {
		
		if let window = (UIApplication.shared.delegate as? AppDelegate)?.window {
			
			switch style {
				
			case .Success:
				BF_Audio.shared.playSuccess()
				UIApplication.feedBack(.Success)
				imageView.tintColor = Colors.Button.Primary.Background
				imageView.image = UIImage(systemName: "hand.thumbsup.circle.fill")
			case .Warning:
				BF_Audio.shared.playError()
				UIApplication.feedBack(.Off)
				imageView.tintColor = Colors.Button.Primary.Background
				imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
			case .Error:
				BF_Audio.shared.playError()
				UIApplication.feedBack(.Error)
				imageView.tintColor = Colors.Button.Primary.Background
				imageView.image = UIImage(systemName: "xmark.circle.fill")
			default:
				UIApplication.feedBack(.On)
				imageView.image = nil
			}
			
			titleLabel.text = title
			subtitleLabel.text = subtitle
			
			dismiss {
			
				window.addSubview(self)
				
				self.layoutIfNeeded()
				
				self.snp.makeConstraints { make in
					make.centerX.equalToSuperview()
					make.top.equalTo(window.safeAreaLayoutGuide).inset(UI.Margins)
					make.width.lessThanOrEqualToSuperview().inset(UI.Margins)
					make.size.greaterThanOrEqualTo(4*UI.Margins)
				}
				
				UIView.animate {
					
					self.alpha = 1.0
				}
				
				UIApplication.wait(4.0) { [weak self] in
					
					self?.dismiss()
				}
			}
		}
	}
	
	private func dismiss(_ completion:(()->Void)? = nil) {
		
		UIView.animate(0.3, {
			
			self.alpha = 0.0
			
		}, {
			
			self.removeFromSuperview()
			
			completion?()
		})
	}
}
