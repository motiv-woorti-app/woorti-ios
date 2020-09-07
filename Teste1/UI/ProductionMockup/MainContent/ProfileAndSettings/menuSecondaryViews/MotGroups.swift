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
import CoreData

class MotGroups: NSManagedObject {

    public static let entityName = "MotGroups"

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MotGroups> {
        return NSFetchRequest<MotGroups>(entityName: MotGroups.entityName)
    }

    @NSManaged public var motCode: Double
    @NSManaged public var mots: NSMutableSet //[Mot]
    @NSManaged public var main: Mot

    convenience init(motCode: Double, mots: NSMutableSet, main: Mot, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: MotGroups.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        self.motCode = motCode
        self.mots = mots
        self.main = main
    }
    
    func getMots() -> [Mot] {
        return self.mots.allObjects as! [Mot]
    }
    
    func setMots(mots: [Mot]) {
        self.mots = NSMutableSet(array: mots)
    }

    public static func getMotGroup(motCode: Double, mots: [Mot], main: Mot, context: NSManagedObjectContext) -> MotGroups? {
        var motGroups: MotGroups?
        UserInfo.ContextSemaphore.wait()
        context.performAndWait {
            motGroups = MotGroups(motCode: motCode, mots: NSMutableSet(array: mots), main: main, context: context)
        }
        UserInfo.ContextSemaphore.signal()
        return motGroups
    }
    
    public static func getMotFromInsideContext(motCode: Double, mots: [Mot], main: Mot, context: NSManagedObjectContext) -> MotGroups? {
        let motGroups = MotGroups(motCode: motCode, mots: NSMutableSet(array: mots), main: main, context: context)
        return motGroups
    }
    
    func incMot(mode: Double) {
        for mot in getMots() {
            if mot.motCode == mode {
                if mot.incValue() {
                    for mot in getMots() {
                        mot.divideBy()
                    }
                }
                break
            }
        }
    }
    
    func getMain() -> Mot {
        var main = self.main
        for mot in getMots() {
            if mot.countTimes > main.countTimes{
                main = mot
            }
        }
        
        return main
    }
    
    static private func getGroups() -> [MotGroups] {
        var motGroups = [MotGroups]()
        motGroups.append(getWalkingMotGroup())
        motGroups.append(getCyclingMotGroup())
        motGroups.append(getStillMotGroup())
        motGroups.append(getCarMotGroup())
        motGroups.append(getBusMotGroup())
//        motGroups.append(getTramMotGroup())
//        motGroups.append(getMetroMotGroup())
        motGroups.append(getTrainMotGroup())
        motGroups.append(getBoatMotGroup())
        motGroups.append(getPlaneMotGroup())
        
        return motGroups
    }
    
    static private func getWalkingMotGroup() -> MotGroups {
        let ctx = UserInfo.context!
        let main = Mot.getMot(text: "walking", motCode: Double(7), context: ctx)!
        let motCode = Double(7)
        
        var mots = [main]
        mots.append(Mot.getMot(text: "run", motCode: Double(8), context: ctx)!)
        
        return MotGroups.getMotGroup(motCode: motCode, mots: mots, main: main, context: ctx)!
    }
    
    static private func getCyclingMotGroup() -> MotGroups {
        let ctx = UserInfo.context!
        let main = Mot.getMot(text: "bicycle", motCode: Double(1), context: ctx)!
        let motCode = Double(1)
        
        var mots = [main]
//        mots.append(Mot.getMot(text: "Run", motCode: Double(8), context: ctx)!)
        
        return MotGroups.getMotGroup(motCode: motCode, mots: mots, main: main, context: ctx)!
    }
    
    static private func getStillMotGroup() -> MotGroups {
        let ctx = UserInfo.context!
        let main = Mot.getMot(text: "still", motCode: Double(3), context: ctx)!
        let motCode = Double(3)
        
        var mots = [main]
        //        mots.append(Mot.getMot(text: "Run", motCode: Double(8), context: ctx)!)
        
        return MotGroups.getMotGroup(motCode: motCode, mots: mots, main: main, context: ctx)!
    }
    
    static private func getCarMotGroup() -> MotGroups {
        let ctx = UserInfo.context!
        let main = Mot.getMot(text: "car", motCode: Double(9), context: ctx)!
        let motCode = Double(9)
        
        var mots = [main]
        //        mots.append(Mot.getMot(text: "Run", motCode: Double(8), context: ctx)!)
        
        return MotGroups.getMotGroup(motCode: Double(motCode), mots: mots, main: main, context: ctx)!
    }
    
    static private func getBusMotGroup() -> MotGroups {
        let ctx = UserInfo.context!
        let main = Mot.getMot(text: "bus", motCode: Double(15), context: ctx)!
        let motCode = Double(15)
        
        var mots = [main]
        //        mots.append(Mot.getMot(text: "Run", motCode: Double(8), context: ctx)!)
        
        return MotGroups.getMotGroup(motCode: Double(motCode), mots: mots, main: main, context: ctx)!
    }
    
    static private func getTramMotGroup() -> MotGroups {
        let ctx = UserInfo.context!
        let main = Mot.getMot(text: "tram", motCode: Double(11), context: ctx)!
        let motCode = Double(11)
        
        var mots = [main]
        //        mots.append(Mot.getMot(text: "Run", motCode: Double(8), context: ctx)!)
        
        return MotGroups.getMotGroup(motCode: Double(motCode), mots: mots, main: main, context: ctx)!
    }
    
    static private func getMetroMotGroup() -> MotGroups {
        let ctx = UserInfo.context!
        let main = Mot.getMot(text: "metro", motCode: Double(12), context: ctx)!
        let motCode = Double(12)
        
        var mots = [main]
        //        mots.append(Mot.getMot(text: "Run", motCode: Double(8), context: ctx)!)
        
        return MotGroups.getMotGroup(motCode: Double(motCode), mots: mots, main: main, context: ctx)!
    }
    
    static private func getTrainMotGroup() -> MotGroups {
        let ctx = UserInfo.context!
        let main = Mot.getMot(text: "train", motCode: Double(10), context: ctx)!
        let motCode = Double(10)
        
        var mots = [main]
        mots.append(Mot.getMot(text: "metro", motCode: Double(12), context: ctx)!)
        mots.append(Mot.getMot(text: "tram", motCode: Double(11), context: ctx)!)
        
        return MotGroups.getMotGroup(motCode: Double(motCode), mots: mots, main: main, context: ctx)!
    }
    
    static private func getBoatMotGroup() -> MotGroups {
        let ctx = UserInfo.context!
        let main = Mot.getMot(text: "ferry", motCode: Double(13), context: ctx)!
        let motCode = Double(13)
        
        var mots = [main]
        //        mots.append(Mot.getMot(text: "Run", motCode: Double(8), context: ctx)!)
        
        return MotGroups.getMotGroup(motCode: Double(motCode), mots: mots, main: main, context: ctx)!
    }
    
    static private func getPlaneMotGroup() -> MotGroups {
        let ctx = UserInfo.context!
        let main = Mot.getMot(text: "plane", motCode: Double(14), context: ctx)!
        let motCode = Double(14)
        
        var mots = [main]
        //        mots.append(Mot.getMot(text: "Run", motCode: Double(8), context: ctx)!)
        
        return MotGroups.getMotGroup(motCode: Double(motCode), mots: mots, main: main, context: ctx)!
    }
    
    func getMotFromCode(code: Double) -> Mot? {
        for mot in self.getMots() {
            if mot.motCode == code {
                return mot
            }
        }
        
        return nil
    }
    
    func getMotFromText(text: String) -> Mot? {
        for mot in self.getMots() {
            if mot.text == text {
                return mot
            }
        }
        
        return nil
    }

    static func UpdateGroupChange(groups: [MotGroups]?) -> [MotGroups] {
        let defaultGroups = getGroups()
        
        guard let userGroups = groups else {
            return defaultGroups
        }
        
        //get groups that are still in use
        var changingGroups = userGroups.filter { (motGroup) -> Bool in
            for Group in defaultGroups {
                if motGroup.isEqual(Group) {
                    motGroup.incorporateChangesFromMaster(group: Group)
                    
                    if !(motGroup.getMots().filter({ (mot) -> Bool in
                        
                        mot.motCode == motGroup.main.motCode
                        
                    }).count>0) {
                        motGroup.main = Group.main
                    }
                    
                    return true
                }
            }
            return false
        }
        
        //get groups that were added
        var newGroups = defaultGroups.filter { (motGroup) -> Bool in
            for group in userGroups {
                if motGroup.isEqual(group) {
                    return false
                }
            }
            return true
        }
        changingGroups.append(contentsOf: newGroups)
        return changingGroups
    }
    
    func incorporateChangesFromMaster(group: MotGroups) {
        //get mots that are still in this group
        var changingMots = self.getMots().filter { (mot) -> Bool in
            for defaultMot in group.getMots() {
                if mot.motCode == defaultMot.motCode {
                    return true
                }
            }
            return false
        }
        //get mots that were added to this group
        let defaultMots = group.getMots().filter { (mot) -> Bool in
            for defaultMot in self.getMots() {
                if mot.motCode == defaultMot.motCode {
                    return false
                }
            }
            return true
        }
        changingMots.append(contentsOf: defaultMots)
        
        self.setMots(mots: changingMots)
        
    }
    
//    override func isEqual(_ object: Any?) -> Bool {
//        guard let group = object as? MotGroups else {
//            return false
//        }
//
//        return self.motCode == group.motCode
//    }
}
