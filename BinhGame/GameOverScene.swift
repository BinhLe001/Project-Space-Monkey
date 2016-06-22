//
//  GameOverScene.swift
//  BinhGame
//
//  Created by Binh Le on 7/15/15.
//
//

import AVFoundation
import Foundation
import SpriteKit

class GameOverScene: SKScene{
    
    var backgroundMusic = AVAudioPlayer()
    
    weak var viewController: GameViewController!
    var currentGame: GameScene!
    
    init(size: CGSize, score: NSInteger) {
        
        super.init(size: size)
        
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
        
        backgroundMusic = self.setupAudioPlayerWithFile("relax", type:"mp3")
        backgroundMusic.numberOfLoops = -1
        self.setUpMusic()

        let defaults = NSUserDefaults.standardUserDefaults()
        let highscore = defaults.integerForKey("highscore")
        if (NSUserDefaults.standardUserDefaults().objectForKey("highscore") == nil){
            defaults.setInteger(score, forKey: "highscore")
        }
        if score > highscore {
            defaults.setInteger(score, forKey: "highscore")
            defaults.synchronize()
        }
        let savedScore: Int = NSUserDefaults.standardUserDefaults().objectForKey("highscore") as! Int
        
        let highScore = SKLabelNode (fontNamed: "Chalkduster")
        let high: NSString = "High Score: " + String(savedScore)
        highScore.text = high as String
        highScore.fontColor = SKColor.whiteColor()
        highScore.position = CGPointMake(size.width/2, size.height * 0.55)
        highScore.name = "High Score:  "
        highScore.setScale(0.7)
        self.addChild(highScore)
        
        let message: NSString = "GAME OVER"
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message as String
        label.fontSize = 40;
        label.fontColor = SKColor.whiteColor()
        label.position = CGPointMake(size.width/2, size.height * 0.8)
        self.addChild(label)
        
        let retrymessage:NSString = "TOUCH FOR START MENU";
        let retryButton = SKLabelNode(fontNamed:"Chalkduster")
        retryButton.text = retrymessage as String
        retryButton.fontColor = SKColor.whiteColor()
        retryButton.position = CGPointMake(size.width/2, size.height/2 - size.height * 0.1)
        retryButton.name = "retry"
        retryButton.setScale(0.65)
        self.addChild(retryButton)

        let playerscoremsg:NSString = "Player Score: " + String(score)
        let playerscore = SKLabelNode(fontNamed: "Chalkduster")
        playerscore.text = playerscoremsg as String;
        playerscore.fontColor = SKColor.whiteColor()
        playerscore.position = CGPointMake(size.width/2, size.height * 0.65);
        playerscore.name = "Player Score"
        playerscore.setScale(0.7)
        self.addChild(playerscore)
        
        let alien : SKSpriteNode = SKSpriteNode (imageNamed: "bigalien")
        alien.position = CGPointMake(self.frame.size.width/2, size.height * 0.2)
        alien.setScale(1.1)
        self.addChild(alien)
    }

    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    //Detects Pressing Of Retry Button
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        super.touchesBegan(touches, withEvent: event!);
        let array = Array(touches)
        let touch = array[0] 
        let location = touch.locationInNode(self)
        let node:SKNode = self.nodeAtPoint(location)
        
        backgroundMusic.stop()
        let reveal = SKTransition.flipHorizontalWithDuration(1.0)
        let scene = GameScene(size: size)
        self.view?.presentScene(scene, transition: reveal)
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
    
    func delay(delay:Double, closure:()->()) {
        
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
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
    
    //Sets Background Music
    func setUpMusic(){
        
        backgroundMusic.volume = 0.4
        backgroundMusic.play()
    }
}