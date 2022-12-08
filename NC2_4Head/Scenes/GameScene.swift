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
    var backgoundImage = SKSpriteNode(imageNamed: "BackgroundImage")
    var leftTree = SKSpriteNode()
    var rightTree = SKSpriteNode()
    var player = SKSpriteNode(imageNamed: "Squirrel")
    
    var cameraNode = SKCameraNode()
    var cameraMovePointPerSecond: CGFloat = 450.0
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    // MARK: System
    
    override func didMove(to view: SKView) {
        createBackground()
        createTrees()
        createPlayer()
        setupCamera()
        //setupNodes()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        moveCamera()
    }
}

extension GameScene {
    
    func setupNodes() {
        
    }
    
    func createBackground() {
        backgoundImage.anchorPoint = .zero
        backgoundImage.position = .zero
        backgoundImage.zPosition = -1.0
        addChild(backgoundImage)
    }
    
    func createTrees() {
        for i in 0...2 {
            leftTree = SKSpriteNode(imageNamed: "LeftTree")
            leftTree.name = "LeftTree"
            leftTree.anchorPoint = .zero
            leftTree.zPosition = 1.0
            leftTree.position = CGPoint(x: 0.0, y: CGFloat(i)*leftTree.frame.height)
            addChild(leftTree)
            rightTree = SKSpriteNode(imageNamed: "RightTree")
            rightTree.name = "RightTree"
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
    }
}
