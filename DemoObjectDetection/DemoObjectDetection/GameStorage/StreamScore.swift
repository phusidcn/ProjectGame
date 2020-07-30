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

struct Volume {
    var valueVolume : Float
    mutating func setVolume(value : Float) {
        self.valueVolume = value
    }
}

protocol VolumeStreamProtocol {
    var volumeObservable : Observable<Volume> { get}
}

protocol MutableVolumeStreamProtocol : VolumeStreamProtocol {
    func updateVolume(value : Float)
}

final class VolumeStreamImpl {
    internal var volume = Volume(valueVolume: 0.7) {
          didSet {
              volumeSubject.onNext(volume)
          }
      }
    var volumeSubject = ReplaySubject<Volume>.create(bufferSize: 1)
}

extension VolumeStreamImpl : MutableVolumeStreamProtocol {
    static let shared = VolumeStreamImpl()

  
    var volumeObservable: Observable<Volume> {
        return volumeSubject.asObserver()
    }
    
    func updateVolume(value : Float) {
        self.volume.setVolume(value: value)
        volumeSubject.onNext(volume)
    }
    
}


protocol StreamScoreProtocol {
 var scoreStream: Observable<ScoreLevel> { get }
}
