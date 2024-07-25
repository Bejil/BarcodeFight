//
//  BF_Account_Infos_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 07/08/2023.
//

import Foundation
import UIKit
import QRCode

public class BF_Account_Infos_ViewController : BF_ViewController {
	
	private var user:BF_User? {
		
		didSet {
			
			if let user = user {
				
				let level = user.level
				let progress = Float(user.experience-level.range.lowerBound)/Float(level.range.upperBound-level.range.lowerBound)
				let experienceString = "(\(user.experience))"
				
				experienceLevelLabel.text = String(key: "account.infos.experience.level.label")+"\(level.number) \(experienceString)"
				experienceLevelLabel.set(font: Fonts.Content.Text.Regular, string: experienceString)
				experienceProgressBar.progress = progress
				experienceProgressPercentLabel.text = "\(Int(progress*100.0))" + String(key: "%")
				experienceNextLevelLabel.text = [String(key: "account.infos.experience.level.next.label.0"),"\(level.range.upperBound-user.experience)",String(key: "account.infos.experience.level.next.label.1"),"(\(level.range.upperBound))"].joined(separator: " ")
				
				fightsStackView.fights = user.fights
				
				let dateFormatter:DateFormatter = .init()
				dateFormatter.dateFormat = "dd/MM/yyyy"
				let creationDateString = dateFormatter.string(from: user.creationDate)
				creationDateLabel.text = [String(key: "account.infos.stats.creationDate.label"),creationDateString].joined(separator: " ")
				creationDateLabel.set(font: Fonts.Content.Text.Regular, string: creationDateString)
				
				let scanCountString = "\(user.scanCount)"
				scanCountLabel.text = [String(key: "account.infos.stats.scanCount.label"),scanCountString].joined(separator: " ")
				scanCountLabel.set(font: Fonts.Content.Text.Regular, string: scanCountString)
				
				scanAvailableStepper.value = Double(user.scanAvailable)
				
				coinsStackView.user = user
				coinsStepper.value = Double(user.coins)
				
				rubiesStackView.user = user
				rubiesStepper.value = Double(user.rubies)
			}
		}
	}
	private lazy var experienceLevelLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		return $0
		
	}(BF_Label())
	private lazy var experienceProgressBar:BF_Monsters_Stat_ProgressView = {
		
		$0.color = Colors.Button.Primary.Background
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	private lazy var experienceProgressPercentLabel:BF_Label = {
		
		$0.setContentHuggingPriority(.init(1000), for: .horizontal)
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		return $0
		
	}(BF_Label())
	private lazy var experienceNextLevelLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		return $0
		
	}(BF_Label())
	private lazy var fightsStackView:BF_Fights_StackView = .init()
	private lazy var creationDateLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		return $0
		
	}(BF_Label())
	private lazy var scanCountLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		return $0
		
	}(BF_Label())
	private lazy var scanAvailableStackView:BF_Scans_StackView = .init()
	private lazy var scanAvailableStepper:BF_Stepper = {
		
		$0.maximumValue = Double(BF_Firebase.shared.config.int(.ScanMaxNumber))
		$0.isHidden = !UIApplication.isDebug
		$0.addAction(.init(handler: { [weak self] _ in
			
			let previousScanAvailable = BF_User.current?.scanAvailable
			
			BF_User.current?.scanAvailable = Int(self?.scanAvailableStepper.value ?? 0.0)
			BF_User.current?.update { [weak self] error in
				
				if let error = error {
					
					BF_User.current?.scanAvailable = previousScanAvailable ?? 0
					self?.scanAvailableStepper.value = Double(previousScanAvailable ?? 0)
					
					BF_Alert_ViewController.present(error)
				}
				else {
					
					NotificationCenter.post(.updateAccount)
				}
			}
			
		}), for: .valueChanged)
		return $0
		
	}(BF_Stepper())
	private lazy var coinsLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		return $0
		
	}(BF_Label())
	private lazy var coinsStackView:BF_Coins_StackView = .init()
	private lazy var coinsStepper:BF_Stepper = {
		
		$0.maximumValue = .infinity
		$0.isHidden = !UIApplication.isDebug
		$0.addAction(.init(handler: { [weak self] _ in
			
			let previousCoins = BF_User.current?.coins
			
			BF_User.current?.coins = Int(self?.coinsStepper.value ?? 0.0)
			BF_User.current?.update { [weak self] error in
				
				if let error = error {
					
					BF_User.current?.coins = previousCoins ?? 0
					self?.coinsStepper.value = Double(previousCoins ?? 0)
					
					BF_Alert_ViewController.present(error)
				}
				else {
					
					NotificationCenter.post(.updateAccount)
				}
			}
			
		}), for: .valueChanged)
		return $0
		
	}(BF_Stepper())
	private lazy var rubiesStackView:BF_Rubies_StackView = .init()
	private lazy var rubiesStepper:BF_Stepper = {
		
		$0.maximumValue = Double(BF_Firebase.shared.config.int(.RubiesMaxNumber))
		$0.isHidden = !UIApplication.isDebug
		$0.addAction(.init(handler: { [weak self] _ in
			
			let previousCoins = BF_User.current?.rubies
			
			BF_User.current?.rubies = Int(self?.rubiesStepper.value ?? 0.0)
			BF_User.current?.update { [weak self] error in
				
				if let error = error {
					
					BF_User.current?.rubies = previousCoins ?? 0
					self?.rubiesStepper.value = Double(previousCoins ?? 0)
					
					BF_Alert_ViewController.present(error)
				}
				else {
					
					NotificationCenter.post(.updateAccount)
				}
			}
			
		}), for: .valueChanged)
		return $0
		
	}(BF_Stepper())
	private lazy var placeholderView:BF_Placeholder_View = {
		
		$0.isCentered = false
		$0.contentStackView.spacing = 2*UI.Margins
		
		if let uid = BF_User.current?.uid {
			
			let qrcodeDocument = QRCode.Document(utf8String: uid)
			qrcodeDocument.design.backgroundColor(UIColor.white.cgColor)
			qrcodeDocument.design.shape.eye = QRCode.EyeShape.RoundedOuter()
			qrcodeDocument.design.shape.onPixels = QRCode.PixelShape.Circle()
			qrcodeDocument.design.style.onPixels = QRCode.FillStyle.Solid(Colors.Secondary.cgColor)
			qrcodeDocument.design.shape.offPixels = QRCode.PixelShape.Horizontal(insetFraction: UI.Margins/3, cornerRadiusFraction: 1)
			qrcodeDocument.design.style.offPixels = QRCode.FillStyle.Solid(Colors.Secondary.withAlphaComponent(0.4).cgColor)
			
			let qrcodeSize = 150
			
			let qrcodeImageView:BF_ImageView = .init(image: qrcodeDocument.uiImage(dimension: qrcodeSize, scale: UIScreen.main.scale))
			qrcodeImageView.contentMode = .scaleAspectFit
			qrcodeImageView.layer.cornerRadius = UI.Margins
			qrcodeImageView.layer.masksToBounds = true
			qrcodeImageView.clipsToBounds = true
			
			let qrcodeView:UIView = .init()
			qrcodeView.addSubview(qrcodeImageView)
			qrcodeImageView.snp.makeConstraints { make in
				make.size.equalTo(qrcodeSize)
				make.centerX.top.bottom.equalToSuperview()
			}
			
			$0.contentStackView.addArrangedSubview(qrcodeView)
		}
		
		let experienceTitleLabel:BF_Label = .init(String(key: "account.infos.experience.title"))
		experienceTitleLabel.font = Fonts.Content.Title.H4
		experienceTitleLabel.contentInsets.bottom = UI.Margins/2
		experienceTitleLabel.addLine(position: .bottom)
		$0.contentStackView.addArrangedSubview(experienceTitleLabel)
		
		let experienceProgressStackView:UIStackView = .init(arrangedSubviews: [experienceProgressBar,experienceProgressPercentLabel])
		experienceProgressStackView.axis = .horizontal
		experienceProgressStackView.alignment = .center
		experienceProgressStackView.spacing = UI.Margins/2
		
		let experienceStackView:UIStackView = .init(arrangedSubviews: [experienceLevelLabel,experienceProgressStackView,experienceNextLevelLabel])
		experienceStackView.axis = .vertical
		experienceStackView.spacing = UI.Margins
		experienceStackView.setCustomSpacing(3*experienceStackView.spacing/4, after: experienceProgressStackView)
		$0.contentStackView.addArrangedSubview(experienceStackView)
		
		let fightsTitleLabel:BF_Label = .init(String(key: "account.infos.fights.title"))
		fightsTitleLabel.font = Fonts.Content.Title.H4
		
		let fightsTitleButton:BF_Button = .init(String(key: "account.infos.fights.history")) { _ in
			
			UI.MainController.present(BF_NavigationController(rootViewController: BF_Account_Fights_ViewController()), animated: true)
		}
		fightsTitleButton.titleFont = Fonts.Content.Text.Bold.withSize(Fonts.Size-3)
		fightsTitleButton.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
		fightsTitleButton.setContentHuggingPriority(.init(1000), for: .horizontal)
		fightsTitleButton.configuration?.contentInsets = .init(horizontal: UI.Margins/2, vertical: UI.Margins/2)
		fightsTitleButton.snp.removeConstraints()
		
		let fightTitleStackView:UIStackView = .init(arrangedSubviews: [fightsTitleLabel,fightsTitleButton])
		fightTitleStackView.axis = .horizontal
		fightTitleStackView.alignment = .center
		fightTitleStackView.isLayoutMarginsRelativeArrangement = true
		fightTitleStackView.layoutMargins.bottom = UI.Margins/2
		fightTitleStackView.addLine(position: .bottom)
		$0.contentStackView.addArrangedSubview(fightTitleStackView)
		
		$0.contentStackView.addArrangedSubview(fightsStackView)
		
		let statsTitleLabel:BF_Label = .init(String(key: "account.infos.stats.title"))
		statsTitleLabel.font = Fonts.Content.Title.H4
		statsTitleLabel.contentInsets.bottom = UI.Margins/2
		statsTitleLabel.addLine(position: .bottom)
		$0.contentStackView.addArrangedSubview(statsTitleLabel)
		
		let scanAvailableLabel:BF_Label = .init(String(key: "account.infos.stats.scanAvailable.label"))
		scanAvailableLabel.font = Fonts.Content.Text.Bold
		
		let scanAvailableStackView:UIStackView = .init(arrangedSubviews: [scanAvailableLabel,self.scanAvailableStackView,.init(),scanAvailableStepper])
		scanAvailableStackView.axis = .horizontal
		scanAvailableStackView.alignment = .center
		scanAvailableStackView.spacing = UI.Margins
		
		let coinsLabel:BF_Label = .init(String(key: "account.infos.stats.coins.label"))
		coinsLabel.font = Fonts.Content.Text.Bold
		
		let coinsStackView:UIStackView = .init(arrangedSubviews: [coinsLabel,self.coinsStackView,.init(),coinsStepper])
		coinsStackView.axis = .horizontal
		coinsStackView.alignment = .center
		coinsStackView.spacing = UI.Margins
		
		let rubiesLabel:BF_Label = .init(String(key: "account.infos.stats.rubies.label"))
		rubiesLabel.font = Fonts.Content.Text.Bold
		
		let rubiesStackView:UIStackView = .init(arrangedSubviews: [rubiesLabel,self.rubiesStackView,.init(),rubiesStepper])
		rubiesStackView.axis = .horizontal
		rubiesStackView.alignment = .center
		rubiesStackView.spacing = UI.Margins
		
		let statsStackView:UIStackView = .init(arrangedSubviews: [creationDateLabel,scanCountLabel,scanAvailableStackView,coinsStackView,rubiesStackView])
		statsStackView.axis = .vertical
		statsStackView.spacing = UI.Margins
		$0.contentStackView.addArrangedSubview(statsStackView)
		
		let audioTitleLabel:BF_Label = .init(String(key: "account.infos.audio.title"))
		audioTitleLabel.font = Fonts.Content.Title.H4
		audioTitleLabel.contentInsets.bottom = UI.Margins/2
		audioTitleLabel.addLine(position: .bottom)
		$0.contentStackView.addArrangedSubview(audioTitleLabel)
		
		let soundsButton:BF_Button = .init(String(key: "account.infos.audio.sounds")) { button in
			
			let state = !(BF_User.current?.isSoundsEnabled ?? true)
			
			button?.isLoading = true
			
			BF_User.current?.isSoundsEnabled = state
			BF_User.current?.update({ error in
				
				button?.isLoading = false
				
				if let error {
					
					BF_Alert_ViewController.present(error)
				}
				else {
					
					button?.style = state ? .solid : .tinted
					button?.subtitle = String(key: state ? "account.infos.audio.sounds.on" : "account.infos.audio.sounds.off")
					button?.image = UIImage(systemName: state ? "speaker.wave.2.fill" : "speaker.slash.fill")
				}
			})
		}
		soundsButton.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size)
		soundsButton.subtitleFont = Fonts.Content.Button.Subtitle.withSize(Fonts.Size-2)
		
		let isSoundsEnabled = BF_User.current?.isSoundsEnabled ?? true
		soundsButton.style = isSoundsEnabled ? .solid : .tinted
		soundsButton.subtitle = String(key: isSoundsEnabled ? "account.infos.audio.sounds.on" : "account.infos.audio.sounds.off")
		soundsButton.image = UIImage(systemName: isSoundsEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
		
		let musicButton:BF_Button = .init(String(key: "account.infos.audio.musics")) { button in
			
			let state = !(BF_User.current?.isMusicEnabled ?? true)
			
			button?.isLoading = true
			
			BF_User.current?.isMusicEnabled = state
			BF_User.current?.update({ error in
				
				button?.isLoading = false
				
				if let error {
					
					BF_Alert_ViewController.present(error)
				}
				else {
					
					button?.style = state ? .solid : .tinted
					button?.subtitle = String(key: state ? "account.infos.audio.musics.on" : "account.infos.audio.musics.off")
					button?.image = UIImage(systemName: state ? "speaker.wave.2.fill" : "speaker.slash.fill")
					
					state ? BF_Audio.shared.playMain() : BF_Audio.shared.stop()
				}
			})
		}
		musicButton.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size)
		musicButton.subtitleFont = Fonts.Content.Button.Subtitle.withSize(Fonts.Size-2)
		
		let isMusicEnabled = BF_User.current?.isMusicEnabled ?? true
		musicButton.style = isMusicEnabled ? .solid : .tinted
		musicButton.subtitle = String(key: isMusicEnabled ? "account.infos.audio.musics.on" : "account.infos.audio.musics.off")
		musicButton.image = UIImage(systemName: isSoundsEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
		
		let audioButtonsStackView:UIStackView = .init(arrangedSubviews: [soundsButton,musicButton])
		audioButtonsStackView.axis = .horizontal
		audioButtonsStackView.spacing = UI.Margins
		audioButtonsStackView.alignment = .center
		audioButtonsStackView.distribution = .fillEqually
		$0.contentStackView.addArrangedSubview(audioButtonsStackView)
		
		return $0
		
	}(BF_Placeholder_View())
	private lazy var bannerView = BF_Ads.shared.presentBanner(BF_Ads.Identifiers.Banner.AccountInfos, self)
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.title = String(key: "account.infos.title")
		
		let settingsButton:BF_Button = .init(String(key: "account.infos.settings.button")) { [weak self] _ in
			
			self?.navigationController?.pushViewController(BF_Account_Settings_ViewController(), animated: true)
		}
		settingsButton.style = .transparent
		settingsButton.isText = true
		settingsButton.image = UIImage(named: "settings_icon")
		settingsButton.titleFont = Fonts.Navigation.Button
		settingsButton.configuration?.contentInsets = .zero
		settingsButton.configuration?.imagePadding = UI.Margins/2
		
		navigationItem.rightBarButtonItem = .init(customView: settingsButton)
		
		let stackView:UIStackView = .init(arrangedSubviews: [placeholderView])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
		
		if let bannerView {
			
			stackView.addArrangedSubview(bannerView)
		}
		
		NotificationCenter.add(.updateAccount) { [weak self] _ in
			
			self?.scanAvailableStackView.user = BF_User.current
			self?.coinsStackView.user = BF_User.current
			self?.rubiesStackView.user = BF_User.current
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		launchRequest()
		
		bannerView?.isHidden = !BF_Ads.shared.shouldDisplayAd
	}
	
	private func launchRequest() {
		
		view.showPlaceholder(.Loading)
		
		BF_User.get { [weak self] error in
			
			self?.view.dismissPlaceholder()
			
			if let error = error {
				
				self?.view.showPlaceholder(.Error,error) { [weak self] _ in
					
					self?.view.dismissPlaceholder()
					self?.launchRequest()
				}
			}
			else {
				
				NotificationCenter.post(.updateAccount)
				
				self?.user = BF_User.current
			}
		}
	}
}
