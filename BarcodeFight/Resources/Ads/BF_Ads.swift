//
//  BF_Ads.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 08/06/2024.
//

import Foundation
import GoogleMobileAds

public class BF_Ads : NSObject {
	
	public struct Identifiers {
		
		public struct FullScreen {
			
#if DEBUG
			static let AppOpening:String = "ca-app-pub-3940256099942544/9257395921"
			static let FreeScan:String = "ca-app-pub-9540216894729209/4249300149"
			static let FreeRuby:String = "ca-app-pub-9540216894729209/4249300149"
			static let AfterFight:String = "ca-app-pub-3940256099942544/4411468910"
			static let StoryStart:String = "ca-app-pub-3940256099942544/4411468910"
			static let StoryContinue:String = "ca-app-pub-9540216894729209/4249300149"
#else
			static let AppOpening:String = "ca-app-pub-9540216894729209/3799186078"
			static let FreeScan:String = "ca-app-pub-9540216894729209/6773103279"
			static let FreeRuby:String = "ca-app-pub-9540216894729209/1568878052"
			static let AfterFight:String = "ca-app-pub-9540216894729209/3971680118"
			static let StoryStart:String = "ca-app-pub-9540216894729209/4935076292"
			static let StoryContinue:String = "ca-app-pub-9540216894729209/3719031695"
#endif
		}
		
		public struct Banner {
			
#if DEBUG
			static let Home:String = "ca-app-pub-3940256099942544/2435281174"
			static let Monster:String = "ca-app-pub-3940256099942544/2435281174"
			static let Shop:String = "ca-app-pub-3940256099942544/2435281174"
			static let Objects:String = "ca-app-pub-3940256099942544/2435281174"
			static let AccountInfos:String = "ca-app-pub-3940256099942544/2435281174"
			static let AccountSettings:String = "ca-app-pub-3940256099942544/2435281174"
			static let Ranking:String = "ca-app-pub-3940256099942544/2435281174"
			static let Fights:String = "ca-app-pub-3940256099942544/2435281174"
#else
			static let Home:String = "ca-app-pub-9540216894729209/6355236657"
			static let Monster:String = "ca-app-pub-9540216894729209/7044334506"
			static let Shop:String = "ca-app-pub-9540216894729209/5013067530"
			static let Objects:String = "ca-app-pub-9540216894729209/3125270795"
			static let AccountInfos:String = "ca-app-pub-9540216894729209/3181111118"
			static let AccountSettings:String = "ca-app-pub-9540216894729209/7667151030"
			static let Ranking:String = "ca-app-pub-9540216894729209/8597089320"
			static let Fights:String = "ca-app-pub-9540216894729209/5476101966"
#endif
		}
	}
	
	public static let shared:BF_Ads = .init()
	private var adReward:GADAdReward?
	private var adRewardCompletion:(()->Void)?
	private var rewardedInterstitialAd:GADRewardedInterstitialAd?
	public var shouldDisplayAd:Bool {
		
#if DEBUG
		return false
#else
		return !(BF_User.current?.removeAds ?? false)
#endif
	}
	
	public func start() {
		
		if shouldDisplayAd {
			
			GADMobileAds.sharedInstance().start(completionHandler: nil)
		}
	}
	
	private var appOpening:GADAppOpenAd?
	
	public func presentAppOpening() {
		
		if shouldDisplayAd {
			
			GADAppOpenAd.load(withAdUnitID: Identifiers.FullScreen.AppOpening, request: GADRequest()) { [weak self] ad, error in
				
				self?.appOpening = ad
				self?.appOpening?.fullScreenContentDelegate = self
				self?.appOpening?.present(fromRootViewController: UI.MainController)
			}
		}
	}
	
	public func presentInterstitial(_ identifier:String) {
		
		if shouldDisplayAd {
			
			GADInterstitialAd.load(withAdUnitID:identifier, request: GADRequest(), completionHandler: { [weak self] ad, _ in
				
				ad?.fullScreenContentDelegate = self
				ad?.present(fromRootViewController: UI.MainController)
			})
		}
	}
	
	public func presentRewardedInterstitial(_ identifier:String, _ completion:(()->Void)?) {
		
		adRewardCompletion = completion
		
		if shouldDisplayAd && ![BF_Ads.Identifiers.FullScreen.FreeRuby,BF_Ads.Identifiers.FullScreen.FreeScan].contains(identifier) {
			
			GADRewardedInterstitialAd.load(withAdUnitID: identifier, request: GADRequest()) { [weak self] ad, error in
				
				if error != nil {
					
					self?.adRewardCompletion?()
					
					self?.rewardedInterstitialAd = nil
					self?.adRewardCompletion = nil
					self?.adReward = nil
				}
				else {
					
					self?.rewardedInterstitialAd = ad
					self?.rewardedInterstitialAd?.fullScreenContentDelegate = self
					self?.rewardedInterstitialAd?.present(fromRootViewController: UI.MainController, userDidEarnRewardHandler: { [weak self] in
						
						self?.adReward = ad?.adReward
					})
				}
			}
		}
		else {
			
			adRewardCompletion?()
		}
	}
	
	public func presentBanner(_ identifier:String, _ rootViewController:UIViewController) -> GADBannerView? {
		
		if shouldDisplayAd {
			
			let bannerView:GADBannerView = .init(adSize: GADAdSizeBanner)
			bannerView.adUnitID = identifier
			bannerView.rootViewController = rootViewController
			bannerView.delegate = self
			bannerView.load(GADRequest())
			return bannerView
		}
		
		return nil
	}
}



extension BF_Ads : GADFullScreenContentDelegate {
	
	public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
		
		appOpening = nil
		
		if rewardedInterstitialAd != nil && adRewardCompletion != nil && adReward != nil && ad is GADRewardedInterstitialAd {
			
			adRewardCompletion?()
			
			rewardedInterstitialAd = nil
			adRewardCompletion = nil
			adReward = nil
		}
		else if ad is GADAppOpenAd && !(BF_User.current?.removeAds ?? false) {
			
			UI.MainController.present(BF_NavigationController(rootViewController: BF_Onboarding_Ads_ViewController()), animated: true)
		}
	}
	
	public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
		
		if rewardedInterstitialAd != nil && adRewardCompletion != nil && ad is GADRewardedInterstitialAd {
			
			adRewardCompletion?()
			
			rewardedInterstitialAd = nil
			adRewardCompletion = nil
			adReward = nil
		}
	}
}


extension BF_Ads : GADBannerViewDelegate {
	
	public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
		
		UIView.animate {
			
			bannerView.isHidden = true
			bannerView.alpha = bannerView.isHidden ? 0.0 : 1.0
			bannerView.superview?.layoutIfNeeded()
		}
	}
}
