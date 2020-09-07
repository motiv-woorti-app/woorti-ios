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
import CoreMotion

class TestDataSegmentation {
    
    var testVector = [[Double]]()
    
    init() {
        // Set the file path
        let path = "rawTestDataIos"
        
        do {
            // Get the contents
//            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//            let path = documents.appending("rawTestDataIos.txt")
//            print(path)
            
            
            var fileRoot = Bundle.main.path(forResource: path, ofType: "txt")
//            print(fileRoot ?? "")
            var contents = try NSString(contentsOfFile: fileRoot!, encoding: String.Encoding.utf8.rawValue)
//            print(contents)
            var cts = contents.replacingOccurrences(of: "[", with: "")
            cts = cts.replacingOccurrences(of: " ],", with: "")
            cts = cts.replacingOccurrences(of: "],", with: "")
            cts = cts.replacingOccurrences(of: "]", with: "")
            for cont in cts.components(separatedBy: .newlines) {
                if cont.count > 0 {
                    print(cont)
                    let line = cont.components(separatedBy: ",").map { (string) -> Double in
                        return Double(string) ?? 0
                    }
    //                print(line)
                    testVector.append(line)
                }
            }
            
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    func createSamples() {
        for line in self.testVector {
            self.createSample(line: line)
        }
        //        RawDataSegmentation.getInstance().testSincSem.wait()
        
        for input in RawDataSegmentation.getInstance().inputs {
            print("\(input.getTextToPrint())")
        }
        
        print("inputsCount: \(RawDataSegmentation.getInstance().inputs.count)")
        for leg in RawDataDetection.getInstance().TripEvaluation(inputs: RawDataSegmentation.getInstance().inputs) {
            print("\nleg values: \(leg.firstIndex) \(leg.length) \(leg.mode) \(leg.probSum) \n")
        }
        print("inputsCount: \(RawDataSegmentation.getInstance().inputs.count)")
        print("\n")
        for input in RawDataSegmentation.getInstance().inputs {
            print("\(input.getTextToPrint())")
        }
        print("\n")
    }
    
    func createSample(line: [Double]) {
        if line[0] == 0 {
            //GPS
            let coord = CLLocationCoordinate2D(latitude: line[5], longitude: line[6])
            let location = CLLocation(coordinate: coord, altitude: 0, horizontalAccuracy: line[7], verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: line[1] / 1000))
            let ul = UserLocation.getUserLocation(userLocation: location, context: UserInfo.context!)!
            
//            RawDataSegmentation.getInstance().newLocation(ua: ul)
            RawDataSegmentation.getInstance().newTestLocation(ua: ul)
        } else {
            //ACC
            let ua = UserAcceleration.getUserAcceleration(x: line[2], y: line[3], z: line[4], date: Date(timeIntervalSince1970: line[1] / 1000))
//            RawDataSegmentation.getInstance().newAcceleration(ua: ua!)
            RawDataSegmentation.getInstance().newTestAcceleration(ua: ua!)
        }
    }
}
