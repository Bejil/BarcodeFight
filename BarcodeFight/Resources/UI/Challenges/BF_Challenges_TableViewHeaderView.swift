//
//  BF_Challenges_TableViewHeaderView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 29/08/2024.
//

import Foundation
import UIKit

public class BF_Challenges_TableViewHeaderView : UITableViewHeaderFooterView {
	
	public class var identifier: String {
		
		return "challengesTableViewHeaderViewIdentifier"
	}
	public lazy var label:BF_Label = {
		
		$0.font = Fonts.Content.Title.H2
		return $0
		
	}(BF_Label())
	
	public override init(reuseIdentifier: String?) {
		
		super.init(reuseIdentifier: reuseIdentifier)
		
		let visualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .dark))
		contentView.addSubview(visualEffectView)
		visualEffectView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		visualEffectView.contentView.addSubview(label)
		label.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
