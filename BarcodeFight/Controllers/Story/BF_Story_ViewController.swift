//
//  BF_Story_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 27/05/2024.
//

import Foundation
import UIKit

public class BF_Story_ViewController : BF_ViewController {
	
	private let numberOfPoints = 90
	private let numberOfParts = 15
	private var pointButtons:[UIButton] = .init()
	private let animationDuration:CFTimeInterval = 2.0
	private lazy var scrollView:UIScrollView = {
		
		$0.delegate = self
		$0.clipsToBounds = false
		$0.bounces = false
		return $0
		
	}(UIScrollView())
	private lazy var contentStackView:UIStackView = {
		
		$0.axis = .vertical
		$0.spacing = 5*UI.Margins
		return $0
		
	}(UIStackView())
	private lazy var backgroundImageView:BF_ImageView = .init()
	private lazy var firstCloudsScrollView:UIScrollView = {
		
		$0.isUserInteractionEnabled = false
		$0.clipsToBounds = false
		return $0
		
	}(UIScrollView())
	private lazy var secondCloudsScrollView:UIScrollView = {
		
		$0.isUserInteractionEnabled = false
		$0.clipsToBounds = false
		return $0
		
	}(UIScrollView())
	private lazy var upButton:BF_Menu_Button = {
		
		$0.backgroundView.backgroundColor = Colors.Button.Secondary.Background
		$0.iconImageView.image = UIImage(named: "up_icon")
		return $0
		
	}(BF_Menu_Button() { [weak self] _ in
		
		self?.scrollTo(BF_User.current?.currentStoryPoint ?? 1, animated: true)
	})
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.title = String(key: "story.title")
		
		navigationItem.rightBarButtonItem = .init(customView: BF_Rubies_StackView())
		
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
		
		scrollView.addSubview(backgroundImageView)
		backgroundImageView.snp.makeConstraints { make in
			make.right.left.equalToSuperview()
		}
		
		let inset = 3*UI.Margins
		
		scrollView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview().inset(UI.Margins)
			make.left.right.width.equalToSuperview().inset(inset)
		}
		
		view.addSubview(firstCloudsScrollView)
		firstCloudsScrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		firstCloudsScrollView.layoutIfNeeded()
		var image = UIImage(named: "clouds")?.resize(firstCloudsScrollView.frame.size.width)
		firstCloudsScrollView.backgroundColor = UIColor(patternImage: image!)
		
		view.addSubview(secondCloudsScrollView)
		secondCloudsScrollView.snp.makeConstraints { make in
			make.width.top.bottom.equalToSuperview()
			make.right.equalTo(view.snp.left)
		}
		secondCloudsScrollView.layoutIfNeeded()
		image = UIImage(named: "clouds")?.resize(secondCloudsScrollView.frame.size.width)
		secondCloudsScrollView.backgroundColor = UIColor(patternImage: image!)
		
		view.addSubview(upButton)
		upButton.snp.makeConstraints { make in
			make.bottom.right.equalTo(view.safeAreaInsets).inset(2*UI.Margins)
		}
		
		for i in 1...numberOfPoints {
			
			let bossState = i % numberOfParts == 0
			let chestState = i % ((numberOfParts/2)+1) == 0
			let sizeRatio = bossState ? 1.75 : chestState ? 1.5 : 1.0
			let pointSize = sizeRatio * UI.Margins * 3
			
			let pointContentView:UIView = .init()
			contentStackView.addArrangedSubview(pointContentView)
			
			let pointContentWidth = UIScreen.main.bounds.width - (2*inset)
			let randomXPosition = CGFloat.random(in: 0...(pointContentWidth-pointSize))
			
			let pointButton:UIButton = .init()
			pointButton.backgroundColor = bossState ? Colors.Button.Secondary.Background : chestState ? Colors.Button.Primary.Background : Colors.Content.Text
			pointButton.setTitleColor(Colors.Button.Secondary.Background, for: .normal)
			pointButton.layer.borderWidth = UI.Margins/4
			pointButton.layer.cornerRadius = pointSize/2
			pointButton.layer.shadowOffset = .zero
			pointButton.layer.shadowRadius = 1.5*UI.Margins
			pointButton.layer.shadowOpacity = 0.5
			pointButton.layer.masksToBounds = false
			pointButton.layer.shadowColor = UIColor.black.cgColor
			pointButton.addAction(.init(handler: { [weak self] sender in
				
				pointButton.pulse(.white)
				UIApplication.feedBack(.On)
					
				self?.scrollTo(i, animated:true)
				
				let userState = i == BF_User.current?.currentStoryPoint ?? 1
				
				if chestState {
					
					if userState {
						
						BF_Alert_ViewController.presentLoading { [weak self] controller in
							
							BF_Item.get { [weak self] items, error in
								
								controller?.close({ [weak self] in
									
									if let error {
										
										BF_Alert_ViewController.present(error)
									}
									else if let chest = items?.first(where: { $0.uid == Items.ChestObjects }) {
										
										BF_User.current?.items.append(chest)
										BF_User.current?.currentStoryPoint += 1
										
										BF_Alert_ViewController.presentLoading { [weak self] controller in
											
											BF_User.current?.update({ [weak self] error in
												
												controller?.close { [weak self] in
													
													if let error {
														
														if let index = BF_User.current?.items.firstIndex(of: chest) {
															
															BF_User.current?.items.remove(at: index)
														}
														
														BF_User.current?.currentStoryPoint -= 1
														BF_Alert_ViewController.present(error)
													}
													else {
														
														self?.updatePoints()
														
														self?.drawBezierPath(isUserPath: true, from: i, to: BF_User.current?.currentStoryPoint ?? 1, animated:true)
														
														let alertController:BF_Item_Chest_Objects_Alert_ViewController = .init()
														alertController.present()
													}
												}
											})
										}
									}
								})
							}
						}
					}
					else if i < BF_User.current?.currentStoryPoint ?? 1 {
						
						BF_Alert_ViewController.present(BF_Error(String(key: "story.chest.error")))
					}
				}
				else if i <= BF_User.current?.currentStoryPoint ?? 1 {
					
					let alertController:BF_Alert_ViewController = .init()
					alertController.title = String(key: "story.dropout.alert.title")
					alertController.add(UIImage(named: "map_icon"))
					alertController.add(String(key: "story.dropout.alert.content"))
					alertController.addButton(title: String(key: "story.dropout.alert.button"), subtitle: String(key: "story.dropout.alert.button.subtitle.1") + "\(BF_Firebase.shared.config.int(.RubiesFightCost))" + String(key: "story.dropout.alert.button.subtitle.2"), image: UIImage(named: "items_rubies")?.resize(25)) { [weak self] _ in
						
						alertController.close { [weak self] in
							
							if BF_User.current?.rubies ?? 0 < BF_Firebase.shared.config.int(.RubiesFightCost) {
								
								let alertController:BF_Rubies_Alert_ViewController = .init()
								alertController.present()
							}
							else {
								
								if BF_User.current?.monsters.filter({ !$0.isDead }).isEmpty ?? true {
									
									BF_Monster.presentEmptyMonstersAlertController()
								}
								else {
									
									let pointByRank = (self?.numberOfPoints ?? 0) / BF_Monster.Stats.Rank.allCases.count
									
									if let rank = BF_Monster.Stats.Rank(rawValue: (i/pointByRank) - (bossState ? 1 : 0)) {
										
										let startPoint = Float(rank.rawValue*pointByRank)
										let currentPoint = Float(i)
										let endPoint = Float((rank.rawValue+1)*pointByRank)
										let proportion = (currentPoint - startPoint) / (endPoint - startPoint)
										let percentage = Int(proportion * 100.0)
										
										var monsters = [
											BF_Monster(rank: rank, percent: percentage),
											BF_Monster(rank: rank, percent: percentage),
											BF_Monster(rank: rank, percent: percentage)
										]
										
										if rank.rawValue != BF_Monster.Stats.Rank.allCases.count - 1, let newRank = BF_Monster.Stats.Rank(rawValue: rank.rawValue + 1) {
											
											let newPercentage = Int(1.0/Float(pointByRank) * 100.0)
											
											for i in 0..<monsters.count {
												
												if (bossState || (!bossState && Bool.random(probability: 0.25))) {
													
													monsters[i] = BF_Monster(rank: newRank, percent: newPercentage)
												}
											}
										}
										
										BF_Alert_ViewController.presentLoading() { [weak self] alertController in
											
											BF_Ads.shared.presentRewardedInterstitial(BF_Ads.Identifiers.FullScreen.StoryContinue) { [weak self] in
												
												alertController?.close {
													
													BF_Alert_ViewController.presentLoading() { [weak self] alertController in
														
														BF_User.current?.rubies -= BF_Firebase.shared.config.int(.RubiesFightCost)
														BF_User.current?.update({ error in
															
															alertController?.close {
																
																if let error = error {
																	
																	BF_Alert_ViewController.present(error)
																}
																else {
																	
																	NotificationCenter.post(.updateAccount)
																	
																	let viewController:BF_Battle_Opponent_ViewController = .init()
																	viewController.isStoryOpponent = true
																	viewController.opponentMonsters = monsters
																	viewController.victoryHandler = { [weak self] in
																		
																		if i == BF_User.current?.currentStoryPoint ?? 1 {
																			
																			BF_Challenge.increase(Challenges.Story)
																			
																			if userState && BF_User.current?.currentStoryPoint ?? 0 < self?.numberOfPoints ?? 0 {
																				
																				BF_User.current?.currentStoryPoint += 1
																				
																				BF_Alert_ViewController.presentLoading() { [weak self] alertController in
																					
																					BF_User.current?.update({ [weak self] error in
																						
																						alertController?.close { [weak self] in
																							
																							if let error {
																								
																								BF_User.current?.currentStoryPoint -= 1
																								BF_Alert_ViewController.present(error)
																							}
																							else {
																								
																								self?.drawBezierPath(isUserPath: true, from: i, to: BF_User.current?.currentStoryPoint ?? 1, animated:true)
																							}
																						}
																					})
																				}
																			}
																		}
																	}
																	UI.MainController.present(BF_NavigationController(rootViewController: viewController), animated: true)
																}
															}
														})
													}
												}
											}
										}
									}
								}
							}
						}
					}
					alertController.addCancelButton()
					alertController.present()
				}
				
			}), for: .touchUpInside)
			
			if bossState {
				
				let imageView:BF_ImageView = .init(image: UIImage(named: "placeholder_delete"))
				imageView.contentMode = .scaleAspectFit
				pointButton.addSubview(imageView)
				imageView.snp.makeConstraints { make in
					make.edges.equalToSuperview().inset(2*UI.Margins/3)
				}
			}
			else if chestState {
				
				let imageView:BF_ImageView = .init(image: UIImage(named: i < (BF_User.current?.currentStoryPoint ?? 1) ? "items_chestObjects_open" : "items_chestObjects"))
				imageView.contentMode = .scaleAspectFit
				pointButton.addSubview(imageView)
				imageView.snp.makeConstraints { make in
					make.edges.equalToSuperview().inset(2*UI.Margins/3)
				}
			}
			else {
				
				pointButton.setTitle("\(i)", for: .normal)
				pointButton.titleLabel?.font = Fonts.Content.Title.H4
				pointButton.titleLabel?.textAlignment = .center
			}
			
			pointContentView.addSubview(pointButton)
			pointButton.snp.makeConstraints { make in
				make.size.equalTo(pointSize)
				make.top.bottom.equalToSuperview()
				make.left.equalToSuperview().offset(randomXPosition)
			}
			
			pointButtons.append(pointButton)
		}
		
		UIApplication.wait(0.1) { [weak self] in
			
			self?.view.layoutSubviews()
			
			let image = UIImage(named: "story_background")?.resize(self?.scrollView.frame.size.width ?? 0)
			self?.backgroundImageView.backgroundColor = UIColor(patternImage: image!)
			
			self?.backgroundImageView.snp.makeConstraints { make in
				make.top.equalToSuperview().offset(-(self?.view.safeAreaInsets.top ?? 0.0))
				make.height.equalTo((self?.scrollView.contentSize.height ?? 0.0)  + (self?.view.safeAreaInsets.top ?? 0.0) + (self?.view.safeAreaInsets.bottom ?? 0.0))
			}
			
			self?.drawBezierPath(isUserPath: false, from: 1, to:self?.numberOfPoints ?? 0, animated:false)
			
			if BF_User.current?.currentStoryPoint != 1 {
				
				self?.drawBezierPath(isUserPath: true, from: 1, to:BF_User.current?.currentStoryPoint ?? 1, animated:false)
				self?.scrollTo(BF_User.current?.currentStoryPoint ?? 1, animated: false)
			}
			
			self?.firstCloudsScrollView.contentSize = self?.scrollView.contentSize ?? .zero
			self?.secondCloudsScrollView.contentSize = self?.scrollView.contentSize  ?? .zero
		}
		
		BF_Ads.shared.presentInterstitial(BF_Ads.Identifiers.FullScreen.StoryStart)
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		UIView.animate(withDuration: 30.0, delay: 0.0, options: [.repeat, .curveLinear], animations: {
			
			self.firstCloudsScrollView.frame = self.firstCloudsScrollView.frame.offsetBy(dx: -1 * self.firstCloudsScrollView.frame.size.width, dy: 0.0)
			self.secondCloudsScrollView.frame = self.secondCloudsScrollView.frame.offsetBy(dx: -1 * self.secondCloudsScrollView.frame.size.width, dy: 0.0)
			
		}, completion: nil)
		
		scrollView.delegate?.scrollViewDidScroll?(scrollView)
	}
	
	private func drawBezierPath(isUserPath:Bool, from fromPoint:Int, to toPoint:Int, animated:Bool) {
		
		if pointButtons.count > 1 && toPoint != 1 {
			
			let path = UIBezierPath()
			
			let points: [CGPoint] = pointButtons.map { scrollView.convert($0.center, from: $0.superview) }
			path.move(to: points[fromPoint-1])
			
			let controlPoints = calculateControlPoints(for: points)
			
			for i in fromPoint..<toPoint {
				
				path.addCurve(to: points[i], controlPoint1: controlPoints[i - 1].0, controlPoint2: controlPoints[i - 1].1)
			}
			
			let centerLayer = CAShapeLayer()
			
			if isUserPath {
				
				centerLayer.path = path.cgPath
				centerLayer.lineCap = .round
				centerLayer.lineJoin = .round
				centerLayer.fillColor = UIColor.clear.cgColor
				centerLayer.strokeColor = Colors.Button.Secondary.Background.cgColor
				centerLayer.lineWidth = 3*UI.Margins/4
				scrollView.layer.insertSublayer(centerLayer, at: isUserPath ? 2 : 1)
			}
			
			let shapeLayer = CAShapeLayer()
			shapeLayer.path = path.cgPath
			shapeLayer.lineCap = .round
			centerLayer.lineJoin = .round
			shapeLayer.fillColor = UIColor.clear.cgColor
			shapeLayer.strokeColor = isUserPath ? UIColor.white.cgColor : Colors.Content.Text.withAlphaComponent(0.5).cgColor
			shapeLayer.lineWidth = 1.5*UI.Margins
			scrollView.layer.insertSublayer(shapeLayer, at: isUserPath ? 2 : 1)
			
			if animated {
				
				let animation = CABasicAnimation(keyPath: "strokeEnd")
				animation.fromValue = 0
				animation.toValue = 1
				animation.duration = animationDuration
				
				centerLayer.add(animation, forKey: "drawLineAnimation")
				shapeLayer.add(animation, forKey: "drawLineAnimation")
				
				scrollTo(toPoint, animated: true)
				
				UIApplication.wait(animationDuration) { [weak self] in
					
					UIView.animate { [weak self] in
						
						self?.updatePoints()
					}
					
					self?.pointButtons[toPoint-1].pulse(.white)
					UIApplication.feedBack(.Success)
				}
			}
			else {
				
				updatePoints()
			}
		}
	}
	
	private func updatePoints() {
		
		for i in 1...pointButtons.count {
			
			let bossState = i % numberOfParts == 0
			let chestState = i % ((numberOfParts/2)+1) == 0
			
			pointButtons[i-1].layer.borderColor = bossState || chestState ? UIColor.white.cgColor : Colors.Button.Secondary.Background.cgColor
		}
	}
	
	private func calculateControlPoints(for points: [CGPoint]) -> [(CGPoint, CGPoint)] {
		
		if points.count > 2 {
			
			var controlPoints: [(CGPoint, CGPoint)] = []
			
			for i in 1..<points.count {
				
				let previousPoint = points[i - 1]
				let currentPoint = points[i]
				
				let controlPoint1 = CGPoint(x: (previousPoint.x + currentPoint.x) / 2, y: previousPoint.y)
				let controlPoint2 = CGPoint(x: (previousPoint.x + currentPoint.x) / 2, y: currentPoint.y)
				
				controlPoints.append((controlPoint1, controlPoint2))
			}
			
			return controlPoints
		}
		
		return []
	}
	
	private func scrollTo(_ point:Int, animated:Bool) {
		
		guard pointButtons.count > 1, point >= 1, point <= pointButtons.count else { return }
		
		let targetView = pointButtons[point - 1]
		let targetCenterY = scrollView.convert(targetView.center, from: targetView.superview).y
		let targetYOffset = targetCenterY - scrollView.bounds.height / 2
		let newOffset = CGPoint(x: scrollView.contentOffset.x, y: max(0,min(targetYOffset,scrollView.contentSize.height-scrollView.frame.size.height)))
		
		scrollView.setContentOffset(newOffset, animated: animated)
	}
}

extension BF_Story_ViewController: UIScrollViewDelegate {
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		let contentOffsetY = 3*scrollView.contentOffset.y/4
		firstCloudsScrollView.contentOffset = .init(x: 0, y: contentOffsetY)
		secondCloudsScrollView.contentOffset = .init(x: 0, y: contentOffsetY)
		
		let targetSubview = pointButtons[(BF_User.current?.currentStoryPoint ?? 1)-1]
		let targetFrame = targetSubview.convert(targetSubview.bounds, to: scrollView)
		let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
		
		UIView.animate {
			
			let state = !visibleRect.intersects(targetFrame)
			
			self.upButton.alpha = state ? 1.0 : 0.0
			
			if state {
				
				UIView.animate {
					
					self.upButton.transform = CGAffineTransform(rotationAngle: targetFrame.midY < visibleRect.minY ? 0 : .pi)
				}
			}
		}
	}
}
