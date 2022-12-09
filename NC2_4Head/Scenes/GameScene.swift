//
//  GameScene.swift
//  NC2_4Head
//
//  Created by Marco Agizza on 07/12/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // MARK: Properties
    var background = SKSpriteNode()
    var leftTree = SKSpriteNode()
    var rightTree = SKSpriteNode()
    // Player
    var player = SKSpriteNode(imageNamed: "Squirrel")
    var onLeftTree = true
    var onTree = true
    var velocityX: CGFloat = 0.0
    var playerXPosLeft: CGFloat = 0.0
    var playerXPosRight: CGFloat = 0.0
    
    // Obstacles
    var obstacles: [SKSpriteNode] = []
    
    // Camera
    var cameraNode = SKCameraNode()
    var cameraMovePointPerSecond: CGFloat = 450.0
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    // Delay for obstacles random generation
    var isTime: CGFloat = 3.0 {
        didSet {
            print(isTime)
        }
    }
    
    
    var playableRect: CGRect {
        let ratio: CGFloat = 0.4 // TODO: understand better how it works
        /*switch UIScreen.main.nativeBounds.height {
        case 2688, 1792, 2436:
            ratio = 2.16
        default:
            ratio = 16/9
        }*/
        let playableHeight = size.width / ratio
        let playableMargin = (size.height - playableHeight) / 2.0
        
        return CGRect(x: 0.0, y: playableMargin, width: size.width, height: playableHeight)
    }
    
    var cameraRect: CGRect {
        let width = playableRect.width
        let height = playableRect.height
        let x = cameraNode.position.x - size.width/2.0 + (size.width - width)/2.0
        let y = cameraNode.position.y - size.height/2.0 + (size.height - height)/2.0
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
        
    // MARK: System
    
    override func didMove(to view: SKView) {
        createBackground()
        createTrees()
        createPlayer()
        setupCamera()
        setupObstacles()
        spawnObstacles()
        print(self.isTime)
        //setupNodes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if !isPaused {
            onLeftTree.toggle()
            onTree.toggle()
            if !onLeftTree {
                velocityX = 18
            } else {
                velocityX = -18
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        moveCamera()
        movePlayer()
        
        player.position.x += velocityX
        if onLeftTree {
            if player.position.x < playerXPosLeft {
                player.position.x = playerXPosLeft
                velocityX = 0.0
                onTree.toggle()
            }
        }else{
            if player.position.x > playerXPosRight {
                player.position.x = playerXPosRight
                velocityX = 0.0
                onTree.toggle()
            }
            
        }
    }
}

extension GameScene {
    
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
            addChild(leftTree)
            rightTree = SKSpriteNode(imageNamed: "RightTree")
            rightTree.name = "Tree"
            rightTree.anchorPoint = CGPoint(x: 1, y:  0)
            rightTree.zPosition = 1.0
            rightTree.position = CGPoint(x: frame.width, y: CGFloat(i)*rightTree.frame.height)
            addChild(rightTree)
        }
    }
    
    func createPlayer() {
        player.name = "Squirrel"
        player.zPosition = 5.0
        player.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        player.position = CGPoint(x: leftTree.frame.width, y: frame.height/3)
        
        playerXPosLeft = leftTree.frame.width
        playerXPosRight = frame.width - rightTree.frame.width - player.frame.width
        addChild(player)
    }
    
    func setupCamera() {
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func moveCamera() {
        let amountToMove = CGPoint(x: 0.0, y: cameraMovePointPerSecond * CGFloat(dt))
        cameraNode.position = CGPoint(x: cameraNode.position.x + amountToMove.x, y: cameraNode.position.y + amountToMove.y)
        
        //Background
        enumerateChildNodes(withName: "Background") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.y + node.frame.height < self.cameraRect.origin.y {
                node.position = CGPoint(x: node.position.x, y: node.position.y + node.frame.height*3)
            }
        }
        
        //Grounds
        enumerateChildNodes(withName: "Tree") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.y + node.frame.height < self.cameraRect.origin.y {
                node.position = CGPoint(x: node.position.x, y: node.position.y + node.frame.height*3)
            }
        }
    }
    
    func movePlayer() {
        let amountToMove = cameraMovePointPerSecond * CGFloat(dt)
        player.position = CGPoint(x: player.position.x, y: player.position.y + amountToMove)
    }
    
    func setupObstacles() {
        for i in 1...2 {
            let sprite = SKSpriteNode(imageNamed: "Obstacle-\(i)")
            sprite.name = "Obstacle"
            obstacles.append(sprite)
        }
        let index1 = Int(arc4random_uniform(UInt32(obstacles.count-1)))
        let index2 = Int(arc4random_uniform(UInt32(obstacles.count-1)))
        let sprite1 = obstacles[index1].copy() as! SKSpriteNode
        let sprite2 = obstacles[index2].copy() as! SKSpriteNode
        sprite1.zPosition = 5.0
        sprite1.setScale(0.2)
        sprite1.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let random = Int.random(in: 0...1)
        sprite2.zPosition = 5.0
        sprite2.setScale(0.2)
        sprite2.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let distanceBetweenSprites = Double.random(in: 150...300)
        switch random{
        case 0:
            sprite1.zRotation = (.pi/2)*3
            sprite1.position = CGPoint(x: leftTree.frame.width + sprite1.frame.width/2, y: cameraRect.maxY + sprite1.frame.height/2)
            sprite2.zRotation = .pi/2
            sprite2.position = CGPoint(x: frame.width - rightTree.frame.width - sprite2.frame.width/2, y: cameraRect.maxY + sprite2.frame.height/2 + distanceBetweenSprites)
        default:
            sprite1.zRotation = .pi/2
            sprite1.position = CGPoint(x: frame.width - rightTree.frame.width - sprite1.frame.width/2, y: cameraRect.maxY + sprite1.frame.height/2)
            sprite2.zRotation = (.pi/2)*3
            sprite2.position = CGPoint(x: leftTree.frame.width + sprite2.frame.width/2, y: cameraRect.maxY + sprite2.frame.height/2 + distanceBetweenSprites)
        }
        addChild(sprite1)
        addChild(sprite2)
        sprite1.run(.sequence([
            .wait(forDuration: 3),
            .removeFromParent()
        ]))
        sprite2.run(.sequence([
            .wait(forDuration: 3),
            .removeFromParent()
        ]))
    }
    
    func spawnObstacles() {
        run(.repeatForever(.sequence([
            .wait(forDuration: CGFloat.random(in: 0.8...self.isTime)),
            .run{ [weak self] in
                self?.setupObstacles()
            }
        ])))
        
        run(.repeatForever(.sequence([
            .wait(forDuration: 6),
            .run{
                self.isTime -= 0.5
                if self.isTime < 0.8 {
                    self.isTime = 0.8
                }
            }
        ])))
    }
}

