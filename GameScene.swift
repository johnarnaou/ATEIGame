//
//  GameScene.swift
//  Survivor
//
//  Created by John Arnaoutakis on 09/10/2017.
//  Copyright © 2017 John Arnaoutakis. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let Rick: UInt32 = 0x1 << 1
    static let Ground: UInt32 = 0x1 << 2
    static let Enemy: UInt32 = 0x1 << 3
    static let Shoot : UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Ground = SKSpriteNode()
    var rick = Rick(direction:true)
    var shoot = Shoot(direction:true)
    var morty = Morty(direction:true)
    var spaceship = SpaceShip(direction: true)
    
    var spaceShipAdded : Bool = false
    var gameStarted : Bool = false
    var startBTN = SKSpriteNode()
    
    var died = Bool()
    var score : Int = 0
    var scoreLbl = SKLabelNode()
    
    var restartBTN = SKSpriteNode()
    
    var resumeBTN = SKSpriteNode()
    var rickMenu = SKSpriteNode()
    var mortyMenu = SKSpriteNode()
    var scoresBTN = SKSpriteNode()
    
    var pauseBTN = SKSpriteNode()
    var leftBTN = SKSpriteNode()
    var rightBTN = SKSpriteNode()
    var portalGun = SKSpriteNode()
    
    var hearts : [SKSpriteNode] = []
    
    var moveLeft : Bool = false
    var moveRight : Bool = false
    var lastDirect : Bool = true
    var talked : Bool = false
    var lives : Int = 5
    
    var spawn = 10
    var spawned = true
    var first = true
    
    override func sceneDidLoad() {
        
        self.view?.isMultipleTouchEnabled = true
        createStartScene()
        
    }
    
    func createStartScene(){
        let background = SKSpriteNode(imageNamed: "Background")
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint(x: -self.frame.width/2, y: -self.frame.height/4)
        background.name = "background"
        
        self.addChild(background)
        
        startBTN = SKSpriteNode(imageNamed: "start")
        startBTN.position = CGPoint(x: 0, y: 0)
        startBTN.size = CGSize(width: 400, height: 158)
        startBTN.zPosition = 3
        self.addChild(startBTN)
    }
    
    func restartGame(){
        self.removeAllChildren()
        self.removeAllActions()
        
        gameStarted = true
        
        died = false
        lives = 5
        score = 0
        
        spawn = 10
        
        createScenery()
        
        createRick(direction:true, point:CGPoint(x:-200,y:0))
        
        createMenu()
        
        createControls()
        
//        self.run(SKAction.repeatForever(
//            SKAction.sequence([
//                SKAction.run(self.addEnemy),
//                SKAction.wait(forDuration: TimeInterval(self.spawn))
//                ])))
    }
    
    func createRestartButton(){
        self.removeAllChildren()
        self.removeAllActions()
        
        createScenery()
        
        restartBTN = SKSpriteNode(imageNamed: "restartBTN")
        restartBTN.size = CGSize(width: 200, height: 200)
        restartBTN.position = CGPoint(x: 0, y: 0)
        restartBTN.zPosition = 6
        restartBTN.setScale(0)
        self.addChild(restartBTN)
        restartBTN.run(SKAction.scale(to: 1.0, duration: 0.3))
        
    }
    func startScene(){
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        lives = 5
        score = 0
        createScene()
    }
    
    func createScenery() {
        let background = SKSpriteNode(imageNamed: "Background")
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint(x: -self.frame.width/2, y: -self.frame.height/4)
        background.name = "background"
        
        self.addChild(background)
        
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(0.5)
        Ground.position = CGPoint(x: 0, y: -self.frame.height/7)
        Ground.size = CGSize(width: self.frame.width, height: Ground.size.height)
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        Ground.zPosition = 3
        self.addChild(Ground)
        
        createHearts()
    }
    
    func createHearts(){
        var pos = 30
        if lives > 0 {
            for _ in 0...lives-1 {
                let Heart1 = SKSpriteNode(imageNamed: "filledHeart")
                Heart1.size = CGSize(width: 40, height: 40)
                Heart1.position = CGPoint(x: -self.frame.width/2 + CGFloat(pos), y: self.frame.height/7)
                Heart1.zPosition = 6
                self.addChild(Heart1)
                hearts.append(Heart1)
                pos += 40
            }
            if(5-lives > 0){
                for _ in 0...4-lives {
                    let Heart1 = SKSpriteNode(imageNamed: "emptyHeart")
                    Heart1.size = CGSize(width: 40, height: 40)
                    Heart1.position = CGPoint(x: -self.frame.width/2 + CGFloat(pos), y: self.frame.height/7)
                    Heart1.zPosition = 6
                    self.addChild(Heart1)
                    hearts.append(Heart1)
                    pos += 40
                }
            }
        }
    }
    func createIntro() {
        morty = Morty(direction: true)
        
        morty.position = CGPoint(x: 300, y: 0)
        morty.physicsBody = SKPhysicsBody(circleOfRadius: morty.frame.height / 3)
        morty.physicsBody?.categoryBitMask = PhysicsCategory.Rick
        morty.physicsBody?.collisionBitMask = PhysicsCategory.Enemy | PhysicsCategory.Ground
        morty.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.Ground
        morty.physicsBody?.affectedByGravity = true
        morty.physicsBody?.isDynamic = true
        morty.physicsBody?.allowsRotation = false
        morty.zPosition = 4
        self.addChild(morty)
        
        let actionMove = SKAction.moveTo(x: 0, duration: 2)
        actionMove.timingMode = .easeInEaseOut
        morty.run(actionMove)
    }
    
    func space(){
        spaceship = SpaceShip(direction:true)
        spaceship.position = CGPoint(x:30, y:300)
        spaceship.size = CGSize(width: 130, height: 125)
        spaceship.zPosition = 10
        self.addChild(spaceship)
        
        let actionMove = SKAction.move(to: CGPoint(x:-90, y: 150), duration: 2)
        actionMove.timingMode = .easeIn
        
        let action = SKAction.move(to: CGPoint(x:0, y:-10), duration: 2)
        action.timingMode = .easeOut
        
        spaceship.run(SKAction.sequence([actionMove,action]))
    }
    
    func talk() {
        let text1 = SKSpriteNode(imageNamed: "helpRick")
        text1.position = CGPoint(x:morty.position.x - 50, y: morty.position.y + 70)
        text1.zPosition = 999
        text1.size = CGSize(width: 174, height: 70)
        self.addChild(text1)
        
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            text1.removeFromParent()
            
            let text2 = SKSpriteNode(imageNamed: "mortyyy")
            text2.position = CGPoint(x:self.rick.position.x + 50, y: self.rick.position.y + 70)
            text2.zPosition = 999
            text2.size = CGSize(width: 174, height: 70)
            self.addChild(text2)
            
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                text2.removeFromParent()
                
                let text3 = SKSpriteNode(imageNamed: "jeez")
                text3.position = CGPoint(x:self.morty.position.x - 50, y: self.morty.position.y + 70)
                text3.zPosition = 999
                text3.size = CGSize(width: 174, height: 70)
                self.addChild(text3)
                
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when) {
                    text3.removeFromParent()
                    self.stealMorty()
                }
                
            }
        }
    }
    
    func stealMorty(){
        let action = SKAction.move(to: spaceship.position, duration: 1.5)
        action.timingMode = .easeInEaseOut
        let remove = SKAction.removeFromParent()
        morty.run(SKAction.sequence([action,remove]))
        
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            let spaceShipAction = SKAction.move(to: CGPoint(x:300, y:400), duration: 2)
            spaceShipAction.timingMode = .easeInEaseOut
            self.spaceship.run(SKAction.sequence([spaceShipAction,remove]))
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.createControls()
//                self.run(SKAction.repeatForever(
//                    SKAction.sequence([
//                        SKAction.run(self.addEnemy),
//                        SKAction.wait(forDuration: TimeInterval(self.spawn))
//                        ])))
            }
        }
        
    }
    
    func createScene() {
        self.physicsWorld.contactDelegate = self
        
        createScenery()
        
        createRick(direction:true, point:CGPoint(x:-200,y:0))
        
        createMenu()
        
        createIntro()
        
    }
    
    func pauseGame() {
        self.physicsWorld.speed = 0
        self.removeChildren(in: [leftBTN,rightBTN,portalGun,pauseBTN,scoreLbl])
        
        for node in self.children {
            if (node.physicsBody?.categoryBitMask == PhysicsCategory.Enemy){
                node.speed = 0
            }
        }
        gameStarted = false
        displayMenu()
    }
    
    func displayMenu(){
        let actionRick = SKAction.moveTo(x: self.frame.maxX - 100, duration: 0.7)
        actionRick.timingMode = .easeInEaseOut
        
        rickMenu.run(actionRick)
        
        let actionMorty = SKAction.moveTo(x: -self.frame.maxX + 100, duration: 0.7)
        actionMorty.timingMode = .easeInEaseOut
        
        mortyMenu.run(actionMorty)
        
        let actionResume = SKAction.moveTo(y: 100, duration: 0.7)
        actionResume.timingMode = .easeInEaseOut
        
        resumeBTN.run(actionResume)
        
        let actionScores = SKAction.moveTo(y: -20, duration: 0.7)
        actionScores.timingMode = .easeInEaseOut
        
        scoresBTN.run(actionScores)
    }
    
    func createMenu(){
        rickMenu = SKSpriteNode(imageNamed: "rickMenu")
       
        rickMenu.size = CGSize(width: 201, height: 450)
        rickMenu.zPosition = 10
        rickMenu.position = CGPoint(x: self.frame.width + 400, y: 0)
        
        addChild(rickMenu)
        
        mortyMenu = SKSpriteNode(imageNamed: "mortyMenu")
        
        mortyMenu.size = CGSize(width: 212, height: 250)
        mortyMenu.zPosition = 10
        mortyMenu.position = CGPoint(x: -self.frame.width - 400, y: -100 )
        
        addChild(mortyMenu)
        
        resumeBTN = SKSpriteNode(imageNamed: "resume")
        
        resumeBTN.size = CGSize(width: 300, height: 108)
        resumeBTN.zPosition = 10
        resumeBTN.position = CGPoint(x: 0, y: self.frame.height + 400 )
        
        addChild(resumeBTN)
        
        scoresBTN = SKSpriteNode(imageNamed: "scoresButton")
        
        scoresBTN.size = CGSize(width: 300, height: 108)
        scoresBTN.zPosition = 10
        scoresBTN.position = CGPoint(x: 0, y: self.frame.height + 400 )
        
        addChild(scoresBTN)
    }
    
    func resume(){
        let actionResume = SKAction.moveTo(y: self.frame.height + 400, duration: 0.7)
        actionResume.timingMode = .easeInEaseOut
        
        resumeBTN.run(actionResume)
        
        scoresBTN.run(actionResume)
        
        let actionMorty = SKAction.moveTo(x: -self.frame.width - 400, duration: 0.7)
        actionMorty.timingMode = .easeInEaseOut
        
        mortyMenu.run(actionMorty)
        
        let actionRick = SKAction.moveTo(x: self.frame.width + 400, duration: 0.7)
        actionRick.timingMode = .easeInEaseOut
        
        rickMenu.run(actionRick)
        
        createControls()
        
        self.physicsWorld.speed = 1.0
        
        for node in self.children {
            if(node.physicsBody?.categoryBitMask == PhysicsCategory.Enemy){
                node.speed = 1.0
            }
        }
        gameStarted = true
    }
    
    func randomEnemy() -> Bool {
        let num = random(min: -1, max: 1)
        if(num > 0){
            return true
        } else {
            return false
        }
    }
    
    func attack(direction:Bool,point:CGPoint){
        shoot = Shoot(direction:direction)
        
        var direct = 30
        if (!direction){
            shoot.position = CGPoint(x:point.x - 5, y:point.y)
            direct = -30
        } else {
            shoot.position = CGPoint(x:point.x + 5, y:point.y)
        }
        
        shoot.size = CGSize(width:40, height:40)
        shoot.physicsBody = SKPhysicsBody(circleOfRadius: shoot.frame.height / 3)
        shoot.physicsBody?.isDynamic = true
        shoot.physicsBody?.categoryBitMask = PhysicsCategory.Shoot
        shoot.physicsBody?.collisionBitMask = PhysicsCategory.Enemy
        shoot.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        shoot.physicsBody?.affectedByGravity = false
        shoot.zPosition = 3
        self.addChild(shoot)
        
        
        
        let move = SKAction.moveBy(x: CGFloat(direct), y: 0, duration: 0.1)
        shoot.run(SKAction.repeatForever(move))
    }
    
    func createControls(){
        leftBTN = SKSpriteNode(imageNamed: "left")
        leftBTN.name = "left"
        leftBTN.size = CGSize(width: 50, height: 50)
        leftBTN.position = CGPoint(x: -self.frame.width/2 + 40, y: -self.frame.height/8)
        leftBTN.zPosition = 6
        
        self.addChild(leftBTN)
        
        rightBTN = SKSpriteNode(imageNamed: "right")
        rightBTN.name = "right"
        rightBTN.size = CGSize(width: 50, height: 50)
        rightBTN.position = CGPoint(x: -self.frame.width/2 + 110, y: -self.frame.height/8)
        rightBTN.zPosition = 6
        
        self.addChild(rightBTN)
        
        portalGun = SKSpriteNode(imageNamed: "portal")
        portalGun.size = CGSize(width: 100, height: 100)
        portalGun.position = CGPoint(x: self.frame.width/2 - 50, y: -self.frame.height/10)
        portalGun.zPosition = 6
        
        self.addChild(portalGun)
        
        pauseBTN = SKSpriteNode(imageNamed: "pause")
        pauseBTN.position = CGPoint(x: self.frame.width/2 - 40, y:  self.frame.height/7 - 10)
        pauseBTN.zPosition = 7
        pauseBTN.size = CGSize(width: 50, height: 45)
        self.addChild(pauseBTN)
        
        scoreLbl.position = CGPoint(x: 0, y: 150)
        scoreLbl.text = "\(score)"
        scoreLbl.fontName = "8-BIT WONDER"
        scoreLbl.zPosition = 5
        scoreLbl.fontSize = 40
        self.addChild(scoreLbl)
    }
    
    func createRick(direction:Bool, point:CGPoint) {
        
        rick = Rick(direction:direction)
        
        rick.position = point
        rick.physicsBody = SKPhysicsBody(circleOfRadius: rick.frame.height/3)
        rick.physicsBody?.categoryBitMask = PhysicsCategory.Rick
        rick.physicsBody?.collisionBitMask = PhysicsCategory.Enemy | PhysicsCategory.Ground
        rick.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.Ground
        rick.physicsBody?.affectedByGravity = true
        rick.physicsBody?.isDynamic = true
        rick.physicsBody?.allowsRotation = false
        rick.zPosition = 4
        self.addChild(rick)
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addEnemy() {
        var direct = true
        var enemy = Enemy(direction: direct)
        
        var start = 300
        if(!randomEnemy()){
            start = -300
            direct = false
            enemy = Enemy(direction: false)
        }
        
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.frame.height/3.3)
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.Rick | PhysicsCategory.Ground
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Rick | PhysicsCategory.Ground
        enemy.physicsBody?.affectedByGravity = true
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.allowsRotation = false
        enemy.size = CGSize(width: 60, height: 100)
        enemy.zPosition = 3
        
        enemy.position = CGPoint(x: start, y:0)
        // Add the monster to the scene
        addChild(enemy)

        enemy.beginAnimation(direction: direct)

        let actionMove = SKAction.moveTo(x: CGFloat(start), duration: 3)
        actionMove.timingMode = .easeIn
        
        let actionMoveTwo = SKAction.moveTo(x: CGFloat(-start), duration: 3)
        actionMoveTwo.timingMode = .easeOut
        enemy.run(SKAction.repeatForever(SKAction.sequence([actionMove,actionMoveTwo])))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let first = contact.bodyA
        let second = contact.bodyB
        
        if first.categoryBitMask == PhysicsCategory.Rick && second.categoryBitMask == PhysicsCategory.Enemy || second.categoryBitMask == PhysicsCategory.Rick && first.categoryBitMask == PhysicsCategory.Enemy{
            
            lives -= 1
            self.removeChildren(in: hearts)
            createHearts()
            let direct = rick.getRickDirection()
            
            if direct {
                rick.physicsBody?.applyImpulse(CGVector(dx: -20, dy: 80))
            } else {
                rick.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 80))
            }
            
            var enemy = SKSpriteNode()
            
            if first.categoryBitMask == PhysicsCategory.Enemy {
                enemy = first.node as! Enemy
            } else {
                enemy = second.node as! Enemy
            }
            
            reverseDirection(node: enemy)
            
            if lives <= 0 {
                died = true
                gameStarted = false
                createRestartButton()
            }
        } else if first.categoryBitMask == PhysicsCategory.Enemy && second.categoryBitMask == PhysicsCategory.Shoot || second.categoryBitMask == PhysicsCategory.Enemy && first.categoryBitMask == PhysicsCategory.Shoot {
            score += 1
            scoreLbl.text = "\(score)"
            
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
         
            if(score % 10 == 0 && spawn > 2){
                spawn -= 1
            }
        }
    }
    
    func reverseDirection(node: SKSpriteNode){
        let enemy = node as! Enemy
        let position = enemy.position
        let duration = ((300 - abs(position.x)) * 0.025)
        let direction = enemy.getDirection()
        enemy.removeAllActions()

        if(direction){
            print("here")
            var action = SKAction()
            if(position.x < 0){
                action = SKAction.moveTo(x: 300, duration: TimeInterval(5 - duration))
            } else {
                action = SKAction.moveTo(x: 300, duration: TimeInterval(2.5 - duration))
            }
            
            let reverse = SKAction.repeatForever(SKAction.sequence([SKAction.moveTo(x: -300, duration: 2.5),SKAction.run {
                enemy.beginAnimation(direction: !direction)
                }, SKAction.moveTo(x: 300, duration: 2.5), SKAction.run {
                    enemy.beginAnimation(direction: direction)
                }]))
            enemy.run(SKAction.sequence([action, reverse]))
        } else {
            print("or here")
            var action = SKAction()
            if(position.x > 0){
                action = SKAction.moveTo(x: -300, duration: TimeInterval(2.5 - duration))
            } else {
                action = SKAction.moveTo(x: -300, duration: TimeInterval(5 - duration))
            }
            let reverse = SKAction.repeatForever(SKAction.sequence([SKAction.moveTo(x: 300, duration: 2.5),SKAction.run {
                enemy.beginAnimation(direction: !direction)
                }, SKAction.moveTo(x: -300, duration: 2.5), SKAction.run {
                    enemy.beginAnimation(direction: direction)
                }]))
            enemy.run(SKAction.sequence([action, reverse]))
        }
        
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
            if pauseBTN.contains(location){
                pauseGame()
            }
            if resumeBTN.contains(location) {
                resume()
            }
            if(gameStarted){
                if(!died){
                    if(spawned){
                        if(!first){
                            let when = DispatchTime.now() + DispatchTimeInterval.seconds(spawn)
                            spawned = false
                            DispatchQueue.main.asyncAfter(deadline: when) {
                                self.addEnemy()
                                self.spawned = true
                            }
                        } else {
                            first = false
                            self.addEnemy()
                        }
                    }
                    if location.x < 0 {
                        if leftBTN.contains(location) {
                            moveRight = false
                            moveLeft = true
                            lastDirect = false
                            let currentPosition = rick.position
                            
                            rick.removeFromParent()
                            createRick(direction: false, point: currentPosition)
                            rick.beginLeftAnimation()
                        }
                        if rightBTN.contains(location){
                            moveRight = true
                            moveLeft = false
                            lastDirect = true
                            let currentPosition = rick.position
                            
                            rick.removeFromParent()
                            createRick(direction: true, point: currentPosition)
                            rick.beginRightAnimation()
                        }
                    } else {
                        if portalGun.contains(location) {
                            attack(direction: lastDirect, point: rick.position)
                        }
                    }
                }
            } else {
                if startBTN.contains(location){
                    startScene()
                    gameStarted = true
                }
                if restartBTN.contains(location){
                    restartGame()
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: self)
            if location.x < 0 {
                moveLeft = false
                moveRight = false
                rick.stopAnimation()
            }
        }
        //Rick.removeAllActions()
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        
        // Calculate time since last update
        // Update entities
        
        if gameStarted {
            if (rick.position.x >= self.frame.maxX - 30){
                moveRight = false
            } else if(rick.position.x  <= -self.frame.maxX + 30){
                moveLeft = false
            }
            if (moveLeft) {
                let direction = -20
                rick.physicsBody?.velocity = CGVector(dx:0,dy:0)
                rick.physicsBody?.applyImpulse(CGVector(dx:direction, dy:0))
            } else if (moveRight) {
                let direction = 20
                rick.physicsBody?.velocity = CGVector(dx:0,dy:0)
                rick.physicsBody?.applyImpulse(CGVector(dx:direction, dy:0))
            }
            if !talked {
                if (morty.position.x == 0){
                    morty.stopAnimation()
                    if(!spaceShipAdded){
                        spaceShipAdded = true
                        space()
                    }
                    if spaceship.position == CGPoint(x:0, y:-10){
                        talked = true
                        talk()
                    }
                }
            }
        }
    }
}
class Rick: SKSpriteNode {
    var direct = Bool()
    
    init(direction:Bool) {
        direct = direction
        var texture : SKTexture
        if(direction){
            texture = SKTexture(imageNamed: "rickRight0")
        } else {
            texture = SKTexture(imageNamed: "rickLeft0")
        }
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    func getRickDirection() -> Bool {
        return direct
    }
    
    func beginRightAnimation() {
        let textureAtlas = SKTextureAtlas(named: "rickRight")
        let frames = ["rickRight0",  "rickRight2", "rickRight1"].map { textureAtlas.textureNamed($0) }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.1)
        let forever = SKAction.repeatForever(animate)
        self.run(forever)
    }
    
    func beginLeftAnimation() {
        let textureAtlas = SKTextureAtlas(named: "rickLeft")
        let frames = ["rickLeft0",  "rickLeft2","rickLeft1"].map { textureAtlas.textureNamed($0) }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.1)
        let forever = SKAction.repeatForever(animate)
        self.run(forever)
    }
    
    func stopAnimation(){
        self.removeAllActions()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Enemy: SKSpriteNode {
    var direct = Bool()
    
    init(direction:Bool) {
        direct = direction
        var texture : SKTexture
        if(!direction){
            texture = SKTexture(imageNamed: "enemyRight0")
        } else {
            texture = SKTexture(imageNamed: "enemyLeft0")
        }
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    func getDirection() -> Bool {
        return direct
    }
    
    func beginAnimation(direction: Bool){
        var textureAtlas = SKTextureAtlas()
        var frames = [SKTexture]()
 
        if (!direction){
            textureAtlas = SKTextureAtlas(named: "enemyRight")
            frames = ["enemyRight0",  "enemyRight1"].map { textureAtlas.textureNamed($0) }
        } else {
            textureAtlas = SKTextureAtlas(named: "enemyLeft")
            frames = ["enemyLeft0",  "enemyLeft1"].map { textureAtlas.textureNamed($0) }
        }
        
        direct = direction
        
        let animate = SKAction.animate(with: frames, timePerFrame: 0.1)
        let forever = SKAction.repeatForever(animate)
        self.run(forever)
    }
    
    func move(){
        var start = 300
        if(self.position.x > 0){
            start = -300
        }
        let action = SKAction.moveTo(x: CGFloat(-start), duration: 2.5)
        let back = SKAction.moveTo(x: CGFloat(start), duration: 2.5)
        
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {self.beginAnimation(direction: !self.direct)},action,SKAction.run {self.beginAnimation(direction: self.direct)},back])))
    }
    
    func stopAnimation(){
        self.removeAllActions()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Shoot: SKSpriteNode {
    var direct : Bool = true
    init(direction:Bool) {
        direct = direction
        let texture = SKTexture(imageNamed: "shoot01")
        
        super.init(texture: texture, color: .clear, size: texture.size())
        self.beginAnimation()
    }
    
    func beginAnimation() {
        let textureAtlas = SKTextureAtlas(named: "shoot")
        let frames = ["shoot01", "shoot02","shoot03","shoot04"].map { textureAtlas.textureNamed($0) }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.1)
        let forever = SKAction.repeatForever(animate)
        self.run(forever)
    }
    
    func stopAnimation(){
        self.removeAllActions()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Morty: SKSpriteNode {
    var direct : Bool = true
    init(direction:Bool) {
        direct = direction
        let texture = SKTexture(imageNamed: "morty01")
        
        super.init(texture: texture, color: .clear, size: texture.size())
        self.beginAnimation()
    }
    
    func beginAnimation() {
        let textureAtlas = SKTextureAtlas(named: "morty")
        let frames = ["morty01", "morty02"].map { textureAtlas.textureNamed($0) }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.1)
        let forever = SKAction.repeatForever(animate)
        self.run(forever)
    }
    
    func stopAnimation(){
        self.removeAllActions()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SpaceShip: SKSpriteNode {
    var direct : Bool = true
    init(direction:Bool) {
        direct = direction
        let texture = SKTexture(imageNamed: "space")
        
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
