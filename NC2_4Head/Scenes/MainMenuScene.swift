//
//  MainMenuScene.swift
//  NC2_4Head
//
//  Created by Ilia Sedelkin on 12/12/22.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    // MARK: Properties
    var background = SKSpriteNode()
    var leftTree = SKSpriteNode()
    var rightTree = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        createBackground()
        createTrees()
        setupNodes()
        addNodes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        
        if node.name == "play" {
            let scene = GameScene(size: CGSize(width: frame.width, height: frame.height))
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsOpenVertical(withDuration: 0.3))
            
        } else if node.name == "highscore" {
            print("highscore tab")
        }
    }
    
    func setupNodes() {
        
        // TODO: font doesn't work
        let gameTitle = SKLabelNode(fontNamed: "Atari ST 8x16 System Font")
        gameTitle.text = "SquirHell"
        gameTitle.fontSize = 80
        gameTitle.zPosition = 10.0
        gameTitle.position = CGPoint(x: size.width/2.0, y: size.height - 250)
        addChild(gameTitle)
        
        let playButton = SKSpriteNode(imageNamed: "button_green_thick")
        playButton.name = "play"
        // TODO: remove scale for our own assets
        playButton.setScale(0.65)
        playButton.zPosition = 10.0
        playButton.position = CGPoint(x: size.width/2.0, y: size.height/2.0 - 65)
        addChild(playButton)
        
        let higscoreButton = SKSpriteNode(imageNamed: "button_blue_flat")
        higscoreButton.name = "highscore"
        // TODO: remove scale for our own assets
        higscoreButton.setScale(0.65)
        higscoreButton.zPosition = 10.0
        higscoreButton.position = CGPoint(x: size.width/2.0, y: size.height/2.0 + 65)
        addChild(higscoreButton)
        
        
    }
    
    func addNodes() {
        
    }
    
}

extension MainMenuScene {
    
    func createBackground() {
        for i in 0...2 {
            background = SKSpriteNode(imageNamed: "BackgroundImage")
            background.name = "Background"
            background.anchorPoint = .zero
            background.position = CGPoint(x: 0.0, y: CGFloat(i)*background.frame.height)
            background.zPosition = -1.0
            addChild(background)
        }
    }
    
    func createTrees() {
        for i in 0...2 {
            leftTree = SKSpriteNode(imageNamed: "LeftTree")
            leftTree.name = "Tree"
            leftTree.anchorPoint = .zero
            leftTree.zPosition = 1.0
            leftTree.position = CGPoint(x: 0.0, y: CGFloat(i)*leftTree.frame.height)
            leftTree.physicsBody = SKPhysicsBody(rectangleOf: leftTree.size)
            leftTree.physicsBody!.isDynamic = false
            leftTree.physicsBody!.affectedByGravity = false
            leftTree.physicsBody!.categoryBitMask = PhysicsCategory.Tree
            rightTree = SKSpriteNode(imageNamed: "LeftTree")
            rightTree.name = "Tree"
            rightTree.anchorPoint = CGPoint(x: 1, y:  0)
            rightTree.zPosition = 1.0
            rightTree.position = CGPoint(x: frame.width, y: CGFloat(i)*rightTree.frame.height)
            rightTree.physicsBody = SKPhysicsBody(rectangleOf: rightTree.size)
            rightTree.physicsBody!.isDynamic = false
            rightTree.physicsBody!.affectedByGravity = false
            rightTree.physicsBody!.categoryBitMask = PhysicsCategory.Tree
            addChild(leftTree)
            addChild(rightTree)
        }
    }
}
