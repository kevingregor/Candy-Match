//
//  ViewController.swift
//  Candy Match
//
//  Created by Kevin Gregor on 1/7/17.
//  Copyright © 2017 Kevin Gregor. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AudioToolbox

class ViewController: UIViewController, GADBannerViewDelegate {

    // Storyboard Variables
    @IBOutlet weak var topLeftCard: Card!
    @IBOutlet weak var topLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var topMidCard: Card!
    @IBOutlet weak var topMidConstraint: NSLayoutConstraint!
    @IBOutlet weak var topRightCard: Card!
    @IBOutlet weak var topRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var centerLeftCard: Card!
    @IBOutlet weak var centerLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerMidCard: Card!
    @IBOutlet weak var centerMidConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerRightCard: Card!
    @IBOutlet weak var centerRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomLeftCard: Card!
    @IBOutlet weak var bottomLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomMidCard: Card!
    @IBOutlet weak var bottomMidConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomRightCard: Card!
    @IBOutlet weak var bottomRightConstraint: NSLayoutConstraint!
    
    @IBOutlet var bottomViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cardHeight: NSLayoutConstraint!
    @IBOutlet weak var cardWidth: NSLayoutConstraint!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverScoreLabel: UILabel!
    @IBOutlet weak var highscoreLabel: UILabel!
    
    @IBOutlet weak var candyImage: UIImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    
    @IBOutlet weak var tapToPlayView: UIView!
    @IBOutlet weak var tapToPlayLabel: UILabel!
    @IBOutlet weak var backgroundTint: UIView!
    
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var yPositionGameOver: NSLayoutConstraint!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    // tapToPlay Buttons
    @IBOutlet weak var removeAdsConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rateConstraint: NSLayoutConstraint!
    @IBOutlet weak var soundConstraint: NSLayoutConstraint!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!
    
    // Other Variables
    var score = -1
    var candyName: String!
    var candies = ["Chocolate", "Peppermint", "Lollipop", "CandyCane", "HardCandy", "Popsicle", "Cake", "IceCream", "Donut"]
    var cards = [Card]()
    var constraints = [NSLayoutConstraint]()
    var timer = Timer()
    var flippedUp = false
    var timerLength = 2.0
    var highScore = 0
    var atMainMenu = false
    var sound = "SoundOn"
    
    var backgroundColors = [UIColor()]
    var backgroundLoop = 0
    
    let defaults = UserDefaults.standard
    
    let request = GADRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init AdMob banner
        request.testDevices = ["dee3a927f9e1f3dc514bc04e391a4648"]
        bannerView.adUnitID = "ca-app-pub-9248351523483343/1972190911"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        // Load high score
        if let actualHighScore = defaults.value(forKey: "highScore") as? Int {
            self.highScore = actualHighScore
        }
        
        // Load sound status
        if let actualSound = defaults.value(forKey: "sound") as? String {
            self.sound = actualSound
            self.soundButton.setImage(UIImage(named: sound), for: UIControlState.normal)
        }
        
        // Initialize the Game Over Screen
        self.yPositionGameOver.constant = 600
        
        // Set size of cards
        resetCardConstraints()
        self.cardHeight.constant = self.view.frame.height / 5
        self.cardWidth.constant = self.view.frame.width / 4
        view.layoutIfNeeded()
        
        // Set size of image
        self.imageHeight.constant = (self.candyImage.superview?.frame.height)! * 0.4
        self.imageWidth.constant = self.imageHeight.constant
        view.layoutIfNeeded()
        
        // Hide things below cards
        self.candyImage.alpha = 0
        self.scoreLabel.alpha = 0
        
        // Initialize cards
        initCards()
        
        // Initialize Tap To Play View
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(beginGame(gestureRecognizer:)))
        self.tapToPlayView.addGestureRecognizer(recognizer)
        self.tapToPlayLabel.text = "Tap To Start"
        self.middleButton.setImage(UIImage(named: "Rate"), for: UIControlState.normal)
        
        backgroundColors = [UIColor.red, UIColor.blue, UIColor.orange]
        backgroundLoop = 0
        self.animateBackgroundColor()
        self.view.backgroundColor = UIColor.init(patternImage: UIImage(named: "Geometry")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Background color animation from: http://stackoverflow.com/questions/32287237/gradually-change-background-color-in-swift
    func animateBackgroundColor () {
        if backgroundLoop < backgroundColors.count - 1 {
            backgroundLoop += 1
        } else {
            backgroundLoop = 0
        }
        UIView.animate(withDuration: 10, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.backgroundTint.backgroundColor =  self.backgroundColors[self.backgroundLoop];
        }) {(Bool) -> Void in
            self.animateBackgroundColor();
        }
    }
    
    func initCards() {
        // Add all cards to the array
        self.cards.append(topLeftCard)
        self.cards.append(topMidCard)
        self.cards.append(topRightCard)
        self.cards.append(centerLeftCard)
        self.cards.append(centerMidCard)
        self.cards.append(centerRightCard)
        self.cards.append(bottomLeftCard)
        self.cards.append(bottomMidCard)
        self.cards.append(bottomRightCard)
        
        // Add all constraints to the array
        self.constraints.append(bottomLeftConstraint)
        self.constraints.append(bottomMidConstraint)
        self.constraints.append(bottomRightConstraint)
        self.constraints.append(centerLeftConstraint)
        self.constraints.append(centerMidConstraint)
        self.constraints.append(centerRightConstraint)
        self.constraints.append(topLeftConstraint)
        self.constraints.append(topMidConstraint)
        self.constraints.append(topRightConstraint)
        
        // Add tap gesture recognizers to all cards
        for card in self.cards {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(cardTapped(gestureRecognizer:)))
            card.addGestureRecognizer(recognizer)
        }
    }
    
    func selectCandy() {
        // Randomly select a candy
        let index = arc4random_uniform(UInt32(self.candies.count))
        self.candyName = candies[Int(index)]
        self.candyImage.image = UIImage(named: self.candyName + "Square")
    }
    
    func incAndUpdateScore() {
        // Increment score and update label
        self.score += 1
        self.scoreLabel.text = "\(self.score)"
        
        // Decrease the timer length steadily until 0.75 sec, then decrease slower
        self.timerLength = self.timerLength * 0.97 < 0.75 ? self.timerLength * 0.99 : self.timerLength * 0.97
    }
    
    func assignBoard() {
        // Randomly set up board
        var candiesCopy = candies
        var count = 0
        while (candiesCopy.count > 0) {
            let index = arc4random_uniform(UInt32(candiesCopy.count))
            let candy = candiesCopy.remove(at: Int(index))
            cards[count].setCandy(candy: candy)
            count += 1
        }
        selectCandy()
        flipAllUp()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.timerLength), repeats: false, block: { (Timer) in
            self.loseGame()
        })
    }
    
    func flipAllUp() {
        for card in cards {
            card.flipUp()
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.candyImage.alpha = 1
        }, completion: { (Bool) in
            self.flippedUp = true
        })
    }
    
    func flipAllDown() {
        self.flippedUp = false
        for card in cards {
            card.flipDown()
        }
        UIView.animate(withDuration: 0.25) {
            self.candyImage.alpha = 0
        }
    }
    
    func cardTapped(gestureRecognizer:UITapGestureRecognizer) {
        
        // Card is tapped
        let card = gestureRecognizer.view as! Card
        
        // Check if the card is showing
        if flippedUp == true {
            if card.getCandy() == self.candyName {
                // Correct selection
                timer.invalidate()
                incAndUpdateScore()
                flipAllDown()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    // After a 1 second delay, go to the next round
                    self.assignBoard()
                })
            }
            else {
                // Incorrect selection
                timer.invalidate()
                loseGame()
            }
        }
        
    }

    func beginGame(gestureRecognizer:UITapGestureRecognizer) {
        self.tapToPlayView.alpha = 0
        if (self.atMainMenu) {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                self.yPositionGameOver.constant = 600
                self.rateConstraint.constant = -1000
                self.view.layoutIfNeeded()
            }) { (Bool) in
                self.resetCardConstraints()
                self.middleButton.setImage(UIImage(named: "Rate"), for: UIControlState.normal)
                self.tapToPlayView.alpha = 1
                self.tapToPlayLabel.text = "Tap To Start"
                UIView.animate(withDuration: 0.25, animations: {
                    self.removeAdsConstraint.constant = 25
                    self.rateConstraint.constant = 25
                    self.soundConstraint.constant = 25
                    self.view.layoutIfNeeded()
                })
            }
        }
        else {
            incAndUpdateScore()
            self.timerLength = 2
            self.scoreLabel.alpha = 1
            assignBoard()
        }
    }
    
    func loseGame() {
        // Stop all interaction
        self.flippedUp = false
        
        // Set and save high score
        self.highScore =  self.score > self.highScore ? self.score : self.highScore
        self.highscoreLabel.text = "Best: \(self.highScore)"
        defaults.set(self.highScore, forKey: "highScore")
        defaults.synchronize()
        
        self.gameOverScoreLabel.text = self.scoreLabel.text
        self.scoreLabel.alpha = 0
        self.score = -1
        self.candyImage.alpha = 0
        self.bottomViewConstraint.isActive = false
        cardFall(index: 0)
        self.removeAdsConstraint.constant = -100
        self.soundConstraint.constant = -100
    }
    
    func resetCardConstraints() {
        
        self.topLeftConstraint.constant = 60
        self.topMidConstraint.constant = 60
        self.topRightConstraint.constant = 60
        self.centerLeftConstraint.constant = 24
        self.centerMidConstraint.constant = 24
        self.centerRightConstraint.constant = 24
        self.bottomLeftConstraint.constant = 24
        self.bottomMidConstraint.constant = 24
        self.bottomRightConstraint.constant = 24
        self.view.layoutIfNeeded()
        self.bottomViewConstraint.isActive = true

        self.atMainMenu = false
    }
    
    func cardFall(index : Int) {
        let cardConstraint = self.constraints[index]
        UIView.animate(withDuration: 0.1, animations: {
            cardConstraint.constant = 1000
            self.view.layoutIfNeeded()
        }) { (Bool) in
            if (index + 1 < self.constraints.count) {
                self.cardFall(index: index + 1)
            }
            else {
                self.flipAllDown()
                UIView.animate(withDuration: 0.25, animations: {
                    self.yPositionGameOver.constant = 0
                    self.view.layoutIfNeeded()
                }) { (Bool) in
                    self.atMainMenu = true
                    self.middleButton.setImage(UIImage(named: "Share"), for: UIControlState.normal)
                    self.tapToPlayLabel.text = "Tap To Play Again"
                    self.tapToPlayView.alpha = 1
                }
            }
        }
    }

    @IBAction func removeAdsClicked(_ sender: UIButton) {
        // TODO: $0.99 In-App Purchase to Remove Ads
    }
    @IBAction func middleButtonClicked(_ sender: UIButton) {
        if (self.atMainMenu) {
            // TODO: Share score
        }
        else {
            // TODO: Rate app
        }
    }
    
    @IBAction func soundClicked(_ sender: UIButton) {
        // TODO: Toggle Sound
        self.sound = sound == "SoundOn" ? "SoundOff" : "SoundOn"
        self.soundButton.setImage(UIImage(named: sound), for: UIControlState.normal)
        defaults.set(self.sound, forKey: "sound")
        defaults.synchronize()
    }
}

