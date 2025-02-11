//
//  BF_News_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 29/01/2025.
//

import UIKit

public class BF_News_ViewController : BF_ViewController {
	
	private var news:[BF_News]? {
		
		didSet {
			
			if news?.isEmpty ?? true {
				
				view.showPlaceholder(.Empty)
			}
			else {
				
				tableView.reloadData()
			}
		}
	}
	private lazy var tableView:BF_TableView = {
		
		$0.register(BF_News_TableViewCell.self, forCellReuseIdentifier: BF_News_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		$0.separatorInset = .zero
		$0.separatorColor = .white.withAlphaComponent(0.25)
		return $0
		
	}(BF_TableView())
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.title = String(key: "news.title")
		
		view.addSubview(tableView)
		tableView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
		
		launchRequest()
		
		NotificationCenter.add(.updateNews) { [weak self] _ in
			
			self?.tableView.reloadData()
		}
	}
	
	private func launchRequest() {
		
		view.showPlaceholder(.Loading)
		
		BF_News.get { [weak self] news, error in
			
			self?.view.dismissPlaceholder()
			
			if let error {
				
				BF_Alert_ViewController.present(error) { [weak self] in
					
					self?.launchRequest()
				}
			}
			else {
				
				self?.news = news
			}
		}
	}
	
	private func presentNews(_ news:BF_News?) {
		
		let alertController:BF_Alert_ViewController = .init()
		alertController.title = news?.title
		
		if let creationDate = news?.creationDate {
			
			let dateFormatter:DateFormatter = .init()
			dateFormatter.dateFormat = "dd/MM/yyyy"
			
			let dateLabel = alertController.add(dateFormatter.string(from: creationDate))
			dateLabel.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
			dateLabel.textColor = Colors.Content.Text.withAlphaComponent(0.5)
		}
		
		alertController.add(news?.content)
		alertController.addDismissButton(sticky: true)
		alertController.present()
	}
}

extension BF_News_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return news?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BF_News_TableViewCell.identifier, for: indexPath) as! BF_News_TableViewCell
		cell.news = news?[indexPath.row]
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		let news = news?[indexPath.row]
		
		if let id = news?.id, !(BF_User.current?.newsRead.contains(id) ?? false) {
			
			BF_User.current?.newsRead.append(id)
			
			BF_Alert_ViewController.presentLoading { [weak self] alertController in
				
				BF_User.current?.update { [weak self] _ in
					
					NotificationCenter.post(.updateNews)
					
					alertController?.close { [weak self] in
						
						self?.presentNews(news)
					}
				}
			}
		}
		else {
			
			presentNews(news)
		}
	}
}
