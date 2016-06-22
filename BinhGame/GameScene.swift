//
//  GameScene.swift
//  Project Space Monkey
//
//  Created by Binh Le on 7/10/15.
//  Copyright (c) 2015 Le Developers. All rights reserved.
//

import AVFoundation
import SpriteKit
import GoogleMobileAds
import GameKit

struct PhysicsCategory {
    
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let TempRock  : UInt32 = 0b1       // 1
    static let Rock      : UInt32 = 0b10      // 2
    static let Laser     : UInt32 = 0b11      // 3
    static let Char      : UInt32 = 0b100     // 4
    static let Screen    : UInt32 = 0b101     // 5
}

class GameScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate {
    
    let character = SKSpriteNode(imageNamed: "spacemonkey")
    let bigmonkey : SKSpriteNode = SKSpriteNode (imageNamed: "bigmonkey")
    let left: SKSpriteNode = SKSpriteNode(imageNamed: "left1")
    let right: SKSpriteNode = SKSpriteNode(imageNamed: "right1")
    let fire: SKSpriteNode = SKSpriteNode(imageNamed: "fire")
    let title = SKLabelNode(fontNamed: "Chalkduster")
    let title2 = SKLabelNode(fontNamed: "Chalkduster")
    let startButton = SKLabelNode(fontNamed:"Chalkduster")
    let leaderboard = SKSpriteNode(imageNamed: "leader.png")
    var count: NSInteger = 0
    var start = false
    var dead = false
    var xVelocity: CGFloat = 0
    var shoot = false
    
    weak var viewController: GameViewController!
    
    var buttonBeep = AVAudioPlayer()
    var hitNoise = AVAudioPlayer()
    var moveNoise = AVAudioPlayer()
    var crashNoise = AVAudioPlayer()
    var backgroundMusic = AVAudioPlayer()
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        var error: NSError?
        var audioPlayer:AVAudioPlayer?
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        return audioPlayer!
    }

    override func didMoveToView(view: SKView) {
        
        let background : SKSpriteNode = SKSpriteNode (imageNamed: "stars.png")
        background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        background.size = self.frame.size
        self.addChild(background)
        
        let dust = SKSpriteNode(imageNamed: "spacedust")
        dust.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        dust.size = self.frame.size
        self.addChild(dust)
        
        let dustDestination = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2 - self.frame.size.height)
        let dustAction = SKAction.moveTo(dustDestination, duration: 5.00)
        let dustActionDone = SKAction.removeFromParent()
        dust.runAction(SKAction.sequence([dustAction, dustActionDone]))
        self.initScroll()
        
        let name: NSString = "PROJECT"
        title.text = name as String
        title.fontSize = 40;
        title.fontColor = SKColor.whiteColor()
        title.position = CGPointMake(size.width/2, size.height * 0.8)
        title.setScale(1)
        self.addChild(title)
        
        let name1: NSString = "SPACE MONKEY"
        title2.text = name1 as String
        title2.fontSize = 40;
        title2.fontColor = SKColor.whiteColor()
        title2.position = CGPointMake(size.width/2, size.height * 0.7)
        title2.setScale(0.8)
        self.addChild(title2)
        
        let startmessage:NSString = "TOUCH TO PLAY";
        startButton.text = startmessage as String
        startButton.fontColor = SKColor.whiteColor()
        startButton.position = CGPointMake(size.width/2, size.height * 0.17)
        startButton.name = "start"
        startButton.setScale(0.8)
        self.addChild(startButton)
        
        bigmonkey.position = CGPointMake(self.frame.size.width/2, size.height/2 - size.height * 0.05)
        bigmonkey.setScale(0.95)
        self.addChild(bigmonkey)
        
        leaderboard.position = CGPointMake(self.frame.size.width/2 , size.height * 0.08)
        leaderboard.setScale(0.14)
        self.addChild(leaderboard)
        
        buttonBeep = self.setupAudioPlayerWithFile("gun", type:"mp3")
        hitNoise = self.setupAudioPlayerWithFile("poopsplat", type:"wav")
        moveNoise = self.setupAudioPlayerWithFile("swoosh", type:"wav")
        crashNoise = self.setupAudioPlayerWithFile("bump", type: "wav")
        backgroundMusic = self.setupAudioPlayerWithFile("funky", type:"mp3")
        backgroundMusic.numberOfLoops = -1
        self.setUpMusic()
        
        character.physicsBody = SKPhysicsBody(rectangleOfSize: character.size)
        character.physicsBody!.affectedByGravity = false
        character.physicsBody!.dynamic = true
        character.physicsBody?.categoryBitMask = PhysicsCategory.Char
        character.physicsBody?.contactTestBitMask = PhysicsCategory.TempRock | PhysicsCategory.Rock
        character.physicsBody?.collisionBitMask = PhysicsCategory.Screen
        character.physicsBody!.angularVelocity = 0
        character.physicsBody!.allowsRotation = false
        
        
        let borderBody = SKPhysicsBody(edgeLoopFromRect: frame)
        borderBody.categoryBitMask = PhysicsCategory.Screen
        borderBody.contactTestBitMask  = PhysicsCategory.None
        borderBody.collisionBitMask = PhysicsCategory.Screen
        self.physicsBody = borderBody
        
        character.physicsBody?.usesPreciseCollisionDetection = true
        character.position = CGPoint(x: size.width * 0.5, y: size.height * 0.25)
        
        shoot = false
        start = false
        
        authenticateLocalPlayer()
    }
    
    //Starts Game
    func setUpGame(){
    
        //self.setUpMusic()
        
        left.position = CGPointMake(48, 42)
        left.setScale(0.5)
        left.zPosition = 1
        self.addChild(left)
        
        right.position = CGPointMake(self.frame.size.width - 48, 42)
        right.setScale(0.5)
        right.zPosition = 1
        self.addChild(right)
        
        fire.position = CGPointMake(self.frame.size.width/2, 42)
        fire.setScale(0.17)
        fire.zPosition = 1
        self.addChild(fire)
        
        self.addChild(character)
        if (randRange(1,upper:2) == 1){
            xVelocity = -120
        }
        else{
            xVelocity = 120
        }
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        self.shoot = true
        
        addRocks()
        
        let label = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        label.position = CGPoint(x: CGRectGetMaxX(frame) - 52, y: CGRectGetMaxY(frame) - 45)
        label.text = String(0)
        label.zPosition = 50
        addChild(label)
        
        delay(3.5){
            self.count += 100
            //self.leaderboard(self.count)
            label.removeFromParent()
            self.initHUD()
        }
    }
    
    //Sets Background Music
    func setUpMusic(){
        
        backgroundMusic.volume = 0.5
        backgroundMusic.play()
    }
    
    //Sets Score And Increments
    func initHUD() {
        
        let label_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        label_score.position = CGPoint(x: CGRectGetMaxX(frame) - 52, y: CGRectGetMaxY(frame) - 45)
        label_score.text = String(count)
        label_score.zPosition = 50
        addChild(label_score)
        
        delay(1.5){
            label_score.removeFromParent()
            self.count += 100
            self.initHUD()
        }
    }
    
    //Scrolls Background
    func initScroll(){
        
        let dust = SKSpriteNode(imageNamed: "spacedust")
        dust.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + self.frame.size.height)
        dust.size = self.frame.size
        self.addChild(dust)
        let dustDestination = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2 - self.frame.size.height)
        
        let dustAction = SKAction.moveTo(dustDestination, duration: 10.00)
        let dustActionDone = SKAction.removeFromParent()
        dust.runAction(SKAction.sequence([dustAction, dustActionDone]))
        
        delay(5.00){
            self.initScroll()
        }
    }
    
    //Shoots Laser From Character
    func fireLaser(){
        
        if (self.dead == false && self.shoot == true){
            buttonBeep = self.setupAudioPlayerWithFile("gun", type:"mp3")
            buttonBeep.volume = 0.4
            buttonBeep.play()
            let laser = SKSpriteNode(imageNamed: "banana")
            laser.position = CGPoint(x:character.position.x, y: character.position.y + 55)
            self.addChild(laser)
        
            laser.physicsBody = SKPhysicsBody(circleOfRadius: laser.size.width/2 + 2)
            laser.physicsBody?.dynamic = true
            laser.physicsBody?.categoryBitMask = PhysicsCategory.Laser
            laser.physicsBody?.contactTestBitMask = PhysicsCategory.TempRock | PhysicsCategory.Rock
            laser.physicsBody?.collisionBitMask = PhysicsCategory.None
            laser.physicsBody?.usesPreciseCollisionDetection = true
        
            let laserDestination = CGPoint(x: character.position.x, y: self.size.height)
            let actionMove = SKAction.moveTo(laserDestination, duration: 1.5)
            let actionMoveDone = SKAction.removeFromParent()
            laser.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
    }
    
    //Uses Touches On Button To Move Sprite Left And Right
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        super.touchesBegan(touches, withEvent: event!);
        let array = Array(touches)
        let touch = array[0] 
        let location = touch.locationInNode(self)
        
        if (location.x<95 && location.x>0 && location.y>0 && location.y<90 && shoot == true){
            xVelocity = -210
            moveNoise = self.setupAudioPlayerWithFile("swoosh", type:"wav")
            moveNoise.volume = 0.6
            moveNoise.play()
        }
            
        if (location.x>self.frame.size.width - 95 && location.x<self.frame.size.width && location.y>0 && location.y<90 && shoot == true){
            xVelocity = 210
            moveNoise = self.setupAudioPlayerWithFile("swoosh", type:"wav")
            moveNoise.volume = 0.6
            moveNoise.play()
        }
        
        if(location.x > 95 && location.x < self.frame.size.width - 95 && location.y < 90 && location.y > 0){
            fireLaser()
        }
        
        let node:SKNode = self.nodeAtPoint(location)
        if (start == false && location.y > self.frame.size.height * 0.13) {
            //self.viewController.hidesBanner(self.viewController.bannerView)
            leaderboard.removeFromParent()
            start = true
            bigmonkey.removeFromParent()
            title.removeFromParent()
            title2.removeFromParent()
            startButton.removeFromParent()
            setUpGame()
        }
        else if (start == false && (location.y < self.frame.size.height * 0.13)) {
            
            leaderboard(self.count)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)  {
        
        if (xVelocity>0){
            xVelocity = 130
        }
        else{
            xVelocity = -130
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        let rate: CGFloat = 0.5; //Controls rate of motion. 1.0 instantaneous, 0.0 none.
        
        let relativeVelocity: CGVector = CGVector(dx:xVelocity-character.physicsBody!.velocity.dx, dy:0);
        character.physicsBody!.velocity=CGVector(dx:character.physicsBody!.velocity.dx+relativeVelocity.dx*rate, dy:0);
    }
    
    //Spawns Rocks
    func addRocks(){
        
        let missRock = randRange(3,upper: 8)
        var count: CGFloat = 1.0
        
        while (count <= 11){
            let countInt: Int = Int(count)
            if (missRock == countInt || missRock == countInt-1 || missRock == countInt+1){
                let temp = randRange(1, upper: 3)
                if (temp == 1 && missRock == countInt){
                    tempRock(count)
                }
            }
            else{
                rock(count)
            }
            count += 1
        }
        delay(1.5){
            self.addRocks()
        }
    }
    
    func rock(count: CGFloat){
       
        let rock = SKSpriteNode(imageNamed: "rock")
        rock.position = CGPoint(x: size.width/10 * count - 10, y: size.height+100)
        self.addChild(rock)
        
        rock.physicsBody = SKPhysicsBody(circleOfRadius: rock.size.width/2-10) // 1
        rock.physicsBody?.dynamic = true // 2
        rock.physicsBody?.categoryBitMask = PhysicsCategory.Rock // 3
        rock.physicsBody?.contactTestBitMask = PhysicsCategory.Laser | PhysicsCategory.Char // 4
        rock.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        rock.physicsBody?.usesPreciseCollisionDetection = true
       
        let rockDestination = CGPoint(x: size.width/10 * count - 10, y: -100)
        let rockMove = SKAction.moveTo(rockDestination, duration: 4.5)
        let rockMoveDone = SKAction.removeFromParent()
        rock.runAction(SKAction.sequence([rockMove, rockMoveDone]))
    }
    
    func tempRock(count: CGFloat){
        
        let tRock = SKSpriteNode(imageNamed: "alien")
        tRock.position = CGPoint(x: size.width/10 * count - 10, y: size.height+100)
        self.addChild(tRock)
        
        tRock.physicsBody = SKPhysicsBody(circleOfRadius: tRock.size.width/2 - 15) // 1
        tRock.physicsBody?.dynamic = true // 2
        tRock.physicsBody?.categoryBitMask = PhysicsCategory.TempRock // 3
        tRock.physicsBody?.contactTestBitMask = PhysicsCategory.Laser | PhysicsCategory.Char // 4
        tRock.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        tRock.physicsBody?.usesPreciseCollisionDetection = true
        
        let rockDestination = CGPoint(x: size.width/10 * count - 10, y: -100)
        let rockMove = SKAction.moveTo(rockDestination, duration: 4.5)
        let rockMoveDone = SKAction.removeFromParent()
        tRock.runAction(SKAction.sequence([rockMove, rockMoveDone]))
    }
    
    func randRange (lower: Int , upper: Int) -> Int {
        
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    func delay(delay:Double, closure:()->()) {
        
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    //Deals With Collisions
    func charDidCollideWithRock(){
       
        crashNoise = self.setupAudioPlayerWithFile("bump", type: "wav")
        crashNoise.play()
        let deadMonkey = SKSpriteNode(imageNamed: "monkeyDead")
        deadMonkey.position = character.position
        
        character.removeFromParent()
        self.dead = true
        self.addChild(deadMonkey)
        
        //End Game
        saveHighscore(self.count)
        backgroundMusic.stop()
        let reveal = SKTransition.flipHorizontalWithDuration(1)
        let gameOverScene = GameOverScene(size: self.size, score: self.count)
        self.view?.presentScene(gameOverScene, transition: reveal)
        //self.viewController.showsBanner(self.viewController.bannerView)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        firstBody = contact.bodyA
        secondBody = contact.bodyB

        //Laser Hits TempRock
        if (firstBody.categoryBitMask == 0b11 && secondBody.categoryBitMask == 0b1
        || firstBody.categoryBitMask == 0b1 && secondBody.categoryBitMask == 0b11){
            
            if (firstBody.categoryBitMask > secondBody.categoryBitMask){
                firstBody.node?.removeFromParent()
                secondBody.node?.removeFromParent()
                hitNoise = self.setupAudioPlayerWithFile("poopsplat", type:"wav")
                hitNoise.play()
            }
            else{
                firstBody.node?.removeFromParent()
                secondBody.node?.removeFromParent()
                hitNoise = self.setupAudioPlayerWithFile("poopsplat", type:"wav")
                hitNoise.play()
            }
        }
        
        //Laser Hits Rock
        if (firstBody.categoryBitMask == 0b11 && secondBody.categoryBitMask == 0b10
            || firstBody.categoryBitMask == 0b10 && secondBody.categoryBitMask == 0b11){
                
            if (firstBody.categoryBitMask > secondBody.categoryBitMask){
                firstBody.node?.removeFromParent()
                hitNoise = self.setupAudioPlayerWithFile("poopsplat", type:"wav")
                hitNoise.play()
            }
            else{
                secondBody.node?.removeFromParent()
                hitNoise = self.setupAudioPlayerWithFile("poopsplat", type:"wav")
                hitNoise.play()
            }
        }
        
        //Char Hits TempRock
        if (firstBody.categoryBitMask == 0b100 && secondBody.categoryBitMask == 0b1
            || firstBody.categoryBitMask == 0b1 && secondBody.categoryBitMask == 0b100){
                
            if (firstBody.categoryBitMask > secondBody.categoryBitMask){
                charDidCollideWithRock()
            }
            else{
                charDidCollideWithRock()
            }
        }
        
        //Char Hits Rock
        if (firstBody.categoryBitMask == 0b100 && secondBody.categoryBitMask == 0b10
            || firstBody.categoryBitMask == 0b10 && secondBody.categoryBitMask == 0b100){
            
            if (firstBody.categoryBitMask > secondBody.categoryBitMask){
                charDidCollideWithRock()
            }
            else{
                charDidCollideWithRock()
            }
        }
    }
    
    func leaderboard(score: Int) {
        
        saveHighscore(self.count)
        showLeader()
    }
    
    //send high score to leaderboard
    func saveHighscore(count: Int) {
        
        //check if user is signed in
        if GKLocalPlayer.localPlayer().authenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "High_Scores") //leaderboard id here
            
            scoreReporter.value = Int64(count) //score variable here (same as above)
            
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.reportScores(scoreArray, withCompletionHandler: {(error : NSError?) -> Void in
                if error != nil {
                    print("error")
                }
            })
            
        }
        
    }
    
    //shows leaderboard screen
    func showLeader() {
        let vc = self.view?.window?.rootViewController
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc?.presentViewController(gc, animated: true, completion: nil)
    }
    
    //hides leaderboard screen
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController)
    {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //initiate gamecenter
    func authenticateLocalPlayer(){
        
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                self.viewController.presentViewController(viewController!, animated: true, completion: nil)
            }
                
            else {
                print((GKLocalPlayer.localPlayer().authenticated))
            }
        }
        
    }
    
}
    