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
    var scale: CGFloat = 2.0
    
    override func didMove(to view: SKView) {
        SKTAudio.sharedInstance().playBackgroundMusic("MenuSong.mp3")
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
            SKTAudio.sharedInstance().pauseBackgroundMusic()
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
        gameTitle.fontSize = 70
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
        background = SKSpriteNode(imageNamed: "BackgroundImage")
        background.name = "Background"
        background.setScale(scale)
        background.anchorPoint = .zero
        background.position = CGPoint(x: 0.0, y: 0.0)
        background.zPosition = -1.0
        addChild(background)
    }
    
    func createTrees() {
        for i in 0...2 {
            leftTree = SKSpriteNode(imageNamed: "LeftTree")
            leftTree.setScale(scale)
            leftTree.name = "Tree"
            leftTree.anchorPoint = .zero
            leftTree.zPosition = 1.0
            leftTree.position = CGPoint(x: 0.0, y: CGFloat(i)*leftTree.frame.height)
            leftTree.physicsBody = SKPhysicsBody(rectangleOf: leftTree.size)
            leftTree.physicsBody!.isDynamic = false
            leftTree.physicsBody!.affectedByGravity = false
            leftTree.physicsBody!.categoryBitMask = PhysicsCategory.Tree
            rightTree = SKSpriteNode(imageNamed: "LeftTree")
            rightTree.setScale(scale)
            rightTree.xScale = -scale
            rightTree.name = "Tree"
            rightTree.anchorPoint = .zero
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
