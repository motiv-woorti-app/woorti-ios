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


/*
 * Entity representing one notification
 */
class UserEngagementNotification: NSManagedObject {
    @NSManaged public var title: String
    @NSManaged public var text: String
    @NSManaged public var sent: Date?
    @NSManaged public var order: Double
    
    public static let entityName = "UserEngagementNotification"
    
    convenience init(title: String, text: String, order: Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: UserEngagementNotification.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        self.title = title
        self.text = text
        self.order = order
        self.sent = nil
    }
    
    public static func getUserEngagementNotification(title: String, text: String, order: Double) -> UserEngagementNotification? {
        var notification: UserEngagementNotification?
        UserInfo.ContextSemaphore.wait()
        notification = UserEngagementNotification(title: title, text: text, order: order, context: UserInfo.context!)
        UserInfo.ContextSemaphore.signal()
        return notification
    }
    
    public static func getUserEngagementNotifications() -> [UserEngagementNotification] {
        var notifications = [UserEngagementNotification]()
        notifications.append(UserEngagementNotification.getUserEngagementNotification(title: NSLocalizedString("engagement_notification_1_title", comment: ""), text: NSLocalizedString("engagement_notification_1_content", comment: ""), order: 0)!)
        notifications.append(UserEngagementNotification.getUserEngagementNotification(title: NSLocalizedString("engagement_notification_2_title", comment: ""), text: NSLocalizedString("engagement_notification_2_title", comment: ""), order: 1)!)
        
        notifications.append(UserEngagementNotification.getUserEngagementNotification(title: NSLocalizedString("engagement_notification_4_title", comment: ""), text: NSLocalizedString("engagement_notification_4_content", comment: ""), order: 2)!)
        
        notifications.append(UserEngagementNotification.getUserEngagementNotification(title: NSLocalizedString("engagement_notification_3_title", comment: ""), text: NSLocalizedString("engagement_notification_3_title", comment: ""), order: 3)!)
        
        
        notifications.append(UserEngagementNotification.getUserEngagementNotification(title: NSLocalizedString("engagement_notification_6_title", comment: ""), text: NSLocalizedString("engagement_notification_6_content", comment: ""), order: 4)!)
        
        notifications.append(UserEngagementNotification.getUserEngagementNotification(title: NSLocalizedString("engagement_notification_8_title", comment: ""), text: NSLocalizedString("engagement_notification_8_content", comment: ""), order: 5)!)
        
        notifications.append(UserEngagementNotification.getUserEngagementNotification(title: NSLocalizedString("engagement_notification_9_title", comment: ""), text: NSLocalizedString("engagement_notification_9_content", comment: ""), order: 6)!)
        return notifications
    }
    
}
