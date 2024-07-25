//
//  BF_User_ImageView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 28/05/2024.
//

import Foundation
import UIKit

public class BF_User_ImageView : BF_ImageView {
	
	public var user:BF_User? {
		
		didSet {
			
			if let user = user {
				
				if let url = user.pictureUrl, !url.isEmpty {
					
					self.url = url
				}
				else {
					
					BF_BoringAvatar.get(for: user.displayName) { [weak self] image in
						
						if let image {
							
							self?.image = image
						}
						else {
							
							self?.image = UIImage(named: "placeholder_profile")
						}
					}
				}
			}
		}
	}
	
	init() {
		
		super.init(frame: .zero)
		
		image = UIImage(named: "placeholder_profile")
		contentMode = .scaleAspectFill
		clipsToBounds = true
		layer.masksToBounds = true
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		layer.cornerRadius = frame.size.height/2.5
	}
}
