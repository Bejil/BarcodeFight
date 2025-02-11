//
//  BF_Challenges_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 26/08/2024.
//

import Foundation
import UIKit

public class BF_Challenges_View : UIView {
	
	private lazy var titleLabel:BF_Label = {
		
		$0.font = Fonts.Content.Title.H4.withSize(Fonts.Size+1)
		return $0
		
	}(BF_Label())
	private lazy var subtitleLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		return $0
		
	}(BF_Label())
	private var buttonTimer:Timer?
	private lazy var button:BF_Button = {
		
		$0.style = .tinted
		$0.configuration?.contentInsets = .init(horizontal: UI.Margins/3)
		$0.configuration?.imagePadding = 0
		$0.setContentHuggingPriority(.init(1000), for: .horizontal)
		$0.snp.makeConstraints { make in
			make.size.equalTo(3*UI.Margins)
		}
		
		return $0
		
	}(BF_Button())
	
	deinit {
		
		buttonTimer?.invalidate()
		buttonTimer = nil
	}
	
	override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		let visualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .dark))
		visualEffectView.layer.cornerRadius = UI.CornerRadius
		visualEffectView.layer.masksToBounds = true
		addSubview(visualEffectView)
		visualEffectView.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview().inset(UI.Margins)
			make.left.right.equalToSuperview().inset(UI.Margins)
		}
		
		let imageView:BF_ImageView = .init(image: UIImage(named: "challenges_icon"))
		imageView.contentMode = .scaleAspectFit
		imageView.snp.makeConstraints { make in
			make.size.equalTo(2.5*UI.Margins)
		}
		
		let textStackView:UIStackView = .init(arrangedSubviews: [titleLabel,subtitleLabel])
		textStackView.axis = .vertical
		
		let stackView:UIStackView = .init(arrangedSubviews: [imageView,textStackView,button])
		stackView.layer.cornerRadius = UI.CornerRadius
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.spacing = UI.Margins
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.layoutMargins = .init(UI.Margins)
		addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalTo(visualEffectView)
		}
		
		NotificationCenter.add(.updateChallenges) { [weak self] _ in
			
			self?.updateChallenges()
		}
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	private func updateChallenges() {
		
		buttonTimer?.invalidate()
		buttonTimer = nil
		
		gestureRecognizers?.removeAll()
		
		showLoadingIndicatorView()
		
		BF_Challenge.get { [weak self] challenges, _ in
			
			self?.dismissLoadingIndicatorView()
			
			self?.button.image = UIImage(systemName: "chevron.forward", withConfiguration: UIImage.SymbolConfiguration(pointSize: Fonts.Size))
			
			self?.addGestureRecognizer(UITapGestureRecognizer(block: { _ in
				
				UI.MainController.present(BF_NavigationController(rootViewController: BF_Challenges_ViewController()), animated: true)
			}))
			
			if let count = challenges?.pending.count {
				
				if count == 0 {
					
					self?.titleLabel.text = String(key: "challenges.header.empty")
					self?.subtitleLabel.text = String(key: "challenges.header.subtitle.empty")
					
					if !Calendar.current.isDate(BF_User.current?.challenges.lastRewardDate ?? Date.distantPast, inSameDayAs: Date()) {
						
						self?.button.image = UIImage(named: "items_chestObjects")?.scalePreservingAspectRatio(targetSize: .init(width: 1.5*UI.Margins, height: 1.5*UI.Margins))
						
						self?.buttonTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
							
							self?.button.pulse(.white)
						})
						
						self?.addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] _ in
							
							self?.button.isLoading = true
							
							BF_Item.get { [weak self] items, error in
								
								self?.button.isLoading = false
								
								if let item = items?.first(where: { $0.uid == Items.ChestObjects }) {
									
									BF_User.current?.items.append(item)
									BF_User.current?.challenges.lastRewardDate = .init()
									
									self?.button.isLoading = true
									
									BF_User.current?.update({ [weak self] error in
										
										self?.button.isLoading = false
										
										if error == nil {
											
											NotificationCenter.post(.updateChallenges)
											
											let alertController:BF_Item_Chest_Objects_Alert_ViewController = .init()
											alertController.present()
										}
									})
								}
							}
						}))
					}
				}
				else {
					
					self?.titleLabel.text = "\(count) " + String(key: "challenges.header.title")
					self?.subtitleLabel.text = String(key: "challenges.header.subtitle")
				}
			}
		}
	}
}
