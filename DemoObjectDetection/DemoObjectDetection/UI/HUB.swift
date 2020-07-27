

import Foundation
import SceneKit
import SpriteKit

protocol InGameDelegate: AnyObject {
    func backToMenu()
    func backToLevel()
}

class HUB: SKScene {
    public weak var inGameDelegate: InGameDelegate?
    private var overlayNode: SKNode
    private var congratulationsGroupNode: SKNode?
    private var collectedKeySprite: SKSpriteNode!
    private var collectedGemsSprites = [SKSpriteNode]()
    private var countItemLabel : SKLabelNode!
//    private var btnEndGame : SKSpriteNode!
    // demo UI
    private var demoMenu: Menu?
    
    public var controlOverlay: ControlOverlay?

// MARK: - Initialization
        init(size: CGSize, controller: GameController) {
        overlayNode = SKNode()
        super.init(size: size)
        
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        
        collectedGemsSprites = []
        
        // Setup the game overlays using SpriteKit.
        scaleMode = .resizeFill
        
        addChild(overlayNode)
        overlayNode.position = CGPoint(x: 0.0, y: h)
    
        countItemLabel = SKLabelNode(fontNamed: "Chalkduster")
        countItemLabel.xScale = 2
        countItemLabel.yScale = 2
        countItemLabel.text = "x0"
        countItemLabel!.position = CGPoint(x:180, y:-70)
        overlayNode.addChild(countItemLabel)

        // The Max icon.
        let characterNode = SKSpriteNode(imageNamed: "MaxIcon.png")
        let menuButton = Button(skNode: characterNode)
        menuButton.position = CGPoint(x: 50, y: -50)
        menuButton.xScale = 0.5
        menuButton.yScale = 0.5
//        overlayNode.addChild(menuButton)
        menuButton.setClickedTarget(self, action: #selector(self.toggleMenu))
        
        // The Gems
        for i in 0..<1 {
            let gemNode = SKSpriteNode(imageNamed: "collectableBIG_empty.png")
            gemNode.position = CGPoint(x: 125 + i * 80, y: -50)
            gemNode.xScale = 0.25
            gemNode.yScale = 0.25
            overlayNode.addChild(gemNode)
            collectedGemsSprites.append(gemNode)
        }
            
            // end game
           
        
        // The key
        collectedKeySprite = SKSpriteNode(imageNamed: "key_empty.png")
        collectedKeySprite.position = CGPoint(x: CGFloat(195), y: CGFloat(-50))
        collectedKeySprite.xScale = 0.4
        collectedKeySprite.yScale = 0.4
//        overlayNode.addChild(collectedKeySprite)
        
        // The virtual D-pad
            controlOverlay = ControlOverlay(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: w, height: h))
            controlOverlay!.leftPad.delegate = controller
            controlOverlay!.rightPad.delegate = controller
            controlOverlay!.buttonA.delegate = controller
            controlOverlay!.buttonB.delegate = controller
            addChild(controlOverlay!)
        
     
        // the demo UI
        demoMenu = Menu(size: size)
        demoMenu?.isMenuHidden
//        demoMenu!.delegate = controller
        demoMenu!.isHidden = true
        overlayNode.addChild(demoMenu!)
        
        // Assign the SpriteKit overlay to the SceneKit view.
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layout2DOverlay() {
        overlayNode.position = CGPoint(x: 0.0, y: size.height)

        guard let congratulationsGroupNode = self.congratulationsGroupNode else { return }
        
        congratulationsGroupNode.position = CGPoint(x: CGFloat(size.width * 0.5), y: CGFloat(size.height * 0.5))
        congratulationsGroupNode.xScale = 1.0
        congratulationsGroupNode.yScale = 1.0
        let currentBbox: CGRect = congratulationsGroupNode.calculateAccumulatedFrame()
        
        let margin: CGFloat = 25.0
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let maximumAllowedBbox: CGRect = bounds.insetBy(dx: margin, dy: margin)
        
        let top: CGFloat = currentBbox.maxY - congratulationsGroupNode.position.y
        let bottom: CGFloat = congratulationsGroupNode.position.y - currentBbox.minY
        let maxTopAllowed: CGFloat = maximumAllowedBbox.maxY - congratulationsGroupNode.position.y
        let maxBottomAllowed: CGFloat = congratulationsGroupNode.position.y - maximumAllowedBbox.minY
        
        let `left`: CGFloat = congratulationsGroupNode.position.x - currentBbox.minX
        let `right`: CGFloat = currentBbox.maxX - congratulationsGroupNode.position.x
        let maxLeftAllowed: CGFloat = congratulationsGroupNode.position.x - maximumAllowedBbox.minX
        let maxRightAllowed: CGFloat = maximumAllowedBbox.maxX - congratulationsGroupNode.position.x
        
        let topScale: CGFloat = top > maxTopAllowed ? maxTopAllowed / top: 1
        let bottomScale: CGFloat = bottom > maxBottomAllowed ? maxBottomAllowed / bottom: 1
        let leftScale: CGFloat = `left` > maxLeftAllowed ? maxLeftAllowed / `left`: 1
        let rightScale: CGFloat = `right` > maxRightAllowed ? maxRightAllowed / `right`: 1
        
        let scale: CGFloat = min(topScale, min(bottomScale, min(leftScale, rightScale)))
        
        congratulationsGroupNode.xScale = scale
        congratulationsGroupNode.yScale = scale
    }
    
    var collectedGemsCount: Int = 0 {
        didSet {
            countItemLabel.text = "x" + String(collectedGemsCount)
            countItemLabel.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                               SKAction.scale(by: 1.5, duration: 0.2),
                               SKAction.scale(by: 1 / 1.5, duration: 0.2)
            ]))
          
        }
    }
    
    func didCollectKey() {
        collectedKeySprite.texture = SKTexture(imageNamed:"key_full.png")
        collectedKeySprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.scale(by: 1.5, duration: 0.2),
            SKAction.scale(by: 1 / 1.5, duration: 0.2)
            ]))
    }
    
    
    func showVirtualPad() {
        controlOverlay!.isHidden = false
    }
    
    func hideVirtualPad() {
        controlOverlay!.isHidden = true
    }
    
    // MARK: Congratulate the player
    
    func showEndScreen(isWin : Bool) {
        
           // Congratulation title
        let notificationNode : SKSpriteNode
            if isWin {
                notificationNode = SKSpriteNode(imageNamed: "congratulations.png")
            } else {
                notificationNode = SKSpriteNode(imageNamed: "congratulations.png")
            }
           
           
           // Max image
           let characterNode = SKSpriteNode(imageNamed: "congratulations_pandaMax.png")
           characterNode.position = CGPoint(x: CGFloat(0.0), y: CGFloat(-220.0))
           characterNode.anchorPoint = CGPoint(x: CGFloat(0.5), y: CGFloat(0.0))
           
           congratulationsGroupNode = SKNode()
           congratulationsGroupNode!.addChild(characterNode)
           congratulationsGroupNode!.addChild(notificationNode)
           addChild(congratulationsGroupNode!)
        
            let btnEndImg = SKSpriteNode(imageNamed: "MaxIcon.png")

                      let btnEnd = Button(skNode: btnEndImg)
                       btnEnd.position = CGPoint(x: 0, y: 0)
                       btnEnd.xScale = 0.5
                             btnEnd.yScale = 0.5
                     //        overlayNode.addChild(menuButton)
                       btnEnd.setClickedTarget(self, action: #selector(self.toggleLevel))
           
            congratulationsGroupNode!.addChild(btnEnd)
           // Layout the overlay
           layout2DOverlay()
           
           // Animate
           notificationNode.alpha = 0.0
           notificationNode.xScale = 0.0
           notificationNode.yScale = 0.0
           notificationNode.run( SKAction.group([SKAction.fadeIn(withDuration: 0.25),
                                    SKAction.sequence([SKAction.scale(to: 1.22, duration: 0.25),
                                   SKAction.scale(to: 1.0, duration: 0.1)])]))
           
           characterNode.alpha = 0.0
           characterNode.xScale = 0.0
           characterNode.yScale = 0.0
           characterNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                            SKAction.group([SKAction.fadeIn(withDuration: 0.5),
                            SKAction.sequence([SKAction.scale(to: 1.22, duration: 0.25),
                           SKAction.scale(to: 1.0, duration: 0.1)])])]))
       }
    
    //TODO: End game, show menu
    @objc
    func toggleMenu(_ sender: Button) {
        self.inGameDelegate?.backToMenu()
    }
    
    @objc
     func toggleLevel(_ sender: Button) {
        self.inGameDelegate?.backToLevel()
     }
    
    
}

