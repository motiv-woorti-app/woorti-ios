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
import Crashlytics

/*
 * Handle trip leg creation, merge potencial legs.
 - var: instance - singleton instance of RawDataDetection
 - var walkingStrongMinProb - minimum probability to consider a strong walking segment
 - var stillStrongMinProb - minimum probability to consider a strong still segment
 - var walkingMinProbForCandidates - probability to consider a candidate for strong segments
 */
class RawDataDetection {
    static private var instance: RawDataDetection? = nil
    static private let walkingStrongMinProb = Double(0.75)
    static private let stillStrongMinProb = Double(0.9)
    static private let walkingMinProbForCandidates = Double(0.5)
    static private let walkingStrongPoint1JoinProbability = Double(0.5)
    private let walkingLengthFilter: Int
    private let stillLengthFilter : Int
    
    enum mergeFiltersEnum: Int {
        case walkEdge
        case othersEdge
        case stillEdge
        
        case walkBetweenOthers
        case othersBetweenWalk
        
        case stillBetweenOthers
        case othersBetweenStill
    }
    
    init(){
        walkingLengthFilter = RawDataDetection.timeInsegmentsNumber(seconds: 90) // prev 120
        stillLengthFilter = RawDataDetection.timeInsegmentsNumber(seconds: 180) // prev 120
    }
    
    /*
    * get instance of RawDataDetection
    */
    static public func getInstance() -> RawDataDetection {
        if instance == nil {
            instance = RawDataDetection()
        }
        return self.instance!
    }
    
    
    /// Define segments according to potential legs
    /// - Parameters:
    ///   - strongSegments: strong segments array
    ///   - inputs: classifier results
    ///   - intervalStart:
    ///   - intervalFinish:
    func GeneratePotentialLegs(strongSegments: [Segments], inputs: [MLInputMetadata], intervalStart: Int = -1, intervalFinish: Int = -1) -> [Segments] {
        var potentialLegs = [Segments]()
        var first: Int
        var length: Int
        var intervalInit = intervalStart
        var intervalEnd = intervalFinish
        
        if intervalInit == -1 && intervalEnd == -1 {
            intervalInit = 0
            intervalEnd = inputs.count
        }
        
        if strongSegments.count == 0 {
            first = intervalInit
            length = intervalEnd - intervalInit
            let (bestModeSegm,bestConfSegm) = self.bestModeInInterval(input: inputs)
            potentialLegs.append(Segments(mode: Int(bestModeSegm), length: length, probSum: bestConfSegm, firstIndex: first))
        } else {
            for j in 0..<strongSegments.count {
                if j==0 && strongSegments[j].firstIndex > intervalInit {
                    first = intervalInit
                    length = strongSegments[j].firstIndex - first
                    let (bestModeSegm,bestConfSegm) = self.bestModeInInterval(input: inputs, start: first, size: length)
                    potentialLegs.append(Segments(mode: Int(bestModeSegm), length: length, probSum: bestConfSegm, firstIndex: first))
                }
                if j>0 {
                    first = strongSegments[j-1].firstIndex + strongSegments[j-1].length
                    length = strongSegments[j].firstIndex - first
                    if length > 0 {
                        let (bestModeSegm,bestConfSegm) = self.bestModeInInterval(input: inputs, start: first, size: length)
                        potentialLegs.append(Segments(mode: Int(bestModeSegm), length: length, probSum: bestConfSegm, firstIndex: first))
                    }
                }
                potentialLegs.append(Segments(mode: strongSegments[j].mode, length: strongSegments[j].length, probSum: strongSegments[j].probSum, firstIndex: strongSegments[j].firstIndex))
                if (j == strongSegments.count - 1) && (strongSegments[j].firstIndex + strongSegments[j].length < intervalEnd) {
                    first = strongSegments[j].firstIndex + strongSegments[j].length
                    length = intervalEnd - first
                    
                    let (bestModeSegm,bestConfSegm) = self.bestModeInInterval(input: inputs, start: first, size: length)
                    potentialLegs.append(Segments(mode: Int(bestModeSegm), length: length, probSum: bestConfSegm, firstIndex: first))
                }
            }
        }
        return potentialLegs
    }
    
    /// Generate final legs
    /// - Parameter inputs: classifier results
    func TripEvaluation(inputs: [MLInputMetadata]) -> [Segments] {
        print("Probas:")
        for input in inputs {
            var content = ""
            for prob in input.getProbasOrd() {
                content.append("(\(prob.0), \(prob.1), ")
            }
            
            print("\(inputs.index(of: input)) [\(content)]")
        }
        
        let strongSegments = self.legSeparation(inputs: inputs)
        print("Walking segments after point 2.1):")
        for s in strongSegments {
            print("{'mode': \(s.mode), 'probSum': \(s.probSum), 'length': \(s.length), 'firstIdx': \(s.firstIndex)}")
        }
        var potentialLegs = GeneratePotentialLegs(strongSegments: strongSegments, inputs: inputs)
        
        print("Potencial legs:")
        for s in potentialLegs {
            print("{'mode': \(s.mode), 'probSum': \(s.probSum), 'length': \(s.length), 'firstIdx': \(s.firstIndex)}")
        }
        //potential legs 
        let mergeFilters = [
            mergeFiltersEnum.walkEdge: RawDataDetection.timeInsegmentsNumber(seconds: 90),               // prev 120
            mergeFiltersEnum.othersEdge: RawDataDetection.timeInsegmentsNumber(seconds: 180),            // prev 250
            mergeFiltersEnum.stillEdge: RawDataDetection.timeInsegmentsNumber(seconds: 135),             // prev 130
            mergeFiltersEnum.walkBetweenOthers: RawDataDetection.timeInsegmentsNumber(seconds: 180),     // prev 110
            mergeFiltersEnum.othersBetweenWalk: RawDataDetection.timeInsegmentsNumber(seconds: 180),     // prev 250
            mergeFiltersEnum.stillBetweenOthers: RawDataDetection.timeInsegmentsNumber(seconds: 180),    // prev 190
            mergeFiltersEnum.othersBetweenStill: RawDataDetection.timeInsegmentsNumber(seconds: 180)]    // prev 190
        
        if potentialLegs.count >= 2 {
            potentialLegs = mergeConsecutiveLegs(potentialLegs: potentialLegs)
        }
        print("Potencial legs after merging consecutive legs:")
        for s in potentialLegs {
            print("{'mode': \(s.mode), 'probSum': \(s.probSum), 'length': \(s.length), 'firstIdx': \(s.firstIndex)}")
        }
        
        if potentialLegs.count >= 2 {
            potentialLegs = mergePotentialLegs(potentialLegs: potentialLegs, inputs: inputs, mergeFilters: mergeFilters, isWalkingLevel: true)
        }
        print("Potencial legs after merging Potential legs (walking level):")
        for s in potentialLegs {
            print("{'mode': \(s.mode), 'probSum': \(s.probSum), 'length': \(s.length), 'firstIdx': \(s.firstIndex)}")
        }
        
        let segmentsToAdd = identifyStillSegments(potentialLegs: potentialLegs, mergeFilters: mergeFilters, inputs: inputs)
        
        for j in stride(from: segmentsToAdd.count - 1, to: -1, by: -1) {
            potentialLegs.remove(at: segmentsToAdd[j].0)
            let newSegmentsToAdd = segmentsToAdd[j].1
            for k in stride(from: newSegmentsToAdd.count - 1, to: -1, by: -1) {
                potentialLegs.insert(newSegmentsToAdd[k], at: segmentsToAdd[j].0)
            }
        }
        
        if potentialLegs.count >= 2 {
            potentialLegs = mergeConsecutiveLegs(potentialLegs: potentialLegs)
        }
        
        if potentialLegs.count >= 2 {
            var left = 0
            var right = 1
            
            let mergeWeakFilter = 3
            
            while right < potentialLegs.count {
                var wasMerged = false
                
                if potentialLegs[left].length <= mergeWeakFilter &&
                    potentialLegs[left].probSum < Double(potentialLegs[left].length)/2.0 &&
                    potentialLegs[right].length > mergeWeakFilter {
                    
                    let rleg = potentialLegs.removeFirst()
                    
                    potentialLegs[left].mode = rleg.mode
                    
                    let mProbas = calcModesInInterval(input: inputs, first: potentialLegs[left].firstIndex, end: potentialLegs[left].firstIndex + potentialLegs[left].length)
                    
                    potentialLegs[left].probSum = mProbas[Int64(rleg.mode)]! + rleg.probSum
                    potentialLegs[left].length += rleg.length
                    
                    wasMerged = true
                }
                
                if !wasMerged &&
                    potentialLegs[right].length <= mergeWeakFilter &&
                    potentialLegs[right].probSum < Double(potentialLegs[right].length)/2.0 &&
                    potentialLegs[left].length > mergeWeakFilter {
                    
                    let rleg = potentialLegs.removeFirst()
                    
                    potentialLegs[left].length += rleg.length
                    
                    let mProbas = calcModesInInterval(input: inputs, first: rleg.firstIndex, end: rleg.firstIndex + rleg.length)
                    
                    potentialLegs[left].probSum += mProbas[Int64(potentialLegs[left].mode)]!
                    
                    wasMerged = true
                    
                }
                
                if !wasMerged {
                    left += 1
                    right += 1
                }
            }
        }
        
        print("Potencial legs after merging weak segments:")
        for s in potentialLegs {
            print("{'mode': \(s.mode), 'probSum': \(s.probSum), 'length': \(s.length), 'firstIdx': \(s.firstIndex)}")
        }
        
        var identifiedLegs = [Segments]()
        identifiedLegs = potentialLegs
        
        print("Final legs res:")
        for s in identifiedLegs {
            let lastIdx = s.firstIndex + s.length - 1
            let firstTsLeg = inputs[s.firstIndex].startDate.timeIntervalSince1970
            let minutesFromTripStart = (firstTsLeg - inputs[0].startDate.timeIntervalSince1970) / (60)
            
            print("{'mode': \(s.mode), 'probSum': \(s.probSum), 'length': \(s.length), 'firstIdx': \(s.firstIndex)}, 'lastIdx': \(lastIdx), 'firstTimestamp': \(firstTsLeg), 'minutesFromTripStart': \(minutesFromTripStart)")
        }
        
        return identifiedLegs
    }
    
    /// Identify segments where the user is not moving
    /// - Parameters:
    ///   - potentialLegs: trip divided by legs
    ///   - mergeFilters:
    ///   - inputs: classifier results
    func identifyStillSegments(potentialLegs: [Segments], mergeFilters: [mergeFiltersEnum: Int], inputs: [MLInputMetadata]) -> [(Int, [Segments])] {
        var segmentsToAdd = [(Int, [Segments])]()
        for j in 0..<potentialLegs.count {
            let leg = potentialLegs[j]
            if leg.mode != Trip.modesOfTransport.walking.rawValue {
                let first = leg.firstIndex
                let last = leg.firstIndex + leg.length
                let stillSegments = SegmentsIdentification(inputs: inputs, strongMinProb: RawDataDetection.stillStrongMinProb, mode: Int64(Trip.modesOfTransport.stationary.rawValue), firstIndex: first, lastIndex: last)
                
                var stillStrongSegments = stillSegments.filter { (segment) -> Bool in
                    segment.length >= stillLengthFilter
                }
                
                var candidateSegments = stillSegments.filter { (segment) -> Bool in
                    segment.length < stillLengthFilter
                }
                
                if stillStrongSegments.count == 0 {
                    continue
                }
                
                if candidateSegments.count > 0 {
                    var candidatesPerStrong = [Int : [Segments]]()
                    candidatesPerStrong[-1] = [Segments]()
                    for ss in stillStrongSegments {
                        candidatesPerStrong[ss.firstIndex] = [Segments]()
                    }
                    for ss in stillStrongSegments {
                        while candidateSegments.count > 0 && candidateSegments[0].firstIndex < ss.firstIndex {
                            let candidate = candidateSegments.removeFirst()
                            candidatesPerStrong[ss.firstIndex]!.append(candidate)
                        }
                    }
                    
                    while candidateSegments.count > 0 {
                        let candidate = candidateSegments.removeFirst()
                        candidatesPerStrong[-1]!.append(candidate)
                    }
                    
                    stillStrongSegments = MergeCandidates(strongSegments: stillStrongSegments, candidatesPerStrong: candidatesPerStrong, inputs: inputs)
                    var potentialSegmentsInInterval = GeneratePotentialLegs(strongSegments: stillStrongSegments, inputs: inputs, intervalStart: first, intervalFinish: last)
                    
                    if potentialSegmentsInInterval.count >= 2 {
                        potentialSegmentsInInterval = mergePotentialLegs(potentialLegs: potentialSegmentsInInterval, inputs: inputs, mergeFilters: mergeFilters, isWalkingLevel: false)
                    }
                    
                    if potentialSegmentsInInterval.count >= 2 {
                        potentialSegmentsInInterval = mergeConsecutiveLegs(potentialLegs: potentialSegmentsInInterval)
                    }
                    
                    if potentialSegmentsInInterval.count > 1 {
                        segmentsToAdd.append((j, potentialSegmentsInInterval))
                    }
                }
            }
        }
        
        return segmentsToAdd
    }
    
    /// Segments with equal modes are merged
    /// - Parameter potentialLegs: trip divided in potential legs
    func mergeConsecutiveLegs(potentialLegs: [Segments]) -> [Segments] {
        var left = 0
        var right = 1
        
        var pLegs = potentialLegs
        
        while right < pLegs.count {
            var wasMerged = false
            if pLegs[left].mode == pLegs[right].mode {
                let rleg = pLegs.remove(at: right)
                pLegs[left].length = pLegs[left].length + rleg.length
                pLegs[left].probSum = pLegs[left].probSum + rleg.probSum
                wasMerged = true
            }
            if !wasMerged {
                left = left + 1
                right = right + 1
            }
        }
        
        return pLegs
    }
    
    /// Merge legs that are possibly identical
    /// - Parameter potentialLegs: trip divided in potential legs
    /// - Parameter inputs: Classifier results
    /// - Parameter mergeFilters: Filters for merges
    /// - Parameter isWalkingLevel: Boolean
    func mergePotentialLegs(potentialLegs: [Segments], inputs: [MLInputMetadata], mergeFilters: [mergeFiltersEnum: Int], isWalkingLevel: Bool) -> [Segments] {
        var runNext = true
        var orderedLegs = [(Int, Int)]()
        var plegs = potentialLegs
        var wasMerged = false
        
        while runNext {
            orderedLegs = orderPotentialLegs(potentialLegs: plegs)
            for i in 0..<orderedLegs.count {
                if orderedLegs.count < 2 {
                    runNext=false
                    break
                }
                let index2check = orderedLegs[i].0
                if index2check == 0 {
                    (plegs, wasMerged) = checkMergesRight(index2Check: index2check, potentialLegs: plegs, inputs: inputs, mergeFilters: mergeFilters, isWalkingLevel: isWalkingLevel)
                } else if index2check == plegs.count - 1{
                    (plegs, wasMerged) = checkMergesLeft(index2Check: index2check, potentialLegs: plegs, inputs: inputs, mergeFilters: mergeFilters, isWalkingLevel: isWalkingLevel)
                } else {
                    (plegs, wasMerged) = checkMergesLeft(index2Check: index2check, potentialLegs: plegs, inputs: inputs, mergeFilters: mergeFilters, isWalkingLevel: isWalkingLevel)
                    if !wasMerged {
                        (plegs, wasMerged) = checkMergesRight(index2Check: index2check, potentialLegs: plegs, inputs: inputs, mergeFilters: mergeFilters, isWalkingLevel: isWalkingLevel)
                    }
                }
                
                if wasMerged {
                    break
                }
                
                if i==orderedLegs.count-1 && !wasMerged {
                    runNext = false
                }
            }
        }
        
        return plegs
    }
    
    ///Check merges on the right of index
    func checkMergesRight(index2Check: Int, potentialLegs: [Segments], inputs: [MLInputMetadata], mergeFilters: [mergeFiltersEnum: Int], isWalkingLevel: Bool) -> ([Segments], Bool){
        var pLegs = potentialLegs
        
        var targetMode = 0
        var targetFilter = 0
        if isWalkingLevel {
            targetMode = Trip.modesOfTransport.walking.rawValue
            targetFilter = mergeFilters[mergeFiltersEnum.walkEdge]!
        } else {
            targetMode = Trip.modesOfTransport.stationary.rawValue
            targetFilter = mergeFilters[mergeFiltersEnum.stillEdge]!
        }
        
        let ult = potentialLegs.count - 1
        let penUlt = potentialLegs.count - 2
        
        if index2Check==penUlt {
            if potentialLegs.last!.mode == targetMode
                && potentialLegs[penUlt].mode != targetMode
                && potentialLegs.last!.length < targetFilter
                && potentialLegs[penUlt].length >= mergeFilters[mergeFiltersEnum.othersEdge]! {
                
                pLegs = mergeRightTwo(index: ult, potentialLegs: potentialLegs, inputs: inputs)
                return (pLegs,true)
            }
            if potentialLegs.last!.mode != targetMode
                && potentialLegs[penUlt].mode == targetMode
                && potentialLegs.last!.length < mergeFilters[mergeFiltersEnum.othersEdge]! {
                
                if potentialLegs[penUlt].length >= targetFilter
                    || (potentialLegs[penUlt].length < targetFilter && potentialLegs[penUlt].length >= potentialLegs.last!.length) {
                    pLegs = mergeRightTwo(index: ult, potentialLegs: potentialLegs, inputs: inputs)
                    return (pLegs,true)
                }
            }
            
            return (pLegs, false)
        } else {
            let left = index2Check
            let mid = index2Check + 1
            let right = index2Check + 2
            
            return CheckMergesBetween(right: right, mid: mid, left: left, potentialLegs: pLegs, inputs: inputs, mergeFilters: mergeFilters, isWalkingLevel: isWalkingLevel)
        }
    }
    
    ///Check merges between indexes
    func CheckMergesBetween(right: Int, mid: Int, left: Int, potentialLegs: [Segments], inputs: [MLInputMetadata], mergeFilters: [mergeFiltersEnum: Int], isWalkingLevel: Bool) -> ([Segments], Bool) {
        
        var targetMode = 0
        var targetBetween = 0
        var othersBetweenTarget = 0
        if isWalkingLevel {
            targetMode = Trip.modesOfTransport.walking.rawValue
            targetBetween = mergeFilters[mergeFiltersEnum.walkBetweenOthers]!
            othersBetweenTarget = mergeFilters[mergeFiltersEnum.othersBetweenWalk]!
        } else {
            targetMode = Trip.modesOfTransport.stationary.rawValue
            targetBetween = mergeFilters[mergeFiltersEnum.stillBetweenOthers]!
            othersBetweenTarget = mergeFilters[mergeFiltersEnum.othersBetweenStill]!
        }
        
        var pLegs = potentialLegs
        if pLegs[mid].mode == targetMode {
            if pLegs[left].mode == pLegs[right].mode && pLegs[mid].length <= targetBetween {
                pLegs = mergeThree(right: right, mid: mid, left: left, potentialLegs: potentialLegs, inputs: inputs)
                return (pLegs, true)
            }
        }
        if pLegs[mid].mode != targetMode {
            if pLegs[left].mode == pLegs[right].mode && pLegs[mid].length <= othersBetweenTarget {
                pLegs = mergeThree(right: right, mid: mid, left: left, potentialLegs: potentialLegs, inputs: inputs)
                return (pLegs, true)
            }
        }
        return (pLegs, false)
    }
    
    func mergeThree(right: Int, mid: Int, left: Int, potentialLegs: [Segments], inputs: [MLInputMetadata]) -> [Segments] {
        var pLegs = potentialLegs
        let rLeg = pLegs.remove(at: right)
        let mLeg = pLegs.remove(at: mid)
        
        pLegs[left].length += mLeg.length + rLeg.length
        let mProbas = calcModesInInterval(input: inputs, first: mLeg.firstIndex, end: mLeg.firstIndex + mLeg.length)
        
        pLegs[left].probSum += mProbas[Int64(pLegs[left].mode)]! + rLeg.probSum
        
        return pLegs
    }
    
    func mergeRightTwo(index: Int, potentialLegs: [Segments], inputs: [MLInputMetadata]) -> [Segments] {
        var pLegs = potentialLegs
        let lastLeg = pLegs.remove(at: index)
        let mProbas = calcModesInInterval(input: inputs, first: lastLeg.firstIndex, end: lastLeg.firstIndex + lastLeg.length)
        
        pLegs[index-1].probSum += mProbas[Int64(pLegs[index-1].mode)]!
        pLegs[index-1].length += lastLeg.length
        
        return pLegs
    }
    
    func mergeLeftTwo(index: Int, potentialLegs: [Segments], inputs: [MLInputMetadata]) -> [Segments] {
        var pLegs = potentialLegs
        let firstLeg = pLegs.remove(at: index)
        let mProbas = calcModesInInterval(input: inputs, first: firstLeg.firstIndex, end: firstLeg.firstIndex + firstLeg.length)
        
        pLegs[index].probSum += mProbas[Int64(pLegs[index].mode)]!
        pLegs[index].length += firstLeg.length
        pLegs[index].firstIndex = firstLeg.firstIndex
        
        return pLegs
    }
    
    ///Get merge possibilities at the left of index
    func checkMergesLeft(index2Check: Int, potentialLegs: [Segments], inputs: [MLInputMetadata], mergeFilters: [mergeFiltersEnum: Int], isWalkingLevel: Bool) -> ([Segments], Bool){
        
        var targetMode = 0
        var targetFilter = 0
        if isWalkingLevel {
            targetMode = Trip.modesOfTransport.walking.rawValue
            targetFilter = mergeFilters[mergeFiltersEnum.walkEdge]!
        } else {
            targetMode = Trip.modesOfTransport.stationary.rawValue
            targetFilter = mergeFilters[mergeFiltersEnum.stillEdge]!
        }
        
        var pLegs = potentialLegs
        if index2Check==1 {
            if potentialLegs.first!.mode == targetMode
                && potentialLegs[1].mode != targetMode
                && potentialLegs.first!.length < targetFilter
                && potentialLegs[1].length >= mergeFilters[mergeFiltersEnum.othersEdge]! {
                
                pLegs = mergeLeftTwo(index: 0, potentialLegs: pLegs, inputs: inputs)
                return (pLegs,true)
            }
            if potentialLegs.first!.mode != targetMode
                && potentialLegs[1].mode == targetMode
                && potentialLegs.first!.length < mergeFilters[mergeFiltersEnum.othersEdge]! {
                
                if potentialLegs[1].length >= targetFilter
                || (potentialLegs[1].length < targetFilter && potentialLegs[1].length >= potentialLegs[0].length) {
                    pLegs = mergeLeftTwo(index: 0, potentialLegs: pLegs, inputs: inputs)
                    return (pLegs,true)
                }
                
            }
            
            return (pLegs, false)
        } else {
            let left = index2Check - 2
            let mid = index2Check - 1
            let right = index2Check
            
            return CheckMergesBetween(right: right, mid: mid, left: left, potentialLegs: pLegs, inputs: inputs, mergeFilters: mergeFilters, isWalkingLevel: isWalkingLevel)
        }
    }
    
    func orderPotentialLegs(potentialLegs: [Segments]) -> [(Int, Int)] {
        var orderedLegs = [(Int, Int)]()
        for i in 0..<potentialLegs.count {
            orderedLegs.append((i,potentialLegs[i].length))
        }
        
        return orderedLegs.sorted(by: { (v1, v2) -> Bool in
            v1.1 > v2.1
        })
    }

    
    /// get mode with highest probability in interval
    /// - Parameters:
    ///   - input: classifier results
    ///   - start:
    ///   - size: inp
    func bestModeInInterval(input: [MLInputMetadata], start: Int = 0, size: Int = -1) -> (Int64,Double) {
        var first = start
        var length = size
        
        if length == -1 {
            length = input.count
        }
        
        let end = first + length
        let legProbas: [Int64: Double] = calcModesInInterval(input: input, first: first, end: end)
        let legProbasOrd = legProbas.sorted { (v1, v2) -> Bool in
            v1.value > v2.value
        }
        
        return legProbasOrd.first ?? (Int64(0),Double(0))
    }
    
    /// get probabilities by mode in interval
    /// - Parameters:
    ///   - input: classifier results
    ///   - first:
    ///   - end:
    func calcModesInInterval(input: [MLInputMetadata], first: Int, end: Int) -> [Int64: Double]{
        var legProbas = [Int64: Double]()
        let keys = Array(input.first!.getProbasDicts().keys)
        for key in keys {
            legProbas[key] = Double(0)
        }
        
        for k in first..<end {
            for key in keys {
                legProbas[key] = (legProbas[key] ?? 0) + input[k].getProbabilityByMode(mode: key)
            }
        }
        return legProbas
    }
    
    /// merge segments according to strong segments
    /// - Parameters:
    ///   - strongSegments: segments with high probability towards one mode
    ///   - candidatesPerStrong:
    ///   - inputs: classifier results
    func MergeCandidates(strongSegments:  [Segments], candidatesPerStrong: [Int: [Segments]], inputs: [MLInputMetadata]) -> [Segments] {
        //Point2.1
        for j in 0..<strongSegments.count {
            
            var candidateSegments = candidatesPerStrong[strongSegments[j].firstIndex]! //SegmentsIdentification(inputs: inputs, strongMinProb: RawDataDetection.walkingMinProbForCandidates, firstIndex: first, lastIndex: last)
            
            if j==0 {
                for k in stride(from: candidateSegments.count - 1, to: -1, by: -1) {
                    let lenSepSegment = strongSegments[j].firstIndex - (candidateSegments[k].firstIndex + candidateSegments[k].length)
                    if lenSepSegment <= (candidateSegments[k].length + 2)/2 {
                        strongSegments[j].probSum += candidateSegments[k].probSum
                        for m in stride(from: candidateSegments[k].firstIndex + candidateSegments[k].length, to: strongSegments[j].firstIndex, by: 1) {
                            strongSegments[j].probSum += inputs[m].getProbabilityByMode(mode: Int64(strongSegments[j].mode))
                        }
                        
                        strongSegments[j].firstIndex = candidateSegments[k].firstIndex
                        strongSegments[j].length += strongSegments[k].length + lenSepSegment
                    } else {
                        break
                    }
                }
            } else {
                //From right to left
                var lastMergedRight = candidateSegments.count
                for k in stride(from: candidateSegments.count - 1, to: -1, by: -1) {
                    let lenSepSegment = strongSegments[j].firstIndex - (candidateSegments[k].firstIndex + candidateSegments[k].length)
                    if lenSepSegment <= (candidateSegments[k].length + 2)/2 {
                        lastMergedRight = k
                        strongSegments[j].probSum += candidateSegments[k].probSum
                        for m in stride(from: candidateSegments[k].firstIndex + candidateSegments[k].length, to: strongSegments[j].firstIndex, by: 1) {
                            strongSegments[j].probSum += inputs[m].getProbabilityByMode(mode: Int64(strongSegments[j].mode))
                        }
                        
                        strongSegments[j].firstIndex = candidateSegments[k].firstIndex
                        strongSegments[j].length += candidateSegments[k].length + lenSepSegment
                    } else {
                        break
                    }
                }
                
                //from left To right
                for k in 0..<lastMergedRight {
                    let lenSepSegment = candidateSegments[k].firstIndex - (strongSegments[j-1].firstIndex + strongSegments[j-1].length)
                    if lenSepSegment <= (candidateSegments[k].length + 2)/2 {
                        strongSegments[j-1].probSum += candidateSegments[k].probSum
                        for m in (strongSegments[j-1].firstIndex+strongSegments[j-1].length)..<candidateSegments[k].firstIndex {
                            strongSegments[j-1].probSum += inputs[m].getProbabilityByMode(mode: Int64(strongSegments[j].mode))
                        }
                        strongSegments[j-1].length += candidateSegments[k].length + lenSepSegment
                    } else {
                        break
                    }
                }
            }
            
            if j == strongSegments.count - 1 {
                candidateSegments = candidatesPerStrong[-1]!
                
                for k in 0..<candidateSegments.count {
                    let lenSepSegment = candidateSegments[k].firstIndex - (strongSegments[j].firstIndex + strongSegments[j].length)
                    if lenSepSegment <= (candidateSegments[k].length + 2)/2 {
                        strongSegments[j].probSum += candidateSegments[k].probSum
                        for m in (strongSegments[j].firstIndex+strongSegments[j].length)..<candidateSegments[k].firstIndex {
                            strongSegments[j].probSum += inputs[m].getProbabilityByMode(mode: Int64(strongSegments[j].mode))
                        }
                        strongSegments[j].length += candidateSegments[k].length + lenSepSegment
                    } else {
                        break
                    }
                }
            }
        }
        return strongSegments
    }
    
    /// Separate trip into legs
    /// - Parameter inputs: classifier results
    func legSeparation(inputs: [MLInputMetadata]) -> [Segments] {
        var strongSegments = SegmentsIdentification(inputs: inputs, strongMinProb: RawDataDetection.walkingStrongMinProb, mode: Int64(Trip.modesOfTransport.walking.rawValue))
//        let lengthFilter = walkingLengthFilter //temporary value 50
        
        print("All segments:")
        for s in strongSegments {
            print("{'mode': \(s.mode), 'probSum': \(s.probSum), 'length': \(s.length), 'firstIdx': \(s.firstIndex)}")
        }
        
        strongSegments = strongSegments.filter { (segment) -> Bool in
            segment.length >= walkingLengthFilter
        }
        
        print("Strong segments:")
        for j in 0..<strongSegments.count {
            
            let segment = strongSegments[j]
            print("{'mode': \(segment.mode), 'probSum': \(segment.probSum), 'length': \(segment.length), 'firstIdx': \(segment.firstIndex)}")
            
            let segmFirstIdx = segment.firstIndex
            let segmLastIdx = segment.firstIndex + segment.length - 1
            var leftLim = -1
            
            if j == 0 {
                leftLim = 0
            } else {
              leftLim = strongSegments[j-1].firstIndex + strongSegments[j-1].length
            }
            
            var curIdx = segmFirstIdx - 1
            
            while curIdx >= leftLim {
                //Point1
                let walkingProb = inputs[curIdx].getProbabilityByMode(mode: Int64(Trip.modesOfTransport.walking.rawValue))
                if walkingProb >= RawDataDetection.walkingStrongPoint1JoinProbability  {
                    segment.firstIndex = curIdx
                    segment.length = segment.length + 1
                    segment.probSum = walkingProb + segment.probSum
                } else {
                    break
                }
                curIdx = curIdx - 1
            }
            
            var rightLim = -1
            
            if j == strongSegments.count - 1 {
                rightLim = inputs.count - 1
            } else {
                rightLim = strongSegments[j + 1].firstIndex - 1
            }
            
            curIdx = segmLastIdx + 1
            
            while curIdx <= rightLim {
                let walkingProb = inputs[curIdx].getProbabilityByMode(mode: Int64(Trip.modesOfTransport.walking.rawValue))
                if walkingProb >= RawDataDetection.walkingStrongPoint1JoinProbability  {
                    segment.length = segment.length + 1
                    segment.probSum = walkingProb + segment.probSum
                } else {
                    break
                }
                
                curIdx = curIdx + 1
            }
        }
        
        print("Strong segments after point 1):")
        for s in strongSegments {
            print("{'mode': \(s.mode), 'probSum': \(s.probSum), 'length': \(s.length), 'firstIdx': \(s.firstIndex)}")
        }
        
        var candidatesPerStrong = [Int : [Segments]]()
        
        for j in 0..<strongSegments.count {
            var first = 0
            if j == 0 {
                first = 0
            } else {
                first = strongSegments[j-1].firstIndex + strongSegments[j-1].length
            }
            
            var last = strongSegments[j].firstIndex
            var candidatesSegments = SegmentsIdentification(inputs: inputs, strongMinProb: RawDataDetection.walkingMinProbForCandidates, mode: Int64(Trip.modesOfTransport.walking.rawValue), firstIndex: first, lastIndex: last)
            candidatesPerStrong[strongSegments[j].firstIndex] = candidatesSegments
            
            if j == strongSegments.count - 1 {
                first = strongSegments[j].firstIndex + strongSegments[j].length
                last = inputs.count
                
                candidatesSegments = SegmentsIdentification(inputs: inputs, strongMinProb: RawDataDetection.walkingMinProbForCandidates, mode: Int64(Trip.modesOfTransport.walking.rawValue), firstIndex: first, lastIndex: last)
                
                candidatesPerStrong[-1] = candidatesSegments
            }
        }
        
        
        
        strongSegments = MergeCandidates(strongSegments: strongSegments, candidatesPerStrong: candidatesPerStrong, inputs: inputs)
        
        return strongSegments
    }
    
    static func timeInsegmentsNumber(seconds: Int) -> Int {
        return Int((Double(seconds) - RawDataSegmentation.getInstance().Overlap) / (RawDataSegmentation.getInstance().TimeWindow - RawDataSegmentation.getInstance().Overlap))
    }
    
    func SegmentsIdentification(inputs: [MLInputMetadata], strongMinProb: Double, mode: Int64, firstIndex: Int = 0, lastIndex: Int = -1) -> [Segments] {
        let firstIdx = firstIndex
        var lastIdx = lastIndex
        
        if lastIdx == -1 {
            lastIdx = inputs.count
        }
        
        var segments = [Segments]()
        var prevIsStrong = false
        
        for j in firstIdx..<lastIdx {
            let input = inputs[j]
            if input.getMaxProbability().1 >= strongMinProb && input.getMaxProbability().0 == mode {
                if j == 0 {
                    segments.append(Segments(mode: Int(input.getMaxProbability().0), length: 1, probSum: input.getMaxProbability().1, firstIndex: j))
                    prevIsStrong = true
                    continue
                }
                if prevIsStrong {
                    segments.last!.length = segments.last!.length + 1
                    segments.last!.probSum = segments.last!.probSum + input.getMaxProbability().1
                } else {
                    segments.append(Segments(mode: Int(input.getMaxProbability().0), length: 1, probSum: input.getMaxProbability().1, firstIndex: j))
                }
                
                prevIsStrong = true
            } else {
                prevIsStrong = false
            }
        }
        return segments
    }
    
    
}

class Segments {
    var mode: Int
    var length: Int
    var probSum: Double
    var firstIndex: Int
    
    init(mode: Int, length: Int, probSum: Double, firstIndex: Int) {
        self.mode = mode
        self.length = length
        self.probSum = probSum
        self.firstIndex = firstIndex
    }
}
