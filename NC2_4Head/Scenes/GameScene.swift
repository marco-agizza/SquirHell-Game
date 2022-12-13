//
//  GameScene.swift
//  NC2_4Head
//
//  Created by Marco Agizza on 07/12/22.
//

import SpriteKit
import GameplayKit
import AudioToolbox

class GameScene: SKScene {
    // MARK: Properties
    var background = SKSpriteNode()
    var leftTree = SKSpriteNode()
    var rightTree = SKSpriteNode()
    var fire = SKSpriteNode()
    var scale: CGFloat = 2.0
    
    // Player
    var player = SKSpriteNode(imageNamed: "SquirrelLeft-0")
    var playerReference = SKSpriteNode()
    var playerGameOverReference = SKSpriteNode()
    var onLeftTree = true
    var onTree = true
    var velocityX: CGFloat = 0.0
    var playerXPosLeft: CGFloat = 0.0
    var playerXPosRight: CGFloat = 0.0
    var playerYPos: CGFloat = 0.0
    var squirrelStepFrequency = 0.083
    
    // Play
    var gameIsStarted = false {
        didSet {
            setupObstacles()
            spawnObstacles()
        }
    }
    var numScore: Double = 0
    var gameOver = false
    var nutIcon: SKSpriteNode!
    var scoreLabel = SKLabelNode(fontNamed: "Atari ST 8x16 System Font")
    
    var pauseNode: SKSpriteNode!
    var containerNode = SKNode()
    
    // Block & Obstacles
    var numBlock = 1
    var numObstacles = 1
    var obstaclesAndBlocks: [SKSpriteNode] = []
    
    // Camera
    var cameraNode = SKCameraNode()
    var cameraMovePointPerSecond: CGFloat = 450.0 {
        didSet {
            print("camera speeds up")
        }
    }
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    // Delay for obstacles random generation
    var maxTime = 2.0 {
        didSet {
            print(maxTime)
        }
    }
    var minTime = 0.8
    
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
        createFire()
        createPlayer()
        setupScore()
        setupPause()
        setupCamera()
        setupPhysics()
        print(self.maxTime)
        //setupNodes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location (in: self))
        if node.name == "pause" {
            if isPaused { return }
            createPanel()
            lastUpdateTime = 0.0
            dt = 0.0
            isPaused = true
        } else if node.name == "resume" {
            containerNode.removeFromParent()
            isPaused = false
        } else if node.name == "quit" {
            //presentScene(MainMenu(size: size))
        } else {
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
        
    }
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
//        numScore = cameraMovePointPerSecond/100
        lastUpdateTime = currentTime
        moveCamera()
        movePlayer()
        updateScore()
        
        player.position.x += velocityX
        if player.position.x < frame.width/2 {
            player.xScale = scale
        } else if player.position.x > frame.width/2 {
            player.xScale = -scale
        }
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
        print("the position is \(player.position.y) and should be \(playerReference.position.y)")
        // TODO: i've to compare the y coordinate with the y cordinate of an hidden obj locked on the screen
        if player.position.y < playerReference.position.y {
            if gameIsStarted {
                player.position.y += 0.3
            } else {
                player.position.y += 2.0
            }
            if player.position.y > playerReference.position.y {
                if !gameIsStarted {
                    gameIsStarted.toggle()
                }
                player.position.y = playerReference.position.y
            }
        }
        
        if player.position.y < playerGameOverReference.position.y {
            gameOver = true
        }
        
        if gameOver {
            let scene = GameOver(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsCloseVertical(withDuration: 0.8))
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
    
    func createFire() {
        fire = SKSpriteNode(imageNamed: "Fire-1")
        fire.setScale(scale)
        fire.name = "Fire"
        fire.zPosition = 50.0
        fire.position = CGPoint(x: frame.width/2, y: 20)
        var textures: [SKTexture] = []
        for i in 0...1 {
            textures.append(SKTexture (imageNamed: "Fire-\(i)"))
        }
        fire.run(.repeatForever(.animate(with: textures, timePerFrame: squirrelStepFrequency)))
        addChild(fire)
    }
    
    func createPlayer() {
        player.name = "Squirrel"
        player.zPosition = 5.0
        player.setScale(scale)
        player.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        player.position = CGPoint(x: leftTree.frame.width + player.frame.width/2, y: 0.0)
        
        playerXPosLeft = leftTree.frame.width + player.frame.width/2
        playerXPosRight = frame.width - rightTree.frame.width - player.frame.width/2
        playerYPos = frame.height/3
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.restitution = 0.0
        player.physicsBody!.categoryBitMask = PhysicsCategory.Player
        player.physicsBody!.contactTestBitMask = PhysicsCategory.Obstacle
        player.physicsBody?.allowsRotation = false
        
        playerReference.zPosition = -5.0
        playerReference.position = CGPoint(x: leftTree.frame.width + player.frame.width/2, y: frame.height/4)
        playerGameOverReference.zPosition = -5.0
        playerGameOverReference.position = CGPoint(x: leftTree.frame.width + player.frame.width/2, y: 0)
        
        var textures: [SKTexture] = []
        for i in 0...3 {
            textures.append (SKTexture (imageNamed: "SquirrelLeft-\(i)"))
        }
        player.run(.repeatForever(.animate(with: textures, timePerFrame: squirrelStepFrequency)))
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
        playerReference.position = CGPoint(x: playerReference.position.x, y: playerReference.position.y + amountToMove)
        playerGameOverReference.position = CGPoint(x: playerGameOverReference.position.x, y: playerGameOverReference.position.y + amountToMove)
        
    }
    
    // Increase the score with time
    func updateScore() {
        let scoreIncrement = 0.01
        
        numScore += scoreIncrement
        scoreLabel.text = "\(Int(numScore.rounded()) * 10)"
    }
    
    func setupObstacles() {
        for i in 1 ... numBlock {
            let sprite = SKSpriteNode(imageNamed: "Block-\(i)")
            sprite.name = "Block"
            obstaclesAndBlocks.append(sprite)
        }
        for i in 1 ... numObstacles {
            let sprite = SKSpriteNode(imageNamed: "Obstacle-\(i)")
            sprite.name = "Obstacle"
            obstaclesAndBlocks.append(sprite)
        }
        let index1 = Int(arc4random_uniform(UInt32(obstaclesAndBlocks.count-1)))
        let index2 = Int(arc4random_uniform(UInt32(obstaclesAndBlocks.count-1)))
        let sprite1 = obstaclesAndBlocks[index1].copy() as! SKSpriteNode
        let sprite2 = obstaclesAndBlocks[index2].copy() as! SKSpriteNode
        if sprite1.name == "Obstacle"{
            sprite1.setScale(scale)
        }else{
            sprite1.setScale(0.2)
        }
        if sprite2.name == "Obstacle"{
            sprite2.setScale(scale)
        }else{
            sprite2.setScale(0.2)
        }
        sprite1.zPosition = 5.0
        sprite1.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let random = Int.random(in: 0...1)
        sprite2.zPosition = 5.0
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
        sprite1.physicsBody = SKPhysicsBody(rectangleOf: sprite1.size)
        sprite1.physicsBody!.affectedByGravity = false
        sprite1.physicsBody!.isDynamic = false
        if sprite1.name == "Obstacle" {
            sprite1.physicsBody!.categoryBitMask = PhysicsCategory.Obstacle
        } else {
            sprite1.physicsBody!.categoryBitMask = PhysicsCategory.Block
        }
        sprite2.physicsBody = SKPhysicsBody(rectangleOf: sprite1.size)
        sprite2.physicsBody!.affectedByGravity = false
        sprite2.physicsBody!.isDynamic = false
        if sprite2.name == "Obstacle" {
            sprite2.physicsBody!.categoryBitMask = PhysicsCategory.Obstacle
        } else {
            sprite2.physicsBody!.categoryBitMask = PhysicsCategory.Block
        }
        sprite1.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        sprite2.physicsBody!.contactTestBitMask = PhysicsCategory.Player
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
            .wait(forDuration: CGFloat.random(in: minTime ... maxTime)),
            .run{ [weak self] in
                self?.setupObstacles()
            }
        ])))
        
        run(.repeatForever(.sequence([
            .wait(forDuration: 10.0),
            .run{
                self.cameraMovePointPerSecond += 100
                self.maxTime -= 0.5
                if self.maxTime < self.minTime {
                    self.maxTime = self.minTime
                }
            }
        ])))
    }
    
    func setupPhysics() {
        physicsWorld.contactDelegate = self
    }
    
    func setupScore() {
        // Nut icon
        nutIcon = SKSpriteNode(imageNamed: "Nut-0")
        
        // Score label
        scoreLabel.text = "\(numScore)"
        scoreLabel.fontSize = 60
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.zPosition = 50.0
        
        setupScorePos(nutIcon, i: 2.0, j: 4.0)
        scoreLabel.position = CGPoint(x:  nutIcon.position.x + nutIcon.frame.width,
                                      y: nutIcon.position.y + nutIcon.frame.height-8.0)
        cameraNode.addChild(scoreLabel)
    }
    
    func setupScorePos(_ node: SKSpriteNode, i: CGFloat, j: CGFloat) {
        let width = playableRect.width
        let height = playableRect.height
        
        node.setScale(0.6)
        node.zPosition = 50.0
        node.position = CGPoint(x: -width/2.0 + node.frame.width * i + j - 15.0,
                                y: height/3.0 + node.frame.height)
        cameraNode.addChild(node)
    }
    
    func setupPause () {
        pauseNode = SKSpriteNode (imageNamed: "pause")
        pauseNode.setScale (0.25)
        pauseNode.zPosition = 50.0
        pauseNode.name = "pause"
        pauseNode.position = CGPoint(x: playableRect.width/2.0 - pauseNode.frame.width/2.0 - 30.0,
                                     y: playableRect.height/3.0 + nutIcon.frame.height-8.0)
        cameraNode.addChild (pauseNode)
    }
    
    func createPanel() {
        cameraNode.addChild(containerNode)
        let panel = SKSpriteNode (imageNamed: "panel")
        panel.zPosition = 60.0
        panel.position = .zero
        containerNode.addChild(panel)
        let resume = SKSpriteNode (imageNamed: "resume")
        resume.zPosition = 70.0
        resume.name = "resume"
        resume.setScale (0.4)
        resume.position = CGPoint (x: -panel.frame.width/2.0 + resume.frame.width*1.5, y: 0.0)
        panel.addChild(resume)
        let quit = SKSpriteNode (imageNamed: "back")
        quit.zPosition = 70.0
        quit.name = "quit"
        quit.setScale(0.4)
        quit.position = CGPoint(x: panel.frame.width/2.0 - quit.frame.width*1.5, y: 0.0)
        panel.addChild(quit)
    }
}

//MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        switch other.categoryBitMask {
        case PhysicsCategory.Block:
            print("Block")
        case PhysicsCategory.Obstacle:
            gameOver = true
            print("Game Over")
        default: break
        }
    }
}
