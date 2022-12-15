//
//  ScoreGenerator.swift
//  SquirHell
//
//  Created by Ilia Sedelkin on 15/12/22.
//

import Foundation

class ScoreGenerator {
    
    static let sharedInstance = ScoreGenerator()
    private init() {}
    
    static let keyScore = "keyScore"
    static let keyHighscore = "keyHighscore"
    
    func setScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: ScoreGenerator.keyScore)
    }
    
    func getScore() -> Int {
        return UserDefaults.standard.integer(forKey: ScoreGenerator.keyScore)
    }
    
    func setHighscore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: ScoreGenerator.keyHighscore)
    }
    
    func getHighscore() -> Int {
        return UserDefaults.standard.integer(forKey: ScoreGenerator.keyHighscore)
    }
}

