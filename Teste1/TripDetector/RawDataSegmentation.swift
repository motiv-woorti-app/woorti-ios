// (C) 2017-2020 - The Woorti app is a research (non-commercial) application that was
// developed in the context of the European research project MoTiV (motivproject.eu). The
// code was developed by partner INESC-ID with contributions in graphics design by partner
// TIS. The Woorti app development was one of the outcomes of a Work Package of the MoTiV
// project.
 
// The Woorti app was originally intended as a tool to support data collection regarding
// mobility patterns from city and country-wide campaigns and provide the data and user
// management to campaign managers.
 
// The Woorti app development followed an agile approach taking into account ongoing
// feedback of partners and testing users while continuing under development. This has
// been carried out as an iterative process deploying new app versions. Along the 
// timeline, various previously unforeseen requirements were identified, some requirements
// Were revised, there were requests for modifications, extensions, or new aspects in
// functionality or interaction as found useful or interesting to campaign managers and
// other project partners. Most stemmed naturally from the very usage and ongoing testing
// of the Woorti app. Hence, code and data structures were successively revised in a
// way not only to accommodate this but, also importantly, to maintain compatibility with
// the functionality, data and data structures of previous versions of the app, as new
// version roll-out was never done from scratch.

// The code developed for the Woorti app is made available as open source, namely to
// contribute to further research in the area of the MoTiV project, and the app also makes
// use of open source components as detailed in the Woorti app license. 
 
// This project has received funding from the European Union’s Horizon 2020 research and
// innovation programme under grant agreement No. 770145.
 
// This file is part of the Woorti app referred to as SOFTWARE.

import Foundation
import CoreLocation
import CoreData
import Crashlytics


/// Create segments of data with 90 (default) seconds per segment
/// Store temportary accelerations and locations
/// Overlap segments
class RawDataSegmentation {
    

    var managedObjectContext: NSManagedObjectContext?
    let managedObjectContextSemaphore = DispatchSemaphore(value: 1)
    let maxProducedValuesCount = DispatchSemaphore(value: 10) //the size limit of produced values before consuming

    static private var instance: RawDataSegmentation?
    
    public let TimeWindow = Double(90)                                 //prev 120
    public let Overlap = Double(45)                                     //prev 40
    private let TimeBeforeOverlap: Double
    
    private let accelStillFilter = Double(0.3)
    
    private let ProcessLock = NSLock()
    private let sincSem = DispatchSemaphore(value: 0)
    let testSincSem = DispatchSemaphore(value: 0)
    
    private let valueReadSincronizationSemaphore = DispatchSemaphore(value: 1)
    
    var inputs = [MLInputMetadata]()
    
    var tempAccelerations = [UserAcceleration]()
    var tempLocations = [UserLocation]()
    
    var accelerations = [UserAcceleration]()
    var locations = [UserLocation]()
    
    var lastPrevPoint: UserLocation?
    
    var startSegmentDate: Date?
    var segmNextIdxLoc: Int?
    var segmNextIdxAcel: Int?
    
    var prevSpeedZero = false
    var ignoreNextZeros = false
    var hasSpeedsOnBegin = false
    var lastSegmPoints = [UserLocation]()
    var pendingInputs = [MLInputMetadata]()
    
    init() {
        TimeBeforeOverlap = TimeWindow - Overlap
        startProcessingValues()
    }
    
    
    /// get instance of singleton RawDataSegmentation
    static func getInstance() -> RawDataSegmentation {
        if instance == nil {
            instance = RawDataSegmentation()
        }
        return self.instance!
    }
    
    /// insert new location in tempLocations.
    /// - Parameter ua: user location
    func newLocation(ua: UserLocation) {
        if DetectLocationModule.processLocationData.isStopped() {
            return
        }
        maxProducedValuesCount.wait()
        ProcessLock.lock()
        if self.tempLocations.count == 0 {
            self.tempLocations.append(ua)
        } else {
            for index in stride(from: self.tempLocations.count - 1, to: -1, by: -1) {
                if (ua.location?.timestamp)! > (self.tempLocations[index].location?.timestamp)! {
                    self.tempLocations.insert(ua, at: index + 1)
                    break;
                } else if index == 0 {
                    self.tempLocations.insert(ua, at: index)
                }
            }
        }
        sincSem.signal()
        ProcessLock.unlock()
        self.LauchThreadToProcessNextValue()
    }
    
    
    
    /// insert new acceleration in tempAccelerations
    /// - Parameter ua: user acceleration
    func newAcceleration(ua: UserAcceleration) {
        if DetectLocationModule.processLocationData.isStopped() {
            return
        }
        maxProducedValuesCount.wait()
        ProcessLock.lock()
        if self.tempAccelerations.count == 0 {
            self.tempAccelerations.append(ua)
        } else {
            for index in stride(from: self.tempAccelerations.count - 1, to: -1, by: -1) {
                if ua.timestamp > self.tempAccelerations[index].timestamp {
                    self.tempAccelerations.insert(ua, at: index + 1)
                    break;
                } else if index == 0 {
                    self.tempAccelerations.insert(ua, at: index)
                }
            }
        }
        sincSem.signal()
        ProcessLock.unlock()
        self.LauchThreadToProcessNextValue()
    }
    
    func startProcessingValues() {
        
        self.managedObjectContext = {
            let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            managedObjectContext.parent = UserInfo.parentContext!
            managedObjectContext.automaticallyMergesChangesFromParent = true
            managedObjectContext.shouldDeleteInaccessibleFaults = true
            managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return managedObjectContext
        }()
        
        let MLInputsMetadataRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MLInputMetadata.entityName)
        MLInputsMetadataRequest.returnsObjectsAsFaults = false
        UserInfo.ContextSemaphore.wait()
        UserInfo.context?.performAndWait {
            do {
                let inputsTmp = try (UserInfo.context?.fetch(MLInputsMetadataRequest) as! [MLInputMetadata]).sorted(by: { (ml1, ml2) -> Bool in
                    ml1.startDate.timeIntervalSince1970 < ml2.startDate.timeIntervalSince1970
                })
                
                self.inputs.append(contentsOf: inputsTmp)
            } catch {
                Crashlytics.sharedInstance().recordError(error)
            }
        }
        UserInfo.ContextSemaphore.signal()
    }
    
    ///Create new thread and execute processNextValue()
    func LauchThreadToProcessNextValue(){
        DispatchQueue.global(qos: .background).async {
            while (self.tempLocations.count + self.tempAccelerations.count > 0) {
                self.sincSem.wait()
                self.valueReadSincronizationSemaphore.wait()
                let bg = FiniteBackgroundTask()
                bg.registerBackgroundTask(withName: "ProcessNextMLValue")
                self.processNextValue()
                bg.endBackgroundTask()
                self.maxProducedValuesCount.signal()
                //for testing
                print("size: \(self.tempLocations.count + self.tempAccelerations.count)")
                NotificationEngine.getInstance().debugNotification(title: "ML size to process: ", body: "size: \(self.tempLocations.count + self.tempAccelerations.count)", notify: false)
                if self.tempLocations.count == 0 && self.tempAccelerations.count == 0 {
                    self.testSincSem.signal()
                }
                self.valueReadSincronizationSemaphore.signal()
            }
        }
    }
    
    
    func processNextValue() {
        ProcessLock.lock()
        var accDate = Date()
        var locDate = Date()
        if let acc = self.tempAccelerations.first {
            accDate = acc.timestamp
        }
        if let loc = self.tempLocations.first {
            locDate = loc.location?.timestamp ?? Date()
        }
        
        if locDate < accDate {
            let loc = self.tempLocations.removeFirst()
            ProcessLock.unlock()
            self.newTestLocation(ua: loc)
        } else {
            let acc =  self.tempAccelerations.removeFirst()
            ProcessLock.unlock()
            self.newTestAcceleration(ua: acc)
        }
    }
    
    /// update segment with new location. Process if duration exceeds TimeWindow
    /// - Parameter ua: user location
    func newTestLocation(ua: UserLocation) {
        if startSegmentDate == nil {
            startSegmentDate = ua.location!.timestamp
        }
        
        var curSegmDuration = ua.location!.timestamp.timeIntervalSince1970 - startSegmentDate!.timeIntervalSince1970
        
        if self.segmNextIdxLoc == nil && curSegmDuration > TimeBeforeOverlap {
            segmNextIdxLoc = self.locations.count
            segmNextIdxAcel = self.accelerations.count
        }
        
        if curSegmDuration > TimeWindow {
            processSegment()
            let newStartDate = self.getMinTimestamp()
            if let newStartDate = newStartDate {
                startSegmentDate = newStartDate
                curSegmDuration = ua.location!.timestamp.timeIntervalSince1970 - startSegmentDate!.timeIntervalSince1970
                
                if self.segmNextIdxLoc == nil && curSegmDuration > TimeBeforeOverlap {
                    segmNextIdxLoc = self.locations.count
                    segmNextIdxAcel = self.accelerations.count
                }
                
                if curSegmDuration > TimeWindow {
                    processSegment()
                    startSegmentDate = ua.location!.timestamp
                }
                
            } else {
                startSegmentDate = ua.location!.timestamp
            }
        }
        
        self.locations.append(ua)

        
    }
    
    /// update segment with new acceleration. Process if duration exceeds TimeWindow
    /// - Parameter ua: user acceleration
    func newTestAcceleration(ua: UserAcceleration) {
        if startSegmentDate == nil {
            startSegmentDate = ua.timestamp
        }
        
        var curSegmDuration = ua.timestamp.timeIntervalSince1970 - startSegmentDate!.timeIntervalSince1970
        
        if self.segmNextIdxAcel == nil && curSegmDuration > TimeBeforeOverlap {
            segmNextIdxLoc = self.locations.count
            segmNextIdxAcel = self.accelerations.count
        }
        
        if curSegmDuration > TimeWindow {
            processSegment()
            let newStartDate = self.getMinTimestamp()
            if let newStartDate = newStartDate {
                startSegmentDate = newStartDate
                curSegmDuration = ua.timestamp.timeIntervalSince1970 - startSegmentDate!.timeIntervalSince1970
                
                if self.segmNextIdxLoc == nil && curSegmDuration > TimeBeforeOverlap {
                    segmNextIdxLoc = self.locations.count
                    segmNextIdxAcel = self.accelerations.count
                }
                
                if curSegmDuration > TimeWindow {
                    processSegment()
                    startSegmentDate = ua.timestamp
                }
                
            } else {
                startSegmentDate = ua.timestamp
            }
        }
        
        self.accelerations.append(ua)
    }

    ///Process last segment
    private func processSegment() {
        let input = calcNewEntry()
        let inputMetadata = MLInputMetadata.getMLInputMetadata(input: input, startDate: startSegmentDate!)!
        
        if inputMetadata.input?.avgSpeed == 0 {
            if !self.ignoreNextZeros && self.hasSpeedsOnBegin {
                self.pendingInputs.append(inputMetadata)
                
                if self.prevSpeedZero && self.pendingInputs.count > RawDataDetection.timeInsegmentsNumber(seconds: 30 * 60) { // 30 minutes max time to wait for locations
                    self.ignoreNextZeros = true
                    self.ClassifyInputs(inputMetadatas: self.pendingInputs)
                }
                prevSpeedZero = true
            } else {
                self.ClassifyOneInput(inputMetadata: inputMetadata)
            }
        } else {
            self.hasSpeedsOnBegin = true
            if self.prevSpeedZero {
                let estimatedAvgSpeed = estimateAvgSpeed()
                if let es = estimatedAvgSpeed {
                    for pendingInput in pendingInputs {
                        pendingInput.input?.avgSpeed = es
                        pendingInput.input?.maxSpeed = es
                        pendingInput.input?.minSpeed = es
                        pendingInput.input?.estimatedSpeed = 1
                    }
                    self.ClassifyInputs(inputMetadatas: self.pendingInputs)
                }
            }
            
            self.ClassifyOneInput(inputMetadata: inputMetadata)
            
            self.lastSegmPoints = self.locations
            self.prevSpeedZero = false
            self.ignoreNextZeros = false
        }
        
        self.accelerations.removeSubrange(0..<self.segmNextIdxAcel!)
        self.locations.removeSubrange(0..<self.segmNextIdxLoc!)
        
        self.segmNextIdxAcel = nil
        self.segmNextIdxLoc = nil
    }
    
    ///Get minimum timestamp found in accelerations or locations
    func getMinTimestamp() -> Date? {
        let locationSize = self.locations.count
        let accSize = self.accelerations.count
        if locationSize == 0 && accSize == 0 {
            return nil
        }
        if locationSize == 0 && accSize > 0 {
            return self.accelerations.first!.timestamp
        }
        if locationSize > 0 && accSize == 0 {
            return self.locations.first!.location!.timestamp
        }
        
        let firstAccelTs = self.accelerations.first!.timestamp
        let firstLocationTs = self.locations.first!.location!.timestamp
        
        if firstAccelTs > firstLocationTs {
            return firstLocationTs
        } else {
            return firstAccelTs
        }
    }
    
    ///Deprecated
    private func newValue(date: Date, idx: inout Int?, collectionSize: Int) -> Bool{
//        if startSegmentDate == nil {
//            startSegmentDate = date
//        }
//        if idx == nil && self.hasPassedTime(startDate: startSegmentDate!, endDate: date, time: self.TimeBeforeOverlap) {
//            idx = collectionSize + 1
//            print("index: \(idx ?? 0)")
//        }
//        if hasPassedTime(startDate: startSegmentDate!, endDate: date, time: TimeWindow) {
//            let (input, lastLocation) = calcNewEntry()
//            lastPrevPoint = lastLocation
//            let inputMetadata = MLInputMetadata(input: input, startDate: startSegmentDate!)
//
//            if inputMetadata.input.avgSpeed == 0 {
//                if !self.ignoreNextZeros && self.hasSpeedsOnBegin {
//                    if !self.prevSpeedZero {
//                        self.pendingInputs.append(inputMetadata)
//                    } else {
//                        if self.pendingInputs.count <= RawDataDetection.timeInsegmentsNumber(seconds: 30 * 60) { // 30 minutes max time to wait for locations
//                            self.pendingInputs.append(inputMetadata)
//                        } else {
//                            self.ignoreNextZeros = true
//                            self.ClassifyInputs(inputMetadatas: self.pendingInputs)
//                        }
//                    }
//                }
//            } else {
//                self.hasSpeedsOnBegin = true
//                if self.prevSpeedZero {
//                    var estimatedAvgSpeed = estimateAvgSpeed()
//                    if let es = estimatedAvgSpeed {
//                        for pendingInput in pendingInputs {
//                            pendingInput.input.avgSpeed = es
//                            pendingInput.input.maxAccel = es
//                            pendingInput.input.minSpeed = es
//                            pendingInput.input.estimatedSpeed = 1
//                        }
//                        self.ClassifyInputs(inputMetadatas: self.pendingInputs)
//                    }
//                } else {
//                    self.ClassifyOneInput(inputMetadata: inputMetadata)
//                }
//                self.lastSegmPoints = self.locations
//                self.prevSpeedZero = false
//                self.self.ignoreNextZeros = false
//            }
//
//            // classify inputs
//            print("classifyed: \(self.inputs.count)")
//            return true
//        }
        return false
    }
    
    /// Order locations by their accuracy
    /// - Parameters:
    ///   - SegmPoints: locations to order
    ///   - isLastSegm: boolean that indicates if this is the last segment
    func orderPointsByAccuracy(SegmPoints: [UserLocation], isLastSegm: Bool) -> [UserLocation] {
        var indexesPerAcc = [Double:[Int]]()
        if isLastSegm {
            for i in stride(from: SegmPoints.count - 1, to: -1, by: -1) {
                let accKey = SegmPoints[i].location!.horizontalAccuracy
                if indexesPerAcc.keys.contains(accKey) {
                    indexesPerAcc[accKey]?.append(i)
                } else {
                    indexesPerAcc[accKey] = [i]
                }
            }
        } else {
            for i in 0..<SegmPoints.count {
                let accKey = SegmPoints[i].location!.horizontalAccuracy
                if indexesPerAcc.keys.contains(accKey) {
                    indexesPerAcc[accKey]?.append(i)
                } else {
                    indexesPerAcc[accKey] = [i]
                }
            }
        }
        
        let orderedKeys = indexesPerAcc.keys.sorted { (k1, k2) -> Bool in
            return k1 < k2
        }
        
        var orderedPoints = [UserLocation]()
        for key in orderedKeys {
            for idx in indexesPerAcc[key]! {
                orderedPoints.append(SegmPoints[idx])
            }
        }
        
        return orderedPoints
    }
    
    
    func estimateAvgSpeed() -> Double? {
        
        let orderedLastSegm = orderPointsByAccuracy(SegmPoints: lastSegmPoints, isLastSegm: true)
        let orderedNextSegm = orderPointsByAccuracy(SegmPoints: locations, isLastSegm: false)

        if orderedLastSegm.count > 0 && orderedNextSegm.count > 0 {
            var lastSegmIdx: Int? = nil
            var nextSegmIdx: Int? = nil
            
            if orderedLastSegm.first!.location!.timestamp != orderedNextSegm.first!.location!.timestamp {
                lastSegmIdx = 0
                nextSegmIdx = 0
            } else {
                if orderedLastSegm.count == 1 && orderedNextSegm.count == 1 {
                    return nil
                }
                if orderedLastSegm.count > 1 && orderedNextSegm.count == 1 {
                    lastSegmIdx = 1
                    nextSegmIdx = 0
                }
                if orderedLastSegm.count == 1 && orderedNextSegm.count > 1 {
                    lastSegmIdx = 0
                    nextSegmIdx = 1
                }
                if orderedLastSegm.count > 1 && orderedNextSegm.count > 1 {
                    if orderedLastSegm[1].location!.horizontalAccuracy < orderedNextSegm[1].location!.horizontalAccuracy {
                        lastSegmIdx = 1
                        nextSegmIdx = 0
                    } else {
                        lastSegmIdx = 0
                        nextSegmIdx = 1
                    }
                }
            }
            
            let left = orderedLastSegm[lastSegmIdx!]
            let right = orderedNextSegm[nextSegmIdx!]
            let timeDiff = abs(right.location!.timestamp.timeIntervalSince1970 - left.location!.timestamp.timeIntervalSince1970)/( 60 * 60 ) // in seconds
            
            let distSimple = simpleDistance(lat1: left.location!.coordinate.latitude, lon1: left.location!.coordinate.longitude, lat2: right.location!.coordinate.latitude, lon2: right.location!.coordinate.longitude)
            
            let estimatedSpeed = distSimple / timeDiff
            return estimatedSpeed

        } else {
            return nil
        }
    }
    

    func ClassifyOneInput(inputMetadata: MLInputMetadata) {
        ModelProcess().classifyData(inputMetadata: inputMetadata)
        self.inputs.append(inputMetadata)
    }
    
    func ClassifyInputs(inputMetadatas: [MLInputMetadata]) {
        for input in inputMetadatas {
            ClassifyOneInput(inputMetadata: input)
        }
        self.pendingInputs.removeAll()
    }
    
    func removeInputsFromDates(startDate: Date, endDate: Date) {
        let inputs = self.inputsBelongingToLeg(legStartDate: startDate, legEndDate: endDate)
        if inputs.count > 0 {
            self.removeUntilInput(input: inputs.last!)
        }
    }
    
    /// calculate new input with trip features to be classified by the classifier.
    private func calcNewEntry() -> MLAlgorithmInput {
        var locationsToEvaluate = self.locations
        var firstPointIsLastBeforeOverlap = false
        
        if lastPrevPoint != nil {
            let newDAte = startSegmentDate!.timeIntervalSince1970 - (lastPrevPoint!.location!.timestamp.timeIntervalSince1970)
            if newDAte < TimeWindow {
                locationsToEvaluate.insert(lastPrevPoint!, at: 0)
                firstPointIsLastBeforeOverlap = true
            }
        }
        
        var accels = [Double]()
        var sumAccels = Double(0)
        var numAccelsBelowFilter = 0
        var sumFilteredAccels = Double(0)
        
        for acc in accelerations {
            let magnitude = acc.accelerationVector()
            accels.append(magnitude)
            sumAccels.add(magnitude)
            if magnitude < accelStillFilter {
                numAccelsBelowFilter += 1
            } else {
                sumFilteredAccels += magnitude
            }
        }
        
        let (avgAccel,maxAccel,minAccel,stdDevAccel,between_03_06,between_06_1,between_1_3,between_3_6,above_6) = ProcessAccelerations(accels: accels, sumAccels: sumAccels)
        
        var accelsBelowFilter = Double(0)
        var avgFilteredAccels = Double(0)
        if accels.count > 0 {
            avgFilteredAccels = sumFilteredAccels / Double(accels.count)
            if numAccelsBelowFilter > 0 {
                accelsBelowFilter = Double(numAccelsBelowFilter) / Double(accels.count)
            }
        }
        
        let overlapLimit = (self.startSegmentDate?.timeIntervalSince1970)! + self.TimeBeforeOverlap
        let pocessedPoint = processPoints(points: locationsToEvaluate, overlapLimit: overlapLimit, firstPointIsLastBeforeOverlap: firstPointIsLastBeforeOverlap)
        
        //Cria entrada para classificador e retorna last point
        let input = MLAlgorithmInput.getMLInputMetadata(avgSpeed: pocessedPoint.avgSpeed, maxSpeed: pocessedPoint.maxSpeed, minSpeed: pocessedPoint.minSpeed, stdDevSpeed: pocessedPoint.stdDevSpeed, avgAcc: pocessedPoint.avgAcc, maxAcc: pocessedPoint.maxAcc, minAcc: pocessedPoint.minAcc, stdDevAcc: pocessedPoint.stdDevAcc, gpsTimeMean: pocessedPoint.gpsTimeMean, distance: pocessedPoint.distance, avgAccel: avgAccel, maxAccel: maxAccel, minAccel: minAccel, stdDevAccel: stdDevAccel, accelsBelowFilter: accelsBelowFilter, avgFilteredAccels: avgFilteredAccels,between_03_06:between_03_06,between_06_1:between_06_1,between_1_3:between_1_3,between_3_6:between_3_6,above_6:above_6)!
        return input
    }
    
    /// Extract features from acceleration values.
    /// - Features: (avgAccel,maxAccel,minAccel,stdDevAccel,between_03_06, between_06_1, between_1_3, between_3_6, above_6)
    /// - Parameters:
    ///   - accels: acceleration array
    ///   - sumAccels: sum of all acceleration values
    func ProcessAccelerations(accels: [Double], sumAccels: Double) -> (Double,Double,Double,Double,Double,Double,Double,Double,Double) {
        var avgAccel = Double(0)
        var maxAccel = Double(0)
        var minAccel = Double(0)
        var stdDevAccel = Double(0)
        
        var between_03_06 = Double(0)
        var between_06_1 = Double(0)
        var between_1_3 = Double(0)
        var between_3_6 = Double(0)
        var above_6 = Double(0)
        
        if accels.count != 0 {
            var between_03_06_num = 0
            var between_06_1_num = 0
            var between_1_3_num = 0
            var between_3_6_num = 0
            var above_6_num = 0
            
            avgAccel = sumAccels.divided(by: Double(accels.count))
            var sumDevAccels = Double(0)
            minAccel = Double(10000)
            for accMagnitude in accels {
                if accMagnitude > maxAccel {
                    maxAccel = accMagnitude
                }
                if accMagnitude < minAccel {
                    minAccel = accMagnitude
                }
                
                if accMagnitude >= 0.3 && accMagnitude < 0.6 {
                    between_03_06_num += 1
                } else if accMagnitude >= 0.6 && accMagnitude < 1 {
                    between_06_1_num += 1
                } else if accMagnitude >= 1 && accMagnitude < 3 {
                    between_1_3_num += 1
                } else if accMagnitude >= 3 && accMagnitude < 6 {
                    between_3_6_num += 1
                } else if accMagnitude >= 6 {
                    above_6_num += 1
                }
                
                let curDivWithMean = accMagnitude - avgAccel
                sumDevAccels = sumDevAccels + (curDivWithMean * curDivWithMean)
            }
            
            between_03_06 = Double(between_03_06_num).divided(by: Double(accels.count))
            between_06_1 = Double(between_06_1_num).divided(by: Double(accels.count))
            between_1_3 = Double(between_1_3_num).divided(by: Double(accels.count))
            between_3_6 = Double(between_3_6_num).divided(by: Double(accels.count))
            above_6 = Double(above_6_num).divided(by: Double(accels.count))
            
            let varianceAccel = sumDevAccels.divided(by: Double(accels.count))
            stdDevAccel = varianceAccel.squareRoot()
        }
        
        return (avgAccel,maxAccel,minAccel,stdDevAccel,between_03_06, between_06_1, between_1_3, between_3_6, above_6)
    }
    
    
    /// Extract movement features (related with speed) from the location points
    /// - Parameters:
    ///   - points: location array
    ///   - overlapLimit: timestamp representing overlap limit
    ///   - firstPointIsLastBeforeOverlap: 
    func processPoints(points: [UserLocation] ,overlapLimit: Double, firstPointIsLastBeforeOverlap: Bool) -> ProcessedPoints {
        self.lastPrevPoint = nil
        let processedPoints = ProcessedPoints.getProcessedPoints(avgSpeed: 0, maxSpeed: 0, minSpeed: 0, stdDevSpeed: 0, avgAcc: 0, maxAcc: 0, minAcc: 0, stdDevAcc: 0, gpsTimeMean: 0, distance: 0)!
        if points.count == 0 {
            return processedPoints
        } else if points.count == 1 {
            let curAcc = (points.first?.location?.horizontalAccuracy)!
            let firstPointTs = (points.first?.location?.timestamp.timeIntervalSince1970)!
            if  !firstPointIsLastBeforeOverlap && self.startSegmentDate!.timeIntervalSince1970 <= firstPointTs && firstPointTs <= overlapLimit {
                self.lastPrevPoint = points.first
            }
            
            processedPoints.avgAcc = curAcc
            processedPoints.maxAcc = curAcc
            processedPoints.minAcc = curAcc
            processedPoints.stdDevAcc = 0
            
            return processedPoints
        } else {
            let firstTime = points.first!.location!.timestamp.timeIntervalSince1970
            var prevTime = points.first!.location!.timestamp.timeIntervalSince1970
            var prevLat = points.first!.location!.coordinate.latitude
            var prevLon = points.first!.location!.coordinate.longitude
            var prevAcc = points.first!.location!.horizontalAccuracy
            
            var accSum = Double(0)
            var timeDiffSum = Double(0)
            var distSum = Double(0)
            var lastTime: TimeInterval? = nil
            var speeds = [Double]()
            
            let firstPointTs = (points.first?.location?.timestamp.timeIntervalSince1970)!
            if  !firstPointIsLastBeforeOverlap && self.startSegmentDate!.timeIntervalSince1970 <= firstPointTs && firstPointTs <= overlapLimit {
                self.lastPrevPoint = points.first
            }
            
            for i in 1..<points.count {
                let location = points[i]
                
                let curTime = location.location!.timestamp.timeIntervalSince1970
                let curLat = location.location!.coordinate.latitude
                let curLon = location.location!.coordinate.longitude
                let curAcc = location.location!.horizontalAccuracy
                
                if  self.startSegmentDate!.timeIntervalSince1970 <= curTime && curTime <= overlapLimit {
                    self.lastPrevPoint = location
                }
                
                accSum = accSum + curAcc
                lastTime=curTime
                
                let timeDiff = (curTime - prevTime)/( 60 * 60 ) // in seconds
                
                if timeDiff <= 0 {
                    if curAcc < prevAcc {
                        prevLat=curLat
                        prevLon=curLon
                        prevAcc=curAcc
                    }
                    continue
                }
                let distSimple = simpleDistance(lat1: prevLat, lon1: prevLon, lat2: curLat, lon2: curLon)
                timeDiffSum = timeDiffSum + timeDiff
                distSum = distSimple + distSum
                
                let curSpeed = distSimple/timeDiff
                speeds.append(curSpeed)
                
                prevTime=curTime
                prevLat=curLat
                prevLon=curLon
                prevAcc=curAcc
            }
            
            // ACC processing
            let avgAcc = accSum/Double(points.count)
            var maxAcc = Double(0)
            var minAcc = Double(100000)
            var sumDeviationsAcc = Double(0)
            
            for point in points {
                let curAcc = point.location!.horizontalAccuracy
                if curAcc>maxAcc {
                    maxAcc = curAcc
                }
                if curAcc<minAcc {
                    minAcc=curAcc
                }
                let diffWithMeanAcc = curAcc-avgAcc
                sumDeviationsAcc = sumDeviationsAcc + (diffWithMeanAcc * diffWithMeanAcc)
            }
            
            let varianceAcc = sumDeviationsAcc / Double(points.count)
            let stdDevAcc = varianceAcc.squareRoot()
            
            //speed Processing
            var avgSpeed = Double(0)
            var maxSpeed = Double(0)
            var minSpeed = Double(0)
            var stdDevSpeed = Double(0)
            
            if speeds.count > 0 {
                let totalTime = (lastTime!-firstTime)/(60 * 60) //in seconds
                avgSpeed = distSum / totalTime
                
                maxSpeed = Double(0)
                minSpeed = Double(10000)
                var sumDeviationsSp = Double(0)
                
                for speed in speeds {
                    if speed>maxSpeed {
                        maxSpeed=speed
                    }
                    if speed<minSpeed {
                        minSpeed=speed
                    }
                    let diffWithMeanSp = speed - avgSpeed
                    sumDeviationsSp = sumDeviationsSp + (diffWithMeanSp * diffWithMeanSp)
                }
                
                let varianceSp = sumDeviationsSp/Double(speeds.count)
                stdDevSpeed = varianceSp.squareRoot()
            }
            
            //outros processamentos
            var gpsTimeMean = Double(0)
            
            if speeds.count > 0 {
                gpsTimeMean = timeDiffSum/Double(speeds.count)
            }
            let distance = distSum * 1000 //from Km to m
            
            processedPoints.avgSpeed = avgSpeed
            processedPoints.maxSpeed = maxSpeed
            processedPoints.minSpeed = minSpeed
            processedPoints.stdDevSpeed = stdDevSpeed
            processedPoints.avgAcc = avgAcc
            processedPoints.maxAcc = maxAcc
            processedPoints.minAcc = minAcc
            processedPoints.stdDevAcc = stdDevAcc
            processedPoints.gpsTimeMean = gpsTimeMean
            processedPoints.distance = distance
            
            return processedPoints
        }
        
    }

    func degToRad(degrees: Double) -> Double {
        return degrees.multiplied(by: 0.0174532925199433) // Pi/180
    }
    
    func simpleDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadiusKm = Double(6371)
        let dLat = degToRad(degrees: lat2 - lat1)
        let dLon = degToRad(degrees: lon2 - lon1)
        let latAux = degToRad(degrees: lat1 + lat2)
        
        let dx = dLon * cos(0.5*latAux)
        let dy = dLat
        
        return earthRadiusKm * ((dx*dx)+(dy*dy)).squareRoot()
    }
    
    private func CleanUp() {
        print("data segmentation clean up")
        startSegmentDate = nil
        if let accIdx = self.segmNextIdxAcel {
            if accIdx >= self.accelerations.count {
                self.accelerations.removeAll()
            } else {
                self.accelerations.removeSubrange(0..<accIdx)
                startSegmentDate = self.accelerations.first?.timestamp
            }
        } else {
            self.accelerations.removeAll()
        }
        self.segmNextIdxAcel = nil
        
        if let locIdx = self.segmNextIdxLoc {
            if locIdx >= self.locations.count {
                self.locations.removeAll()
            } else {
                self.locations.removeSubrange(0..<locIdx)
                //Added logic to make the start segment the oldest date from locations or accelerations
                let proposedStartSementTimestamp = self.locations.first?.location?.timestamp ?? Date(timeIntervalSince1970: 0)
                if  startSegmentDate == nil
                    || proposedStartSementTimestamp < startSegmentDate ?? Date(timeIntervalSince1970: 0) {
                    startSegmentDate = self.locations.first?.location?.timestamp ?? nil
                }
            }
        } else {
            self.locations.removeAll()
        }
        self.segmNextIdxLoc = nil
    }
    
    
    /// check if some time has passed between date1 & date2
    /// - Parameters:
    ///   - startDate:
    ///   - endDate:
    ///   - time: time to compare
    func hasPassedTime(startDate: Date, endDate: Date, time: Double) -> Bool {
        print("diff: \(endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970) time: \(time)")
        return (endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970) > time
    }
    
    // belongs if start and end input dates are inside leg dates
    func inputsBelongingToLeg(legStartDate: Date, legEndDate: Date) -> [MLInputMetadata] {
        return self.inputs.filter({ (input) -> Bool in
            return !(Date(timeIntervalSince1970: input.startDate.timeIntervalSince1970) >= legEndDate || input.getEndDate() <= legStartDate)
        })
    }
    
    func removeUntilInput(input: MLInputMetadata) {
        let lastIdx = self.inputs.index(of: inputs.last!)
        for removeInput in self.inputs.prefix(lastIdx!)  {
            removeInput.managedObjectContext?.delete(removeInput)
        }
        
        self.inputs.removeSubrange(0..<lastIdx!)
        
    }
    // CoreData save parent use exclusivelly on the userinfo save context
    fileprivate func saveRDS(context: NSManagedObjectContext) {
        print("startRDSContextSave")
        //finite length task
        let bg = FiniteBackgroundTask()
        bg.registerBackgroundTask(withName: "saveChildContext")
        if (context.hasChanges) {
            do {
                context.processPendingChanges()
                try context.save()
            } catch {
                let nserror = error as NSError
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //let nserror = error as NSError
                //os_log("Unresolved error (" + nserror + "), (" + nserror.userInfo + ")", type: .error)
                //fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                //                    os_log("Unresolved error save store data" , type: .error)
                //                        print("CoreDate: unable to save changes for Raw data segmentation")
                print("\n")
                //                        os_log("Unresolved error save store data" , type: .error)
                print("error: \(error.localizedDescription)")
                print("error: \(nserror.userInfo)")
                print("error: \(nserror)")
                print("\n")
                UserInfo.writeToLog("!!rds!! Unresolved error save store data error: \(error.localizedDescription) !! \(nserror.userInfo)")
                if let obj = nserror.userInfo["NSValidationErrorObject"] as? NSManagedObject {
                    if let obj1 = context.registeredObject(for: obj.objectID) {
                        //                                context.delete(obj1)
                    }
                }
            }
        }
        bg.endBackgroundTask()
        print("endRDSContextSave")
    }
    
    func saveContext(sem: DispatchSemaphore) {
        if let context = self.managedObjectContext {
//            context.performAndWait {
            //print("rds: \(context.debugDescription)")
            self.managedObjectContextSemaphore.wait()
            context.performAndWait {
                self.saveRDS(context: context)
//                self.managedObjectContextSemaphore.signal()
                sem.signal()
            }

            self.managedObjectContextSemaphore.signal()
        } else {
            sem.signal()
        }
    }
}

class ProcessedPoints: NSManagedObject {
    public static let entityName = "ProcessedPoints"
    
    @NSManaged var avgSpeed: Double
    @NSManaged var maxSpeed: Double
    @NSManaged var minSpeed: Double
    @NSManaged var stdDevSpeed: Double
    @NSManaged var avgAcc: Double
    @NSManaged var maxAcc: Double
    @NSManaged var minAcc: Double
    @NSManaged var stdDevAcc: Double
    @NSManaged var gpsTimeMean: Double
    @NSManaged var distance: Double
    
    func setUp(_ avgSpeed: Double, _ maxSpeed: Double, _ minSpeed: Double, _ stdDevSpeed: Double, _ avgAcc: Double, _ maxAcc: Double, _ minAcc: Double, _ stdDevAcc: Double, _ gpsTimeMean: Double, _ distance: Double) {
        self.avgSpeed = avgSpeed
        self.maxSpeed = maxSpeed
        self.minSpeed = minSpeed
        self.stdDevSpeed = stdDevSpeed
        self.avgAcc = avgAcc
        self.maxAcc = maxAcc
        self.minAcc = minAcc
        self.stdDevAcc = stdDevAcc
        self.gpsTimeMean = gpsTimeMean
        self.distance = distance
    }
    
    convenience init(avgSpeed: Double, maxSpeed: Double, minSpeed: Double, stdDevSpeed: Double, avgAcc: Double, maxAcc: Double, minAcc: Double, stdDevAcc: Double, gpsTimeMean: Double, distance: Double) {
        
        let rds = RawDataSegmentation.getInstance()
        
        rds.managedObjectContextSemaphore.wait()
        let entity = NSEntityDescription.entity(forEntityName: ProcessedPoints.entityName, in: rds.managedObjectContext!)!
        self.init(entity: entity, insertInto: UserInfo.context!)
        setUp(avgSpeed, maxSpeed, minSpeed, stdDevSpeed, avgAcc, maxAcc, minAcc, stdDevAcc, gpsTimeMean, distance)
        rds.managedObjectContextSemaphore.signal()

    }
    
    public static func getProcessedPoints(avgSpeed: Double, maxSpeed: Double, minSpeed: Double, stdDevSpeed: Double, avgAcc: Double, maxAcc: Double, minAcc: Double, stdDevAcc: Double, gpsTimeMean: Double, distance: Double) -> ProcessedPoints? {
        var processedPoints: ProcessedPoints?
        RawDataSegmentation.getInstance().managedObjectContext?.performAndWait {
            processedPoints = ProcessedPoints(avgSpeed: avgSpeed, maxSpeed: maxSpeed, minSpeed: minSpeed, stdDevSpeed: stdDevSpeed, avgAcc: avgAcc, maxAcc: maxAcc, minAcc: minAcc, stdDevAcc: stdDevAcc, gpsTimeMean: gpsTimeMean, distance: distance)
        }
        return processedPoints
    }
    
    func getTextToPrint() -> String {
        return "avgSpeed: \(avgSpeed), maxSpeed: \(maxSpeed), minSpeed: \(minSpeed), stdDevSpeed: \(stdDevSpeed), avgAcc: \(avgAcc), maxAcc: \(maxAcc), minAcc: \(minAcc), stdDevAcc: \(stdDevAcc), gpsTimeMean: \(gpsTimeMean), distance: \(distance)"
    }
}

class MLInputMetadata: NSManagedObject {
    public static let entityName = "MLInputMetadata"
    
    @NSManaged var input: MLAlgorithmInput?

    @NSManaged var startDate: Date
    @NSManaged private var probasDicts: [Int64: Double]?
    private var probasOrd = [(Int64, Double)]()
    
    convenience init(input: MLAlgorithmInput, startDate: Date){
        let rds = RawDataSegmentation.getInstance()
        print("MLInputMetadata: Start Creating")
        let entity = NSEntityDescription.entity(forEntityName: MLInputMetadata.entityName, in: rds.managedObjectContext!)!
        self.init(entity: entity, insertInto: UserInfo.context!)
        
        self.probasDicts = [Int64: Double]()
        self.input = input

        self.startDate = startDate

        print("MLInputMetadata: Start Created")
    }
    
    public static func getMLInputMetadata(input: MLAlgorithmInput, startDate: Date) -> MLInputMetadata? {
        var mlInputMetadata: MLInputMetadata?
        let rds = RawDataSegmentation.getInstance()
        rds.managedObjectContextSemaphore.wait()
        RawDataSegmentation.getInstance().managedObjectContext?.performAndWait {
            mlInputMetadata = MLInputMetadata(input: input, startDate: startDate)
            RawDataSegmentation.getInstance().saveRDS(context: RawDataSegmentation.getInstance().managedObjectContext!)
        }
        rds.managedObjectContextSemaphore.signal()
        return mlInputMetadata
    }
    
    func getProbasDicts() -> [Int64: Double] {
        return self.probasDicts ?? [Int64: Double]()
    }
    
    func setPredictions(predictions: [Int64: Double]) {
        self.probasDicts = predictions
        self.probasOrd = predictions.sorted(by: {
            $0.value > $1.value
        })
    }
    
    func getMaxProbability() -> (Int64, Double) {
        return probasOrd.first ?? (-1, 0)
    }
    func getProbasOrd() -> [(Int64, Double)] {
        return probasOrd
    }
    
    func getProbabilityByMode(mode: Int64) -> Double {
        return probasDicts?[mode] ?? 0
    }
    
    func getEndDate() -> Date {
        return Date(timeIntervalSince1970: self.startDate.addingTimeInterval(RawDataSegmentation.getInstance().TimeWindow).timeIntervalSince1970)
    }
    
    func getTextToPrint() -> String {
//        return "InputMetadata:: startDate: \(startDate.description), probasDicts: \(probasDicts) inputData:\(input.getTextToPrint())"
        return "InputMetadata:: \(input?.getTextToPrint())"
    }
}


class MLAlgorithmInput: ProcessedPoints {
    public static let entityNameDescriptionForChild = "MLAlgorithmInput"
    
    @NSManaged var accelsBelowFilter: Double
    @NSManaged var avgAccel: Double
    @NSManaged var maxAccel: Double
    @NSManaged var minAccel: Double
    @NSManaged var stdDevAccel: Double
    @NSManaged var avgFilteredAccels: Double
    @NSManaged var estimatedSpeed: Double
    
    @NSManaged var between_03_06: Double
    @NSManaged var between_06_1: Double
    @NSManaged var between_1_3: Double
    @NSManaged var between_3_6: Double
    @NSManaged var above_6: Double
    
    let OS = 1 //Android = 0 IOS = 1    WARNING if not 1 then error
    
    convenience init(avgSpeed: Double, maxSpeed: Double, minSpeed: Double, stdDevSpeed: Double, avgAcc: Double, maxAcc: Double, minAcc: Double, stdDevAcc: Double, gpsTimeMean: Double, distance: Double, avgAccel: Double, maxAccel: Double, minAccel: Double, stdDevAccel: Double, accelsBelowFilter: Double, avgFilteredAccels: Double, between_03_06: Double, between_06_1: Double, between_1_3: Double, between_3_6: Double, above_6: Double){
        
        let rds = RawDataSegmentation.getInstance()
        
        rds.managedObjectContextSemaphore.wait()
        print("MLAlgorithmInput: Start Creating")
        let entity = NSEntityDescription.entity(forEntityName: MLAlgorithmInput.entityNameDescriptionForChild, in: rds.managedObjectContext!)!
        self.init(entity: entity, insertInto: UserInfo.context!)
        
        self.avgAccel = avgAccel
        self.maxAccel = maxAccel
        self.minAccel = minAccel
        self.stdDevAccel = stdDevAccel
        self.accelsBelowFilter = accelsBelowFilter
        self.avgFilteredAccels = avgFilteredAccels
        
        self.between_03_06 = between_03_06
        self.between_06_1 = between_06_1
        self.between_1_3 = between_1_3
        self.between_3_6 = between_3_6
        self.above_6 = above_6
        
        self.setUp(avgSpeed, maxSpeed, minSpeed, stdDevSpeed, avgAcc, maxAcc, minAcc, stdDevAcc, gpsTimeMean, distance)
        RawDataSegmentation.getInstance().saveRDS(context: RawDataSegmentation.getInstance().managedObjectContext!)
        print("MLAlgorithmInput: Created")
        rds.managedObjectContextSemaphore.signal()
//        UserInfo.appDelegate!.saveContext()
    }
    
    public static func getMLInputMetadata(avgSpeed: Double, maxSpeed: Double, minSpeed: Double, stdDevSpeed: Double, avgAcc: Double, maxAcc: Double, minAcc: Double, stdDevAcc: Double, gpsTimeMean: Double, distance: Double, avgAccel: Double, maxAccel: Double, minAccel: Double, stdDevAccel: Double, accelsBelowFilter: Double, avgFilteredAccels: Double, between_03_06: Double, between_06_1: Double, between_1_3: Double, between_3_6: Double, above_6: Double) -> MLAlgorithmInput? {
        var mLAlgorithmInput: MLAlgorithmInput?
        RawDataSegmentation.getInstance().managedObjectContext?.performAndWait {
            mLAlgorithmInput = MLAlgorithmInput(avgSpeed: avgSpeed, maxSpeed: maxSpeed, minSpeed: minSpeed, stdDevSpeed: stdDevSpeed, avgAcc: avgAcc, maxAcc: maxAcc, minAcc: minAcc, stdDevAcc: stdDevAcc, gpsTimeMean: gpsTimeMean, distance: distance, avgAccel: avgAccel, maxAccel: maxAccel, minAccel: minAccel, stdDevAccel: stdDevAccel, accelsBelowFilter: accelsBelowFilter, avgFilteredAccels: avgFilteredAccels, between_03_06: between_03_06, between_06_1: between_06_1, between_1_3: between_1_3, between_3_6: between_3_6, above_6: above_6)
        }
        return mLAlgorithmInput
    }
    
    override func getTextToPrint() -> String {
        return "\(estimatedSpeed) ; \(accelsBelowFilter) ; \(avgFilteredAccels) ; \(avgAccel) ; \(maxAccel) ; \(minAccel) ; \(stdDevAccel) ; \(avgSpeed) ; \(maxSpeed) ; \(minSpeed) ; \(stdDevSpeed) ; \(avgAcc) ; \(maxAcc) ; \(minAcc) ; \(stdDevAcc) ; \(gpsTimeMean) ; \(distance) ; "
    }
    
}
