//
//  AudioPlayer.swift
//  NC2_4Head
//
//  Created by Marco Agizza on 13/12/22.
//
import SpriteKit
import AVKit

protocol AudioPlayer {
    var musicVolume: Float { get set }
    func play(music: Music)
    func pause(music: Music)
    
    var effectsVolume: Float { get set }
    func play(effect: Effect)
}
