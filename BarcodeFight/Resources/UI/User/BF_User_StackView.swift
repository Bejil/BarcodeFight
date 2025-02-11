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
			
			imageView.url = user?.pictureUrl
			levelLabel.text = "\(user?.level.number ?? 1)"
			displayNameLabel.text = user?.displayName
		}
	}
	private lazy var imageView:BF_ImageView = {
		
		$0.contentMode = .scaleAspectFill
		$0.clipsToBounds = true
		$0.layer.cornerRadius = 3*UI.Margins
		$0.setContentHuggingPriority(.init(1000), for: .horizontal)
		$0.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
		$0.layer.borderColor = UIColor.white.cgColor
		$0.layer.borderWidth = 5.0
		$0.snp.makeConstraints { make in
			make.size.equalTo(UI.Margins*6)
		}
		return $0
		
	}(BF_ImageView(image: UIImage(named: "placeholder_profile")))
	private lazy var levelLabel:BF_Label = {
		
		$0.textAlignment = .center
		$0.font = Fonts.Content.Title.H4
		$0.adjustsFontSizeToFitWidth = true
		$0.minimumScaleFactor = 0.5
		$0.contentInsets = .init(UI.Margins/2)
		$0.layer.cornerRadius = UI.Margins
		$0.snp.makeConstraints { make in
			make.size.equalTo(2*UI.Margins)
		}
		$0.backgroundColor = Colors.Button.Secondary.Background
		$0.layer.borderColor = UIColor.white.cgColor
		$0.layer.borderWidth = 3.0
		return $0
		
	}(BF_Label())
	private lazy var displayNameLabel:BF_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.numberOfLines = 1
		return $0
		
	}(BF_Label())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .vertical
		spacing = UI.Margins
		addGestureRecognizer(UITapGestureRecognizer(block: { _ in
			
			UIApplication.feedBack(.On)
			UI.MainController.present(BF_NavigationController(rootViewController: BF_Account_Infos_ViewController()), animated: true)
		}))
		
		let stackView:UIStackView = .init()
		stackView.axis = .horizontal
		stackView.alignment = .bottom
		stackView.spacing = UI.Margins
		addArrangedSubview(stackView)
		
		let avatarView:UIView = .init()
		stackView.addArrangedSubview(avatarView)
		
		avatarView.addSubview(imageView)
		imageView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		avatarView.addSubview(levelLabel)
		levelLabel.snp.makeConstraints { make in
			make.left.bottom.equalToSuperview()
		}
		
		let detailsStackView:UIStackView = .init(arrangedSubviews: [displayNameLabel,BF_Scans_StackView(),BF_Rubies_StackView()])
		detailsStackView.spacing = UI.Margins/3
		detailsStackView.axis = .vertical
		stackView.addArrangedSubview(detailsStackView)
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
