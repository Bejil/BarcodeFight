//
//  BF_Monsters_Particules_View.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 23/08/2023.
//

import Foundation
import SpriteKit

public class BF_Monsters_Particules_View : SKView {
	
	public var monster:BF_Monster? {
		
		didSet {
			
			particulesEmitterNode.particleColor = monster?.element.color ?? .white
		}
	}
			
	private lazy var particulesScene:SKScene = {
		
		$0.backgroundColor = .clear
		$0.scaleMode = .resizeFill
		$0.addChild(particulesEmitterNode)
		return $0
		
	}(SKScene())
	private lazy var particulesEmitterNode:SKEmitterNode = {
		
		$0.particleColorSequence = nil
		$0.particleColor = .white
		return $0
		
	}(SKEmitterNode(fileNamed: "BF_Monsters_Particules.sks")!)
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		backgroundColor = .clear
		contentMode = .scaleAspectFit
		presentScene(particulesScene)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		particulesScene.size = frame.size
		particulesEmitterNode.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
	}
}
