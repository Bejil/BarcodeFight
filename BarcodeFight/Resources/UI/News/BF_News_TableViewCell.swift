//
//  BF_News_TableViewCell.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 29/01/2025.
//

import Foundation
import UIKit

public class BF_News_TableViewCell : BF_TableViewCell {
	
	public override class var identifier: String {
		
		return "newsTableViewCellIdentifier"
	}
	public var news:BF_News? {
		
		didSet {
			
			readIndicatorViesw.isHidden = news?.isRead ?? false
			
			if let creationDate = news?.creationDate {
				
				let dateFormatter:DateFormatter = .init()
				dateFormatter.dateFormat = "dd/MM/yyyy"
				dateLabel.text = dateFormatter.string(from: creationDate)
			}
			
			titleLabel.text = news?.title
			contentLabel.text = news?.content
		}
	}
	private lazy var readIndicatorViesw:UIView = {
		
		$0.backgroundColor = Colors.Button.Delete.Background
		
		let size = UI.Margins/2
		
		$0.snp.makeConstraints { make in
			make.size.equalTo(size)
		}
		$0.layer.cornerRadius = size/2
		
		return $0
		
	}(UIView())
	private lazy var dateLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		$0.textColor = Colors.Content.Text.withAlphaComponent(0.5)
		return $0
		
	}(BF_Label())
	private lazy var titleLabel:BF_Label = {
		
		$0.font = Fonts.Content.Title.H4
		return $0
		
	}(BF_Label())
	private lazy var contentLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-1)
		$0.numberOfLines = 5
		return $0
		
	}(BF_Label())
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let stackView:UIStackView = .init(arrangedSubviews: [readIndicatorViesw,titleLabel])
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.spacing = UI.Margins
		
		let contentStackView:UIStackView = .init(arrangedSubviews: [stackView,dateLabel,contentLabel])
		contentStackView.axis = .vertical
		contentStackView.spacing = UI.Margins/2
		contentStackView.setCustomSpacing(3*UI.Margins/4, after: dateLabel)
		contentView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
