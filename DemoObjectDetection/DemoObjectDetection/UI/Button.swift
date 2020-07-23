// Button.swift
//  Created by thi nguyen on 8/4/20.
//  Copyright © 2020 Busline Ticked. All rights reserved.


import SpriteKit

class Button: SKNode {
    var width: CGFloat {
        return size.width
    }

    var label: SKLabelNode?
    var background: SKSpriteNode?
    private(set) var actionClicked: Selector?
    private(set) var targetClicked: Any?
    var size = CGSize.zero

    func setText(_ txt: String) {
        label!.text = txt
    }

    func setBackgroundColor(_ col: SKColor) {
        guard let background = background else { return }
        background.color = col
    }

    func setClickedTarget(_ target: Any, action: Selector) {
        targetClicked = target
        actionClicked = action
    }

    init(text txt: String) {
        super.init()

        // create a label
        let fontName: String = "Optima-ExtraBlack"
        label = SKLabelNode(fontNamed: fontName)
        label!.text = txt
        label!.fontSize = 18
        label!.fontColor = SKColor.white
        label!.position = CGPoint(x: CGFloat(0.0), y: CGFloat(-8.0))

        // create the background
        size = CGSize(width: CGFloat(label!.frame.size.width + 10.0), height: CGFloat(30.0))
        background = SKSpriteNode(color: SKColor(red: CGFloat(0), green: CGFloat(0), blue: CGFloat(0), alpha: CGFloat(0.75)), size: size)

        // add to the root node
        addChild(background!)
        addChild(label!)

        // Track mouse event
        isUserInteractionEnabled = true
    }

    init(skNode node: SKNode) {
        super.init()

        // Track mouse event
        isUserInteractionEnabled = true
        size = node.frame.size
        addChild(node)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func height() -> CGFloat {
        return size.height
    }

#if os( iOS )
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        _ = (targetClicked! as AnyObject).perform(actionClicked, with: self)
    }
#endif
}
