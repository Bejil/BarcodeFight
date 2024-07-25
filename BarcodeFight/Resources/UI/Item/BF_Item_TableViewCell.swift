//
//  BF_Item_TableViewCell.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 25/08/2023.
//

import Foundation
import UIKit

public class BF_Item_TableViewCell : BF_TableViewCell {
	
	public override class var identifier: String {
		
		return "itemTableViewCellIdentifier"
	}
	public var item:BF_Item? {
		
		didSet {
			
			if let picture = item?.picture {
				
				pictureImageView.image = UIImage(named: picture)
			}
			
			nameLabel.text = item?.name
			descriptionLabel.text = item?.description
		}
	}
	private lazy var pictureImageView:BF_ImageView = {
		
		$0.contentMode = .scaleAspectFit
		$0.snp.makeConstraints { make in
			make.size.equalTo(4*UI.Margins)
		}
		return $0
		
	}(BF_ImageView())
	private lazy var nameLabel:BF_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.textColor = Colors.Content.Title
		return $0
		
	}(BF_Label())
	private lazy var descriptionLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-1)
		return $0
		
	}(BF_Label())
	public lazy var button:BF_Button = {
		
		$0.isUserInteractionEnabled = false
		$0.configuration?.imagePlacement = .top
		$0.configuration?.titleAlignment = .center
		let height = 4*UI.Margins
		$0.snp.makeConstraints { make in
			make.height.equalTo(height)
			make.width.equalTo(height+UI.Margins)
		}
		$0.configuration?.background.cornerRadius = height/2.5
		$0.isPrimary = false
		$0.isEnabled = false
		return $0
		
	}(BF_Button())
	private lazy var stackView:UIStackView = {
		
		$0.addArrangedSubview(pictureImageView)
		
		let detailsStackView:UIStackView = .init(arrangedSubviews: [nameLabel,descriptionLabel])
		detailsStackView.axis = .vertical
		detailsStackView.spacing = UI.Margins/3
		detailsStackView.alignment = .leading
		$0.addArrangedSubview(detailsStackView)
		
		$0.addArrangedSubview(button)
		
		$0.axis = .horizontal
		$0.spacing = UI.Margins
		$0.alignment = .center
		
		return $0
		
	}(UIStackView())
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		contentView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
