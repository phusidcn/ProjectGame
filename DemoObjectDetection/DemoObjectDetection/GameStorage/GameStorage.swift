//
//  GameStorage.swift
//  DemoObjectDetection
//
//  Created by Huynh Lam Phu Si on 7/22/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import Foundation

public class GameStorage {
    
    public static var sharedInstance: GameStorage {
        return GameStorage(fileName: "SaveGame.aob")
    }
    
    var fileName: String = "SaveGame.aob"
    static var numberOfLevel: Int = 8
    static var currentLevel: Int = 0
    static var points: [Int] = []
    static var starsNumber: [Int] = []
    
    
    init(fileName: String) {
        self.fileName = fileName
        GameStorage.currentLevel = 0
        GameStorage.points = [Int](repeating: 0, count: GameStorage.numberOfLevel)
        GameStorage.starsNumber = [Int](repeating: 0, count: GameStorage.numberOfLevel)
    }
    
    public func loadGame() -> Bool {
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last
        let path = url?.appendingPathComponent(fileName)
        if let path = path {
            if !fileManager.fileExists(atPath: path.absoluteString) {
                return false
            }
        } else {
            return false
        }
        do {
            let fileHandle = try FileHandle(forReadingFrom: path!)
            let savedData = try String(data: fileHandle.readToEnd() ?? Data(), encoding: .utf8)
            let savedContent = savedData?.components(separatedBy: "\n")
            for i in 0 ..< (savedContent?.count ?? 0) {
                let levelInfo = savedContent?[i].components(separatedBy: " ")
                GameStorage.points[i] = Int(levelInfo?[0] ?? "0") ?? 0
                GameStorage.starsNumber[i] = Int(levelInfo?[1] ?? "0") ?? 0
            }
        } catch let error {
            print(error)
            return false
        }
        
        return true
    }
    
    public func saveGame() {
        var currentStateString = ""
        for i in 0 ..< GameStorage.numberOfLevel {
            currentStateString.append("\(GameStorage.points[i]) ")
            currentStateString.append("\(GameStorage.starsNumber[i])\n")
        }
        
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last
        let path = url?.appendingPathComponent(fileName)
        if let path = path?.absoluteString, fileManager.fileExists(atPath: path) == false {
            let result = fileManager.createFile(atPath: path, contents: currentStateString.data(using: .utf8), attributes: nil)
            if result == true {
                print("OK")
            }
        } else {
            guard let path = path else { return }
            do {
                var higherPoints = GameStorage.points
                var higherStars = GameStorage.starsNumber
                let fileHandler = try FileHandle(forUpdating: path)
                let savedData = try String(data: fileHandler.readToEnd() ?? Data(), encoding: .utf8)
                let savedContent = savedData?.components(separatedBy: "\n")
                for i in 0 ..< (savedContent?.count ?? 0) {
                    let levelInfo = savedContent?[i].components(separatedBy: " ")
                    if Int(levelInfo?[0] ?? "0") ?? 0 > higherPoints[i] {
                        higherPoints[i] = Int(levelInfo?[0] ?? "0") ?? 0
                        higherStars[i] = Int(levelInfo?[1] ?? "0") ?? 0
                    }
                }
                
                for i in 0 ..< GameStorage.numberOfLevel {
                    fileHandler.write("\(higherPoints[i]) \(higherStars[i])\n".data(using: .utf8) ?? Data())
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
            
        }
    }
}
