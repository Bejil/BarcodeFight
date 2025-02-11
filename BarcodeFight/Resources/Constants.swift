//
//  Constants.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 03/08/2023.
//

import Foundation
import UIKit

struct Challenges {
	
	static let Max:Int = 7
	
	static let Connexions:String = "5a9d83e1-1144-4ff4-9ff5-918168d2d76e"
	static let Fights:String = "8f0c55a9-fff6-47eb-aeda-a9c2f002dc71"
	static let Scans:String = "01e506e2-b8a3-454b-a5dc-1a0b0bb77b95"
	static let Story:String = "dd443c46-a12a-4eac-af5c-c086636fbe74"
	static let Monsters:String = "dc7fe587-c09f-4039-afd1-2d223c985f1e"
}

struct Items {
	
	static let ChestObjects:String = "0e1df00a-c430-407f-994a-7336a7c20546"
	static let ChestMonsters:String = "20cf2b5c-fbf7-45d0-8e59-dbf4816204c4"
	static let Rubies:String = "7dd7e330-d4e9-4478-938a-7e37da4c675b"
	static let Scan:String = "3c244023-eb3f-4e3e-bf87-fef44de2a818"
	static let MonsterPlace:String = "a0c32e47-1e9f-49bd-b837-af8327f2e227"
	static let RemoveAds:String = "d96970f1-28b0-4ee7-9221-bf81c8f1c752"
	
	struct Potions {
		
		static let Hp:String = "31659e15-316d-429c-8dfd-113d57b45a0c"
		static let Mp:String = "73a111d8-995a-4e87-af48-0a49da4cda7e"
		static let Revive:String = "28d5c834-627f-4c54-a86f-1074be647614"
	}
	
	struct Coins {
		
		static let Five:String = "b829b821-410c-4979-ae02-3b95e311c0d5"
	}
}

struct UI {
	
	static var MainController :UIViewController {
		
		return UIApplication.shared.topMostViewController()!
	}
	static let Margins:CGFloat = 15.0
	static let CornerRadius:CGFloat = 10.0
}

public struct Colors {
	
	public static let Primary:UIColor = UIColor(named: "Primary")!
	public static let Secondary:UIColor = UIColor(named: "Secondary")!
	
	public struct Navigation {
		
		public static let Title:UIColor = UIColor(named: "NavigationTitle")!
		public static let Button:UIColor = UIColor(named: "NavigationButton")!
	}
	
	public struct Content {
		
		public static let Title:UIColor = UIColor(named: "ContentTitle")!
		public static let Text:UIColor = UIColor(named: "ContentText")!
	}
	
	public struct Button {
		
		public struct Primary {
			
			public static let Background:UIColor = UIColor(named: "ButtonPrimaryBackground")!
			public static let Content:UIColor = UIColor(named: "ButtonPrimaryContent")!
		}
		
		public struct Secondary {
			
			public static let Background:UIColor = UIColor(named: "ButtonSecondaryBackground")!
			public static let Content:UIColor = UIColor(named: "ButtonSecondaryContent")!
		}
		
		public struct Delete {
			
			public static let Background:UIColor = UIColor(named: "ButtonDeleteBackground")!
			public static let Content:UIColor = UIColor(named: "ButtonDeleteContent")!
		}
		
		public struct Text {
			
			public static let Background:UIColor = UIColor(named: "ButtonTextBackground")!
			public static let Content:UIColor = Colors.Button.Primary.Background
		}
	}
	
	public struct Monsters {
		
		public struct Stats {
			
			public static let Atk:UIColor = UIColor(named: "Atk")!
			public static let Def:UIColor = UIColor(named: "Def")!
			public static let Height:UIColor = UIColor(named: "Height")!
			public static let Hp:UIColor = UIColor(named: "Hp")!
			public static let Luk:UIColor = UIColor(named: "Luk")!
			public static let Mp:UIColor = UIColor(named: "Mp")!
			public static let Weight:UIColor = UIColor(named: "Weight")!
		}
		
		public struct Elements {
			
			public static let Darkness:UIColor = UIColor(named: "Darkness")!
			public static let Earth:UIColor = UIColor(named: "Earth")!
			public static let Electricity:UIColor = UIColor(named: "Electricity")!
			public static let Fire:UIColor = UIColor(named: "Fire")!
			public static let Ice:UIColor = UIColor(named: "Ice")!
			public static let Lightness:UIColor = UIColor(named: "Lightness")!
			public static let Neutral:UIColor = UIColor(named: "Neutral")!
			public static let Water:UIColor = UIColor(named: "Water")!
			public static let Wind:UIColor = UIColor(named: "Wind")!
		}
	}
}

public struct Fonts {
	
	private struct Name {
		
		static let Regular:String = "TTInterphasesProTrl-Rg"
		static let Bold:String = "TTInterphasesProTrl-Bd"
		static let Black:String = "GROBOLD"
	}
	
	public static let Size:CGFloat = 13
	
	public struct Navigation {
		
		public struct Title {
			
			public static let Large:UIFont = UIFont(name: Name.Black, size: Fonts.Size+25)!
			public static let Small:UIFont = UIFont(name: Name.Black, size: Fonts.Size+12)!
		}
		
		public static let Button:UIFont = UIFont(name: Name.Regular, size: Fonts.Size-2)!
	}
	
	public struct Content {
		
		public struct Text {
			
			public static let Regular:UIFont = UIFont(name: Name.Regular, size: Fonts.Size)!
			public static let Bold:UIFont = UIFont(name: Name.Bold, size: Fonts.Size)!
		}
		
		public struct Button {
			
			public static let Title:UIFont = UIFont(name: Name.Black, size: Fonts.Size+4)!
			public static let Subtitle:UIFont = UIFont(name: Name.Regular, size: Fonts.Size)!
		}
		
		public struct Title {
			
			public static let H1:UIFont = UIFont(name: Name.Black, size: Fonts.Size+15)!
			public static let H2:UIFont = UIFont(name: Name.Black, size: Fonts.Size+11)!
			public static let H3:UIFont = UIFont(name: Name.Black, size: Fonts.Size+8)!
			public static let H4:UIFont = UIFont(name: Name.Black, size: Fonts.Size+5)!
		}
	}
}
