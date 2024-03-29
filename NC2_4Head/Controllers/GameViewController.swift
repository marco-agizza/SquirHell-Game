//
//  GameViewController.swift
//  NC2_4Head
//
//  Created by Marco Agizza on 07/12/22.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let scene = MainMenuScene(size: CGSize(width: view.frame.width, height: view.frame.height))
//            let scene = GameScene(size: CGSize(width: view.frame.width, height: view.frame.height))
            scene.scaleMode = .aspectFill
            
            view.presentScene(scene)
                
//                = SKScene(fileNamed: "GameScene") {
//                    // Set the scale mode to scale to fit the window
//                    scene.scaleMode = .aspectFill
//
//                    // Present the scene
//                    view.presentScene(scene)
//                }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
