//
//  GameScene.swift
//  Ponger
//
//  Created by Matthew Curtner on 5/29/16.
//  Copyright (c) 2016 Matthew Curtner. All rights reserved.
//

import SpriteKit

enum Layer: CGFloat {
    case Background = 0
    case Ball = 1
    case Paddle = 2
}


class GameScene: SKScene {
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var ball: SKSpriteNode!
    
    
    override func didMoveToView(view: SKView) {
        setupBackground()
        
        player1 = createPaddle()
        player1.zPosition = Layer.Paddle.rawValue
        player1.position = CGPoint(x: frame.size.width/2, y: 15)
        addChild(player1)
        
        player2 = createPaddle()
        player2.zPosition = Layer.Paddle.rawValue
        player2.position = CGPoint(x: frame.size.width/2, y: frame.size.height - 15)
        addChild(player2)
        
        ball = createBall()
        ball.zPosition = Layer.Ball.rawValue
        ball.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        addChild(ball)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
   
    override func update(currentTime: CFTimeInterval) {
    }
    
    // MARK: - Setup Methods
    
    func setupBackground() {
        backgroundColor = SKColor.blackColor()
    }
    
    func createSpriteNodeFromShape(shape: SKShapeNode) -> SKSpriteNode {
        let texture = view?.textureFromNode(shape)
        return SKSpriteNode(texture: texture)
    }
    
    func createPaddle() -> SKSpriteNode {
        let paddleSize: CGSize = CGSize(width: 60, height: 20)
        let paddleShape: SKShapeNode = SKShapeNode(rectOfSize: paddleSize)
        paddleShape.fillColor = SKColor.whiteColor()
        
        return createSpriteNodeFromShape(paddleShape)
    }
    
    func createBall() -> SKSpriteNode {
        let ballShape: SKShapeNode = SKShapeNode(circleOfRadius: 10)
        ballShape.fillColor = SKColor.whiteColor()
        return createSpriteNodeFromShape(ballShape)
    }
}