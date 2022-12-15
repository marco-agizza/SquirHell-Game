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
    var gameIsStarted = false
    var numScore = 0.0
    var gameOver = false
    var nutIcon: SKSpriteNode!
    var scoreLabel = SKLabelNode(fontNamed: "Atari ST 8x16 System Font")
    var nextScoreFinishLine = 100.0
    var timerObstacleSpawn = 60.0*2.0
    var timerObstacleSpawnIncrement = 60.0*10 //each 10 sec i will decrease the timerObstacleSpawn until 60.0*0.8 (every 0.8 secs)
    var tempTimerObstacle = 60.0*2.0
    var tempTimerObstacleIncrement = 0.0
    
    
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
    var minTime = 60 * 0.6
    
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
            if !isPaused {
                SKTAudio.sharedInstance().playSoundEffect("Button-Press.m4a")
            }
            if isPaused { return }
            createPanel()
            lastUpdateTime = 0.0
            dt = 0.0
            isPaused = true
        } else if node.name == "resume" {
            SKTAudio.sharedInstance().playSoundEffect("Button-Press.m4a")
            containerNode.removeFromParent()
            isPaused = false
        } else if node.name == "quit" {
            SKTAudio.sharedInstance().playSoundEffect("Button-Press.m4a")
            let scene = MainMenuScene(size: CGSize(width: frame.width, height: frame.height))
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsOpenVertical(withDuration: 0.3))
        } else {
            if !isPaused {
                SKTAudio.sharedInstance().playSoundEffect("Jump-Sound.m4a")
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
        moveBackground()
        moveFire()
        updateScore()
        
        if gameIsStarted {
            // to manage obstacle spawn
            tempTimerObstacleIncrement += 1.0
            tempTimerObstacle += 1.0
            // each timerObstacleSpawnIncrement frames, increment the frequency of obstacle spawn
            if tempTimerObstacleIncrement >= timerObstacleSpawnIncrement {
                print("10 sec passed")
                tempTimerObstacleIncrement = 0
                timerObstacleSpawn -= 60 * 0.8
                if timerObstacleSpawn <= minTime {
                    print("increment frequency")
                    timerObstacleSpawn = minTime
                    cameraMovePointPerSecond += 200
                    if cameraMovePointPerSecond > 900{
                        cameraMovePointPerSecond = 900
                    }
                }
            }
            if tempTimerObstacle >= timerObstacleSpawn {
                tempTimerObstacle = 0
                setupObstacles()
                print("Obstacle generation")
            }
        }
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
                        goToGameOver()
                    }

        func goToGameOver() {
            let scene = GameOver(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsCloseVertical(withDuration: 0.8))
        }
    }
}

extension GameScene {
    
    func createBackground() {
        background = SKSpriteNode(imageNamed: "BackgroundImage")
        background.setScale(scale)
        background.name = "Background"
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
    
    func moveFire(){
        let amountToMove = cameraMovePointPerSecond * CGFloat(dt)
        fire.position = CGPoint(x: fire.position.x, y: fire.position.y + amountToMove)
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
        
        //Grounds
        enumerateChildNodes(withName: "Tree") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.y + node.frame.height < self.cameraRect.origin.y {
                node.position = CGPoint(x: node.position.x, y: node.position.y + node.frame.height*3)
            }
        }
    }
    
    func moveBackground() {
        let amountToMove = cameraMovePointPerSecond * CGFloat(dt)
        background.position = CGPoint(x: background.position.x, y: background.position.y + amountToMove)
    }
    
    func movePlayer() {
        let amountToMove = cameraMovePointPerSecond * CGFloat(dt)
        player.position = CGPoint(x: player.position.x, y: player.position.y + amountToMove)
        playerReference.position = CGPoint(x: playerReference.position.x, y: playerReference.position.y + amountToMove)
        playerGameOverReference.position = CGPoint(x: playerGameOverReference.position.x, y: playerGameOverReference.position.y + amountToMove)
    }
    
    // Translate background score to displayed score
    func displayedScore(numScore: Double) -> Int {
        return Int(numScore.rounded()) * 10
    }
    
    // Increase the score with time
    func updateScore() {
        let scoreIncrement = 0.01
        
        numScore += scoreIncrement
        scoreLabel.text = "\(displayedScore(numScore: numScore))m"
        scoreLabel.fontColor = UIColor.black
        
        let highscore = ScoreGenerator.sharedInstance.getHighscore()
        let score = displayedScore(numScore: numScore)
        if score > highscore {
            ScoreGenerator.sharedInstance.setHighscore(score)
        } else {
            ScoreGenerator.sharedInstance.setScore(score)
        }
            
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
        sprite1.setScale(scale)
        sprite2.setScale(scale)
        sprite1.zPosition = 6.0
        sprite1.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let random = Int.random(in: 0...1)
        sprite2.zPosition = 6.0
        sprite2.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let distanceBetweenSprites = Double.random(in: 150...300)
        switch random{
        case 0:
            //sprite1.zRotation = (.pi/2)*3
            sprite1.position = CGPoint(x: leftTree.frame.width-3 + sprite1.frame.width/2, y: cameraRect.maxY + sprite1.frame.height/2)
            sprite2.xScale = -scale
            sprite2.position = CGPoint(x: frame.width+3 - rightTree.frame.width - sprite2.frame.width/2, y: cameraRect.maxY + sprite2.frame.height/2 + distanceBetweenSprites)
        default:
            sprite1.xScale = -scale
            sprite1.position = CGPoint(x: frame.width+3 - rightTree.frame.width - sprite1.frame.width/2, y: cameraRect.maxY + sprite1.frame.height/2)
            //sprite2.zRotation = (.pi/2)*3
            sprite2.position = CGPoint(x: leftTree.frame.width-3 + sprite2.frame.width/2, y: cameraRect.maxY + sprite2.frame.height/2 + distanceBetweenSprites)
        }
        if sprite1.name == "Obstacle" {
            sprite1.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite1.frame.width-65, height: sprite1.frame.height-10))
            sprite1.physicsBody!.categoryBitMask = PhysicsCategory.Obstacle
        } else {
            sprite1.physicsBody = SKPhysicsBody(rectangleOf: sprite1.size)
            sprite1.physicsBody!.categoryBitMask = PhysicsCategory.Block
        }
        if sprite2.name == "Obstacle" {
            sprite2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite2.frame.width-65, height: sprite2.frame.height-10))
            sprite2.physicsBody!.categoryBitMask = PhysicsCategory.Obstacle
        } else {
            sprite2.physicsBody = SKPhysicsBody(rectangleOf: sprite2.size)
            sprite2.physicsBody!.categoryBitMask = PhysicsCategory.Block
        }
        sprite1.physicsBody!.affectedByGravity = false
        sprite1.physicsBody!.isDynamic = false
        sprite2.physicsBody!.affectedByGravity = false
        sprite2.physicsBody!.isDynamic = false
        
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
    
    func setupPhysics() {
        physicsWorld.contactDelegate = self
    }
    
    func setupScore() {
        // Nut icon
        nutIcon = SKSpriteNode(imageNamed: "Nut-0")
        
        // Score label
        scoreLabel.text = "\(numScore)m"
        scoreLabel.fontSize = 60
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.zPosition = 50.0
        
        setupScorePos(nutIcon, i: 2.0, j: 4.0)
        nutIcon.zPosition = -50
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
        pauseNode = SKSpriteNode (imageNamed: "PauseButton")
        pauseNode.setScale (scale)
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
        let resume = SKSpriteNode (imageNamed: "ResumeButton")
        resume.setScale(scale)
        resume.zPosition = 70.0
        resume.name = "resume"
        resume.setScale (0.4)
        resume.position = CGPoint (x: -panel.frame.width/2.0 + resume.frame.width*1.5, y: 0.0)
        panel.addChild(resume)
        let quit = SKSpriteNode (imageNamed: "GoToMenuButton")
        quit.setScale(scale)
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
            SKTAudio.sharedInstance().playSoundEffect("Block-Hit.m4a")
        case PhysicsCategory.Obstacle:
            gameOver = true
            SKTAudio.sharedInstance().playSoundEffect("Hit-Obstacle.m4a")
        default: break
        }
    }
}
