// RootComponent.swift
//  Created by thi nguyen on 5/4/20.
//  Copyright © 2020 Busline Ticked. All rights reserved.


import GameplayKit

class PlayerComponent: RootComponent {
    public var character: Character!

    override func update(deltaTime seconds: TimeInterval) {
        positionAgentFromNode()
        super.update(deltaTime: seconds)
    }
}
