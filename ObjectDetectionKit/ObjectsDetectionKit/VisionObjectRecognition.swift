//
//  VisionObjectRecognition.swift
//  ObjectsDetectionKit
//
//  Created by Huynh Lam Phu Si on 4/9/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

struct objectDetection {
    public var name: String
    public var bound: CGRect
    
    public init(name: String, bound: CGRect) {
        self.name = name
        self.bound = bound
    }
}

extension objectDetection: Equatable {
    public static func ==(lhs: objectDetection, rhs: objectDetection) -> Bool {
        return lhs.bound == rhs.bound && lhs.name == rhs.name
    }
}

public enum PlayerMode {
    case onePlayer
    case twoPlayer
}

public class VisionObjectRecognition: UIViewController {
    //MARK: - Public Properties
    public var playMode: PlayerMode? = .onePlayer
    public var delegate: ObjectsRecognitionDelegate?
    
    //MARK: - Private Properties
    private var previousObjects: [UserStep] = []
    var bufferSize: CGSize = .zero
    var rootLayer: CALayer! = nil
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let defaultPosition: AVCaptureDevice.Position = .front
    private let defaultDevice: [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera]
    
    private var requests = [VNRequest]()
    
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    public func setupAVCapture() {
//        setupAVCapture(WithDeviceType: defaultDevice, position: defaultPosition)
    }
    
    public func setupAVCapture(WithDeviceType type:[AVCaptureDevice.DeviceType], position: AVCaptureDevice.Position) {
        var deviceInput: AVCaptureDeviceInput!
        let videoDevices = AVCaptureDevice.DiscoverySession(deviceTypes: type, mediaType: .video, position: position).devices
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevices.first!)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        session.beginConfiguration()
        session.sessionPreset = .hd1280x720
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Can't add video data output to session")
            session.commitConfiguration()
            return
        }
        let captureConnection = videoDataOutput.connection(with: .video)
        captureConnection?.isEnabled = true
        if captureConnection!.isVideoOrientationSupported {
            captureConnection?.videoOrientation = .portrait
        }
        do {
            try videoDevices.first!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevices.first?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevices.first?.unlockForConfiguration()
        } catch let error {
            print(error.localizedDescription)
        }
        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //rootLayer = previewView.layer
        
    }
    
    public func startCaptureSession() {
        session.startRunning()
    }
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
}

//MARK: - AVCamera Capture
extension VisionObjectRecognition: AVCaptureVideoDataOutputSampleBufferDelegate {
    open func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
    }
    
    open func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
}

extension VisionObjectRecognition {
    public func setupVision() throws {
        //let modelURL = BlockRecognition.urlOfModelInThisBundle
        let modelURL = BlockRecognitionTouchRemove.urlOfModelInThisBundle
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: {(request, error) in
                do {
                    try self.visionParseToObject(request: request)
                } catch let error {
                    print(error.localizedDescription)
                }
            })
            self.requests = [objectRecognition]
        } catch let error as NSError{
            throw error
        }
    }
    
    private func visionParseToObject(request: VNRequest) throws {
        guard let results = request.results else {
            return
        }
        var rawResults: [objectDetection] = []
        
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
            let topLabelObservationName = objectObservation.labels.first?.identifier ?? ""
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            let rawObject = objectDetection(name: topLabelObservationName, bound: objectBounds)
            rawResults.append(rawObject)
        }
        if self.playMode == .onePlayer {
            sortObjectOnTopDownOrderWithOnePlayerMode(with: rawResults)
        } else {
            sortObjectOnTopDownOrderWithTwoPlayerMode(with: rawResults)
        }
    }
    
    private func findNearest(position: CGRect, in objects: [objectDetection]) -> objectDetection {
        var min = bufferSize.height
        var suitedObject: objectDetection = objectDetection(name: "", bound: .zero)
        for object in objects {
            let distance = position.origin.y - object.bound.origin.y > 0 ? position.origin.y - object.bound.origin.y : object.bound.origin.y - position.origin.y
            if distance < min {
                min = distance
                suitedObject = object
            }
        }
        return suitedObject
    }
    
    private func isPreviousObjectsSame(currentObjects: [UserStep]) -> Bool {
        guard currentObjects.count == previousObjects.count else {
            return false
        }
        for (index, currentObject) in currentObjects.enumerated() {
            let previousObject = previousObjects[index]
            if currentObject.action == previousObject.action && currentObject.isDanger == previousObject.isDanger && currentObject.number == previousObject.number {
                continue
            } else {
                return false
            }
        }
        return true
    }
    
    private func sortObjectOnTopDownOrderWithOnePlayerMode(with objects:[objectDetection]) {
        var actions: [objectDetection] = []
        var numbers: [objectDetection] = []
        var danger: objectDetection? = nil
        var stars: objectDetection? = nil
        var userGesture: objectDetection? = nil
        for object in objects {
            if object.name == "Walk_Up" || object.name == "Walk_Down" || object.name == "Walk_Left" || object.name == "Walk_Right" || object.name == "Jump_Up" || object.name == "Jump_Down" || object.name == "Jump_Left" || object.name == "Jump_Right" || object.name == "Hand_Up" || object.name == "Hand_Down" || object.name == "Hand_Left" || object.name == "Hand_Right" || object.name == "Repeat" {
                actions.append(object)
                continue
            }
            if object.name == "Number_1" || object.name == "Number_2" || object.name == "Number_3" || object.name == "Number_4" || object.name == "Number_5" {
                numbers.append(object)
                continue
            }
            if object.name == "Danger" {
                danger = object
                continue
            }
            if object.name == "Stars" {
                stars = object
                continue
            } else {
                userGesture = object
            }
        }
        var results: [UserStep] = []
        for number in numbers {
            let suitedAction = findNearest(position: number.bound, in: actions)
            var userStep = UserStep(action: .Walk_Up, position: suitedAction.bound)
            if suitedAction.name == "Walk_Up" {
                userStep.action = .Walk_Up
            } else if suitedAction.name == "Walk_Down" {
                userStep.action = .Walk_Down
            } else if suitedAction.name == "Walk_Left" {
                userStep.action = .Walk_Left
            } else if suitedAction.name == "Walk_Right" {
                userStep.action = .Walk_Right
            } else if suitedAction.name == "Jump_Up" {
                userStep.action = .Jump_Up
            } else if suitedAction.name == "Jump_Down" {
                userStep.action = .Jump_Down
            } else if suitedAction.name == "Jump_Left" {
                userStep.action = .Jump_Left
            } else if suitedAction.name == "Jump_Right" {
                userStep.action = .Jump_Right
            } else if suitedAction.name == "Hand_Up" {
                userStep.action = .Hand_Up
            } else if suitedAction.name == "Hand_Down" {
                userStep.action = .Hand_Down
            } else if suitedAction.name == "Hand_Left" {
                userStep.action = .Hand_Left
            } else if suitedAction.name == "Hand_Right" {
                userStep.action = .Hand_Right
            } else if suitedAction.name == "Repeat" {
                userStep.action = .Repeat
            }
            
            if number.name == "Number_1" {
                userStep.number = .one
            } else if number.name == "Number_2" {
                userStep.number = .two
            } else if number.name == "Number_3" {
                userStep.number = .three
            } else if number.name == "Number_4" {
                userStep.number = .four
            } else if number.name == "Number_5" {
                userStep.number = .five
            }
            results.append(userStep)
            do {
                try actions.removeAll(where: {(removeAction: objectDetection) throws -> Bool in
                    return removeAction == suitedAction
                })
            } catch let error {
                print(error.localizedDescription)
            }
        }
        for action in actions {
            var userStep = UserStep(action: .Walk_Up, position: action.bound)
            if action.name == "Walk_Up" {
                userStep.action = .Walk_Up
            } else if action.name == "Walk_Down" {
                userStep.action = .Walk_Down
            } else if action.name == "Walk_Left" {
                userStep.action = .Walk_Left
            } else if action.name == "Walk_Right" {
                userStep.action = .Walk_Right
            } else if action.name == "Jump_Up" {
                userStep.action = .Jump_Up
            } else if action.name == "Jump_Down" {
                userStep.action = .Jump_Down
            } else if action.name == "Jump_Left" {
                userStep.action = .Jump_Left
            } else if action.name == "Jump_Right" {
                userStep.action = .Jump_Right
            } else if action.name == "Hand_Up" {
                userStep.action = .Hand_Up
            } else if action.name == "Hand_Down" {
                userStep.action = .Hand_Down
            } else if action.name == "Hand_Left" {
                userStep.action = .Hand_Left
            } else if action.name == "Hand_Right" {
                userStep.action = .Hand_Right
            } else if action.name == "Repeat" {
                userStep.action = .Repeat
            }
            results.append(userStep)
        }
        
        if let danger = danger {
            var minRange = bufferSize.height
            var index: Int = 0
            //let dangerResult = UserStep(action: .Hand_Down, position: .zero)
            for result in results {
                let distance = danger.bound.origin.y - result.position.origin.y > 0 ? danger.bound.origin.y - result.position.origin.y : result.position.origin.y - danger.bound.origin.y
                if distance < minRange {
                    minRange = distance
                    guard let resultIndex = try? results.firstIndex(where: {(userStep: UserStep) throws -> Bool in
                        return userStep == result
                    }) else { continue }
                    index = resultIndex
                }
            }
            results[index].isDanger = true
        }
        if let stars = stars {
            let userStep = UserStep(action: .Stars, position: stars.bound)
            results.append(userStep)
        }
        if let userGesture = userGesture {
            let userStep = userGesture.name == "Pressed" ? UserStep(action: .Pressed, position: userGesture.bound) : UserStep(action: .UnPress, position: userGesture.bound)
            results.append(userStep)
        }
        results.sort(by: {(step1: UserStep, step2: UserStep) -> Bool in
            return step1.position.origin.y > step2.position.origin.y
        })
        if !isPreviousObjectsSame(currentObjects: results) {
            previousObjects = results
            self.delegate?.actionSequenceDidChange(actions: results)
        }
    }
    
    private func centerOfRect(_ rect: CGRect) -> CGPoint {
        let midX = rect.origin.x + (rect.width / 2)
        let midY = rect.origin.y + (rect.height / 2)
        return CGPoint(x: midX, y: midY)
    }
    
    private func sortObjectOnTopDownOrderWithTwoPlayerMode(with objects: [objectDetection]) {
        var actions: [objectDetection] = []
        var numbers: [objectDetection] = []
        var danger: objectDetection? = nil
        var stars: objectDetection? = nil
        var userGesture: objectDetection? = nil
        let centerX = self.previewLayer.bounds.width / 2
        for object in objects {
            if object.name == "Walk_Up" || object.name == "Walk_Down" || object.name == "Walk_Left" || object.name == "Walk_Right" || object.name == "Jump_Up" || object.name == "Jump_Down" || object.name == "Jump_Left" || object.name == "Jump_Right" || object.name == "Hand_Up" || object.name == "Hand_Down" || object.name == "Hand_Left" || object.name == "Hand_Right" || object.name == "Repeat" {
                actions.append(object)
                continue
            }
            if object.name == "Number_1" || object.name == "Number_2" || object.name == "Number_3" || object.name == "Number_4" || object.name == "Number_5" {
                numbers.append(object)
                continue
            }
            if object.name == "Stars" {
                stars = object
                continue
            } else {
                userGesture = object
            }
        }

        
        
    }
}
