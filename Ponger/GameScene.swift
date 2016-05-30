//
//  GameScene.swift
//  Ponger
//
//  Created by Matthew Curtner on 5/29/16.
//  Copyright (c) 2016 Matthew Curtner. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // Playable area on screen
    let playableRect: CGRect
    
    // Player elements
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var ball: SKSpriteNode!
    
    // Time Elements
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    // Default Speed and Velocity
    let ballSpeed: CGFloat = 500.0
    var velocity: CGPoint = CGPoint.zero
    
    // Player is not touching paddle
    var isFingerOnPaddle: Bool = false
    
    // Default score
    var player1Score: Int = 0
    var player2Score: Int = 0
    
    // Labels
    var player1ScoreLabel: SKLabelNode!
    var player2ScoreLabel: SKLabelNode!
    
    
    // MARK: - Game Lifecycle
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 4/3
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        setupBackground()
        
        player1 = createPaddle()
        player1.zPosition = 2
        player1.position = CGPoint(x: 40, y: frame.size.height/2)
        player1.name = "player1Paddle"
        addChild(player1)
        
        player2 = createPaddle()
        player2.zPosition = 2
        player2.position = CGPoint(x: frame.size.width - 40, y: frame.size.height/2)
        player2.physicsBody?.dynamic = false
        addChild(player2)
        
        ball = createBall()
        ball.zPosition = 2
        ball.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        addChild(ball)
        
        velocity = CGPoint(x: ballSpeed, y: 120)
        debugDrawPlayableArea()
        
        player1ScoreLabel = createScoreLabels()
        player1ScoreLabel.position = CGPoint(x: frame.size.width/2 + 60, y: frame.size.height - 130)
        addChild(player1ScoreLabel)
        
        player2ScoreLabel = createScoreLabels()
        player2ScoreLabel.position = CGPoint(x: frame.size.width/2 - 60, y: frame.size.height - 130)
        addChild(player2ScoreLabel)
    }
    
    // MARK: - Touch Methods
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.locationInNode(self)
        
        if let body = physicsWorld.bodyAtPoint(touchLocation) {
            if body.node?.name == "player1Paddle" {
                isFingerOnPaddle = true
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isFingerOnPaddle {
            let touch = touches.first
            let touchLocation = touch!.locationInNode(self)
            let previousLocation = touch?.previousLocationInNode(self)
            let paddle = childNodeWithName("player1Paddle") as! SKSpriteNode
            
            var paddleY = paddle.position.y + (touchLocation.y - (previousLocation?.y)!)
            paddleY = max(paddleY, paddle.size.height/2)
            paddleY = min(paddleY, size.height - paddle.size.height/2)
            
            paddle.position = CGPoint(x: paddle.position.x, y: paddleY)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isFingerOnPaddle = false
    }
    
    // MARK: - SpriteKit Update Loop

    override func update(currentTime: CFTimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        moveBall(velocity)
        boundsCheckBall()
        checkCollisions()
        
        // Display the score in the player score labels
        player1ScoreLabel.text = String(player1Score)
        player2ScoreLabel.text = String(player2Score)
    }
    
    // MARK: - Setup Methods
    
    /**
     Set the background color
     */
    func setupBackground() {
        backgroundColor = SKColor.blackColor()
    }
    
    /**
     Create a SKSpriteNode from the provided SKShapeNode.
     - Parameters: shape: SKShapeNode created from a previous function.
     - Returns: A SKSpriteNode
     */
    func createSpriteNodeFromShape(shape: SKShapeNode) -> SKSpriteNode {
        let texture = view?.textureFromNode(shape)
        return SKSpriteNode(texture: texture)
    }
    
    /**
     Create a SKShapeNode for the player's paddle.
     - Returns: A SKSpriteNode Paddle Object
     */
    func createPaddle() -> SKSpriteNode {
        let paddleSize: CGSize = CGSize(width: 40, height: 160)
        let paddleShape: SKShapeNode = SKShapeNode(rectOfSize: paddleSize)
        paddleShape.fillColor = SKColor.whiteColor()
        
        let paddle = createSpriteNodeFromShape(paddleShape)
        paddle.zPosition = 2
        paddle.physicsBody = SKPhysicsBody(rectangleOfSize: paddleSize)
        paddle.physicsBody?.affectedByGravity = false
        paddle.physicsBody?.dynamic = false

        return paddle
    }
    
    /**
     Create a SKShapeNode for the game ball.
     - Returns: A SKSpriteNode Ball Object
     */
    func createBall() -> SKSpriteNode {
        let ballShape: SKShapeNode = SKShapeNode(circleOfRadius: 20)
        ballShape.fillColor = SKColor.whiteColor()
        
        let ball: SKSpriteNode = createSpriteNodeFromShape(ballShape)
        ball.name = "ball"
        ball.zPosition = 2
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.angularDamping = 0

        return ball
    }
    
    // MARK: - Move Ball Methods
    
    /**
     Set the ball's position from the calculation of velocity.
     - Parameters: velocity: The current velocity of the ball
    */
    func moveBall(velocity: CGPoint) {
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
        ball.position = CGPoint(x: ball.position.x + amountToMove.x, y: ball.position.y + amountToMove.y)
    }
    
    /**
     Set the ball's position from the calculation of velocity towards a location position.
     - Parameters: location: The current location of the ball
     */
    func moveBallTowards(location: CGPoint) {
        let offset = CGPoint(x: location.x - ball.position.x, y: location.y - ball.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * ballSpeed, y: direction.y * ballSpeed)
    }
    
    // MARK: - Bounds and Collision Methods
    
    /**
     Check that the ball's position is at or greater than the bounds of the displayed screen.
     If position is greater then reverse velocity.
     */
    func boundsCheckBall() {
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        // Check if the ball's position is at the bottom or top of the screen
        if ball.position.y <= bottomLeft.y {
            ball.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if ball.position.y >= topRight.y {
            ball.position.y = topRight.y
            velocity.y = -velocity.y
        }
        
        // Check if the ball's position is at the left or right of the screen
        if ball.position.x >= topRight.x {
            updateScore("Player2")
            resetBall()
        }
        if ball.position.x <= bottomLeft.x {
            updateScore("Player1")
            resetBall()
        }
    }
    
    /**
     Check if a collision has occurred between either paddles and the ball. If a
     collision has occurred, then reverse velocity.
     */
    func checkCollisions() {
        if CGRectIntersectsRect(ball.frame, player2.frame) {
            velocity.x = -velocity.x
        }
        if CGRectIntersectsRect(ball.frame, player1.frame) {
            velocity.x = -velocity.x
        }
    }
    
    /**
     Remove the ball object from parent and then create a new instance of ball.
     Sets the ball's velocity to a random Y-Axis value based on screen height.
     */
    func resetBall() {
        ball.removeFromParent()
        
        ball = createBall()
        ball.zPosition = 2
        ball.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        addChild(ball)
        
        let randomY: CGFloat = CGFloat(Int(arc4random_uniform(UInt32(self.frame.size.height))))
        velocity = CGPoint(x: -ballSpeed, y: randomY)
    }
    
    // MARK: - Score
    /**
     Creates the default SKLabelNode for player's scores
     - Returns: A SKLabelNode with a font size of 120
     */
    func createScoreLabels() -> SKLabelNode {
        let scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontSize = 120
        return scoreLabel
    }
    
    /**
     Updates the player's score by 1
     - Parameters: player: Either 'Player1' or "Player2'
     */
    func updateScore(player: String) {
        if player == "Player1" {
            player1Score += 1
        } else {
            player2Score += 1
        }
    }

    /**
     Draw a red rectangle around the playable screen. For debug purposes only.
     */
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
}