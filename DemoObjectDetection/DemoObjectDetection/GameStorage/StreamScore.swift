//
//  StreamScore.swift
//  AdventureOfBamboo
//
//  Created by thi nguyen on 7/23/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import RxSwift

struct ScoreLevel {
    var level : Int
    var score : Int
}

protocol StreamScoreProtocol {
 var scoreStream: Observable<ScoreLevel> { get }
}
