//
//  BF_User_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 15/08/2023.
//

import Foundation
import UIKit
import FirebaseFirestore

public class BF_User_StackView : UIStackView {
	
	public var user:BF_User? {
		
		didSet {
			
			stackView.user = user
			rubiesStackView.user = user
			scansStackView.user = user
		}
	}
	private lazy var stackView:BF_User_Opponent_StackView = {
		
		$0.imageView.snp.makeConstraints { make in
			make.size.equalTo(1.5*UI.Margins)
		}
		$0.fightsStackView.isHidden = true
		
		return $0
		
	}(BF_User_Opponent_StackView())
	private lazy var rubiesStackView:BF_Rubies_StackView = .init()
	public lazy var rubiesProgressView:UIProgressView = {
		
		let height = UI.Margins/2
		
		$0.progressViewStyle = .bar
		$0.progressTintColor = Colors.Primary.withAlphaComponent(0.5)
		$0.trackTintColor = Colors.Primary.withAlphaComponent(0.1)
		$0.layer.cornerRadius = height/2
		$0.clipsToBounds = true
		$0.layer.sublayers?.first?.cornerRadius = $0.layer.cornerRadius
		$0.subviews.first?.clipsToBounds = $0.clipsToBounds
		$0.snp.makeConstraints { make in
			make.height.equalTo(height)
		}
		
		nextRubyTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			
			self?.rubiesProgressView.setProgress(BF_Ruby.shared.progress, animated: true)
		}
		
		return $0
		
	}(UIProgressView())
	private lazy var scansStackView:BF_Scans_StackView = .init()
	public lazy var scansProgressView:UIProgressView = {
		
		let height = UI.Margins/2
		
		$0.progressViewStyle = .bar
		$0.progressTintColor = Colors.Primary.withAlphaComponent(0.5)
		$0.trackTintColor = Colors.Primary.withAlphaComponent(0.1)
		$0.layer.cornerRadius = height/2
		$0.clipsToBounds = true
		$0.layer.sublayers?.first?.cornerRadius = $0.layer.cornerRadius
		$0.subviews.first?.clipsToBounds = $0.clipsToBounds
		$0.snp.makeConstraints { make in
			make.height.equalTo(height)
		}
		
		nextScanTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			
			self?.scansProgressView.setProgress(BF_Scan.shared.progress, animated: true)
		}
		
		return $0
		
	}(UIProgressView())
	private var nextRubyTimer:Timer?
	private var nextScanTimer:Timer?
	
	deinit {
		
		nextRubyTimer?.invalidate()
		nextRubyTimer = nil
		
		nextScanTimer?.invalidate()
		nextScanTimer = nil
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .vertical
		spacing = UI.Margins/5
		
		addArrangedSubview(stackView)
		setCustomSpacing(UI.Margins/2, after: stackView)
		
		let infoButton:(()->BF_Button) = {
			
			let button:BF_Button = .init()
			button.isUserInteractionEnabled = false
			button.image = UIImage(systemName: "info.circle.fill")?.applyingSymbolConfiguration(.init(scale: .small))
			button.isText = true
			button.style = .transparent
			button.configuration?.contentInsets = .zero
			button.configuration?.imagePadding = 0
			button.snp.makeConstraints { make in
				make.size.equalTo(UI.Margins)
			}
			return button
		}
		
		let rubiesStackView:UIStackView = .init(arrangedSubviews: [self.rubiesStackView,rubiesProgressView,infoButton()])
		rubiesStackView.axis = .horizontal
		rubiesStackView.alignment = .center
		rubiesStackView.spacing = UI.Margins/2
		rubiesStackView.addGestureRecognizer(UITapGestureRecognizer(block: { _ in
			
			UIApplication.feedBack(.On)
			
			let alertController:BF_Alert_ViewController = .init()
			alertController.title = String(key: "fights.ruby.loading.alert.title")
			alertController.add(UIImage(named: "items_rubies"))
			alertController.add(String(key: "fights.ruby.error.alert.label.1"))
			
			let nextRubyAlertControllerLabel:BF_Label = .init(BF_Ruby.shared.nextRubyString)
			nextRubyAlertControllerLabel.font = Fonts.Content.Title.H3
			nextRubyAlertControllerLabel.textAlignment = .center
			alertController.add(nextRubyAlertControllerLabel)
			
			var nextFreeRubyTimer:Timer? = nil
			nextFreeRubyTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
				
				nextRubyAlertControllerLabel.text = BF_Ruby.shared.nextRubyString
			}
			
			alertController.addButton(title: String(key: "fights.ruby.error.alert.button"), image: UIImage(named: "items_rubies")) { _ in
				
				alertController.close {
					
					UI.MainController.present(BF_NavigationController(rootViewController: BF_Items_Shop_ViewController()), animated: true)
				}
			}
			alertController.addDismissButton()
			alertController.present(as: .Sheet)
			alertController.dismissHandler = {
				
				nextFreeRubyTimer?.invalidate()
				nextFreeRubyTimer = nil
			}
		}))
		addArrangedSubview(rubiesStackView)
		
		let scansStackView:UIStackView = .init(arrangedSubviews: [self.scansStackView,scansProgressView,infoButton()])
		scansStackView.axis = .horizontal
		scansStackView.alignment = .center
		scansStackView.spacing = UI.Margins/2
		scansStackView.addGestureRecognizer(UITapGestureRecognizer(block: { _ in
			
			UIApplication.feedBack(.On)
			
			let alertController:BF_Alert_ViewController = .init()
			alertController.add(UIImage(named: "scan_icon"))
			alertController.title = String(key: "monsters.scan.loading.alert.title")
			alertController.add(String(key: "monsters.scan.empty.alert.label.1"))
			
			let nextScanAlertControllerLabel:BF_Label = .init(BF_Scan.shared.nextScanString)
			nextScanAlertControllerLabel.font = Fonts.Content.Title.H3
			nextScanAlertControllerLabel.textAlignment = .center
			alertController.add(nextScanAlertControllerLabel)
			
			var nextFreeScanTimer:Timer? = nil
			nextFreeScanTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
				
				nextScanAlertControllerLabel.text = BF_Scan.shared.nextScanString
			}
			
			alertController.addButton(title: String(key: "monsters.scan.empty.button"), image: UIImage(named: "scan_icon")) { _ in
				
				alertController.close {
					
					UI.MainController.present(BF_NavigationController(rootViewController: BF_Items_Shop_ViewController()), animated: true)
				}
			}
			alertController.addDismissButton()
			alertController.present(as: .Sheet)
			alertController.dismissHandler = {
				
				nextFreeScanTimer?.invalidate()
				nextFreeScanTimer = nil
			}
		}))
		addArrangedSubview(scansStackView)
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
