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
import Firebase

/*
* Reward Description
* var myShortDescription: short version of the description
* var longDescription: long version of the description
*/
class Description: NSManagedObject, JsonParseable {
    
    public static let MyEntityName = "Description"
    
    @NSManaged var myShortDescription: String
    @NSManaged var longDescription: String
    @NSManaged var lang: String
    
    enum CodingKeysSpec: String, CodingKey {
        case shortDescription
        case longDescription
        case lang
       
    }
    
    convenience init(lang: String, shortDescription: String, longDescription: String) {
        let context = UserInfo.context!
        let entity = NSEntityDescription.entity(forEntityName: Description.MyEntityName, in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.lang = lang
        self.myShortDescription = shortDescription
        self.longDescription = longDescription
    }
    
    
    required convenience init(from decoder: Decoder) throws {
        
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: Description.MyEntityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let shortDescription = try container.decodeIfPresent(String.self, forKey: .shortDescription),
            let longDescription = try container.decodeIfPresent(String.self, forKey: .longDescription) {
            
            self.myShortDescription = shortDescription
            self.longDescription = longDescription
            
            if let language = try container.decodeIfPresent(String.self, forKey: .lang){
                self.lang = language
            }
           
        } else {
            throw NSError(domain: "decoding Description", code: 1, userInfo: ["Container" : container])
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        
        try container.encode(self.myShortDescription, forKey: .shortDescription)
        try container.encode(self.longDescription, forKey: .longDescription)
    }
    
}


