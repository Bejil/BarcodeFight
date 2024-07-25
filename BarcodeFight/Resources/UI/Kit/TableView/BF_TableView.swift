//
//  BF_TableView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 21/07/2022.
//

import Foundation
import UIKit

public class BF_TableView: UITableView {
	
	public var isHeightDynamic:Bool = false {
		
		didSet {
			
			isScrollEnabled = !isHeightDynamic
		}
	}
	public override var contentSize: CGSize {
		
		didSet {
			
			if isHeightDynamic {
				
				self.invalidateIntrinsicContentSize()
			}
		}
	}
	public override var intrinsicContentSize: CGSize {
		
		if isHeightDynamic {
			
			return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
		}
		
		return super.intrinsicContentSize
	}
	
	public override init(frame: CGRect, style: UITableView.Style) {
		
		super.init(frame: frame, style: style)
		
		backgroundColor = .clear
		sectionHeaderTopPadding = 0
		register(BF_TableViewCell.self, forCellReuseIdentifier: BF_TableViewCell.identifier)
		tableHeaderView = .init()
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func reloadData() {
		
		super.reloadData()
		
		if isHeightDynamic {
			
			invalidateIntrinsicContentSize()
			layoutIfNeeded()
		}
	}
	
	public var headerView:UIView? {
		
		didSet {
			
			tableHeaderView = headerView
			
			if let headerView = headerView {
				
				tableHeaderView?.snp.makeConstraints { make in
					make.edges.width.equalToSuperview()
				}
				headerView.layoutIfNeeded()
			}
			
			tableHeaderView?.layoutIfNeeded()
		}
	}
}
