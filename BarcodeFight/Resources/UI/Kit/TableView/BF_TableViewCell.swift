//
//  BF_TableViewCell.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 26/04/2021.
//

import UIKit

public class BF_TableViewCell: UITableViewCell {

	public class var identifier: String {
		
		return "tableViewCellIdentifier"
	}
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		tintColor = Colors.Primary
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		
		selectionStyle = .default
		selectedBackgroundView = .init()
		
		let view:UIView = .init()
		view.backgroundColor = tintColor.withAlphaComponent(0.15)
		selectedBackgroundView?.addSubview(view)
		view.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		textLabel?.numberOfLines = 0
		textLabel?.textColor = Colors.Content.Text
		textLabel?.font = Fonts.Content.Text.Bold
		
		detailTextLabel?.numberOfLines = 0
		detailTextLabel?.textColor = Colors.Content.Text
		detailTextLabel?.font = Fonts.Content.Text.Regular
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
	}
	
	public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		
		super.setHighlighted(highlighted, animated: animated)
		
		if !isEditing && selectionStyle != .none {
			
			UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut,.allowUserInteraction], animations: {
				
				self.transform = highlighted ? .init(scaleX: 0.95, y: 0.95) : .identity
				
			}, completion: nil)
		}
	}
}
