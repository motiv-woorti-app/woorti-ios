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
import Firebase
import GoogleSignIn
import CoreData
import FirebaseMessaging

/*
 * This class holds the information about the user.
 * This information was filled by the user in the onboarding/settings. 
 */
class MotivUser: NSManagedObject, JsonParseable {
    //MARK:properties
    public static let entityName = "MotivUser"
    
    
    @NSManaged var email: String
    @NSManaged var age: Double
    @NSManaged var userid: String
    @NSManaged var token: String
    
    @NSManaged var hasOnboardingInfo: Bool          // The onboarding info has been sent to server
    @NSManaged var hasOnboardingFilledInfo: Bool    // The user has gone through the onboarding process
    
    //Onboarding
    @NSManaged var prodValue: Float
    @NSManaged var relValue: Float
    @NSManaged var actValue: Float
    @NSManaged var preferedMots: NSSet  //[MotSettings]
    @NSManaged var name: String
    @NSManaged var country: String
    @NSManaged var city: String
    @NSManaged var campaigns: NSSet //[MockCampaign]
    @NSManaged var rewards: NSSet 
    @NSManaged var rewardStatus: NSSet
    @NSManaged var ageRange: String
    @NSManaged var minAge: Double
    @NSManaged var maxAge: Double
    @NSManaged var gender: String
    @NSManaged var degree: String
    @NSManaged var chosenDefaultCampaignID: String
    
    @NSManaged var workAddress: String?
    @NSManaged var homeAddress: String?
    @NSManaged var homeAddressPoint: UserLocation?
    @NSManaged var workAddressPoint: UserLocation?
    
    @NSManaged var language: String?
    @NSManaged var motPreferences: NSSet? //[MotGroups]?
    
    static var tmpPreferedMots = [MotSettings]()
    static var tmpprodValue: Float = 0
    static var tmprelValue: Float = 0
    static var tmpactValue: Float = 0
    
    @NSManaged var lessons: NSSet? //[Lesson]?
    
    @NSManaged var surveyPoints: [String: Double]
    @NSManaged var fullPoints: [String: Double]
    @NSManaged var version: Double
    
    @NSManaged var registerDate: Date
    @NSManaged var hasSetGoal: Bool
    @NSManaged var hasHasRewards: Bool
    @NSManaged var mobilityGoalChosen: Double
    @NSManaged var mobilityGoalPoints: Double
    
    @NSManaged var yearlyInfo: NSSet //worthwhileness yearly info
    @NSManaged var userNotifications: NSMutableSet? //user engagement notificaitons
    
    @NSManaged var maritalStatusHousehold: String?
    @NSManaged var humberPeopleHousehold: String?
    @NSManaged var yearsOfResidenceHousehold: String?
    @NSManaged var labourStatusHousehold: String?
    
    @NSManaged var dontShowTellUsMorePopup: Bool
    
    @NSManaged var carOwner: Bool
    @NSManaged var motorbikeOwner: Bool
    @NSManaged var subsPubTrans: Bool
    @NSManaged var subsCarShare: Bool
    @NSManaged var subsBikShare: Bool
    let serialQueue = DispatchQueue(label: "com.inescID.Motiv.SincQueue")
    let rewardSerialQueue = DispatchQueue(label: "com.inescID.Motiv.RewardSincQueue")
    
    @NSManaged var seenBateryPopup: Bool
    @NSManaged var lastSummarySent: Double
    
    enum CodingKeysSpec: String, CodingKey {
        case prodValue
        case relValue
        case actValue
        case preferedMots
        case rewards
        case rewardStatus
        case name
        case country
        case city
        case onCampaigns
        case minAge
        case maxAge
        
        case chosenDefaultCampaignID
        case gender
        case degree
        case dontShowTellUsMorePopup
        case lastSummarySent
    }
    
    static func addVariables(prodvalue: Float, relValue: Float, actValue: Float) {
        if let user = getInstance() {
            user.prodValue = prodvalue
            user.relValue = relValue
            user.actValue = actValue
        } else {
            tmpprodValue = prodvalue
            tmprelValue = relValue
            tmpactValue = actValue
        }
    }
    
    private static var user: MotivUser?
    private static var tmpUser: MotivUser?
    
    convenience init(email: String, age: Int, userId: String,token: String) {
        let context = UserInfo.context!
        
        let entity = NSEntityDescription.entity(forEntityName: MotivUser.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.email=email
        self.age=Double(age)
        self.userid=userId
        self.token=token
        self.hasOnboardingInfo = false
        self.hasOnboardingFilledInfo = false
        
        self.prodValue = -1
        self.relValue = -1
        self.actValue = -1
        self.preferedMots = NSSet(array: [MotSettings]())
        self.name = ""
        self.country = ""
        self.city = ""
        self.campaigns = NSSet(array: [MockCampaign]())
        self.rewards = NSSet(array: [Reward]())
        self.rewardStatus = NSSet(array: [RewardStatus]())
        self.ageRange = ""
        self.minAge = 0
        self.maxAge = 125
        self.gender = ""
        self.degree = ""
        self.chosenDefaultCampaignID = ""
        self.dontShowTellUsMorePopup = false
        self.lastSummarySent = 0.0
        
        self.surveyPoints = [String: Double]()
        self.fullPoints = [String: Double]()
        
        self.registerDate = Date()
        self.hasSetGoal = false
        self.hasHasRewards = false
        self.mobilityGoalChosen = -1
        self.mobilityGoalPoints = 0
        
    }
    
    func showBatteryPopup() -> Bool {
        return self.seenBateryPopup
    }
    
    func seeBateryPopup() {
        self.seenBateryPopup = true
        UserInfo.appDelegate?.saveContext()
        MotivRequestManager.getInstance().requestSaveUserSettings()
    }
    
    public func setCampaigns(newCampaigns: NSSet){
        var camps = newCampaigns.allObjects as? [MockCampaign] ?? [MockCampaign.getDefaultCampaign()]
        
        
        //HACK TO INSERT DUMMY
        var hasDummy = false
        for campaign in camps {
            if(campaign.campaignId == "dummyCampaignID"){
                hasDummy = true
               
            }
        }
        if !hasDummy {
            camps.insert(MockCampaign.getDefaultCampaign(), at: 0)
        }
        
        UserInfo.ContextSemaphore.wait()
        UserInfo.context?.perform {
            self.campaigns = NSSet(array: camps)
        }
        UserInfo.ContextSemaphore.signal()
        
    }
    
    public func getCampaigns() -> [MockCampaign] {
        var camps = [MockCampaign]()
        serialQueue.sync {
            camps = self.campaigns.allObjects as? [MockCampaign] ?? [MockCampaign.getDefaultCampaign()]
            
            //HACK TO INSERT DUMMY
            var hasDummy = false
            for campaign in camps {
                if(campaign.campaignId == "dummyCampaignID"){
                    hasDummy = true
                }
            }
            if !hasDummy {
                camps.insert(MockCampaign.getDefaultCampaign(), at: 0)
            }
            
        }
        return camps
    }
    
    
    
    public func getMainCampaign() -> MockCampaign {
        for campaign in getCampaigns(){
            if campaign.campaignId != MockCampaign.titleForDefaultCampaign {
                return campaign
            }
        }
        return getCampaigns().first!
    }
    
    public func getCampaignName(id: String) -> String {
        for campaign in getCampaigns(){
            if campaign.campaignId == id {
                return campaign.name
            }
        }
        //Default - return id
        return id
    }
    
    public func getRewardStatusById(id: String) -> RewardStatus? {
        let rewardStatuses = getRewardStatus()
        return rewardStatuses.filter({$0.rewardID == id }).first
    }
    
    public func getRewardStatus() -> [RewardStatus] {
        return rewardSerialQueue.sync {
            return rewardStatus.allObjects as? [RewardStatus] ?? [RewardStatus]()
        }
    }
    
    public func addNewRewardStatus(reward: RewardStatus){
        var statuses = getRewardStatus()
        statuses.append(reward)
        setRewardStatuses(array: statuses)
        
    }
    
    public func deleteRewardStatus(){
        for reward in rewardStatus.allObjects as? [RewardStatus] ?? [RewardStatus]() {
            self.managedObjectContext?.delete(reward)
        }
    }
    
    public func setRewardStatuses(array: [RewardStatus]) {
        rewardSerialQueue.sync {
            deleteRewardStatus()
            rewardStatus = NSSet(array: array)
        }
    }
    
    private func getAllLessonsToArray() -> [Lesson] {
        return (self.lessons?.allObjects as? [Lesson] ?? [Lesson]()).sorted(by: { (l1, l2) -> Bool in
            l1.order < l2.order
        })
    }
    
    func getPreferedMots() -> [MotSettings] {
        return preferedMots.allObjects as? [MotSettings] ?? [MotSettings]()
    }
    
    func getRewards() -> [Reward] {
        return rewardSerialQueue.sync {
            return rewards.allObjects as? [Reward] ?? [Reward]()
        }
    }
    
    func isRewardSyncNeeded() -> Bool {
        let rewardStatuses = getRewardStatus()
        
        if rewardStatuses.count == 0 {      //IF USER HAS NO REWARD STATUS, SYNC
            return true
        }
        for reward in rewardStatuses {      //IF AT LEAST ONE REWARD NOT SENT TO SERVER, SYNC
            if !reward.hasBeenSentToServer {
                return true
            }
        }
        
        return false
    }
    
    
    //lessons
    func getLessonsToshow() -> [Lesson]{
        
        
        var lessonsToReturn = getLessonsForFeed()
        
       
        
        let lessons = self.getAllLessonsToArray()
        if let last = lessonsToReturn.last {
            if let date = last.read {
                if Date() > UtilityFunctions.getDateFromDateTimeWithHourAndMinute(date: date, dayDistance: 1) {
                   
                    if let ind = lessons.index(of: last),
                        (ind + 1) < lessons.count {
                        lessonsToReturn.append(lessons[ind+1])
                    }
                } else {
                   
                    lessonsToReturn.append(Lesson.getNextDayLesson(number: lessonsToReturn.count + 1))
                }
            }
        } else if let first = lessons.first {
            lessonsToReturn.append(first)
        }
        
        return lessonsToReturn
    }
    
    func getLessonsForFeed() -> [Lesson] {
        let tless = Lesson.testLessons()
        var actualLessons : NSSet?
        
        UserInfo.ContextSemaphore.wait()
        UserInfo.context?.performAndWait {
            actualLessons = nil
            if let lessons = self.lessons {
                actualLessons = NSSet.init(set: lessons)
            }
        }
        UserInfo.ContextSemaphore.signal()
        
        
        if actualLessons == nil ||
            (actualLessons?.count ?? 0) < 1 {
            actualLessons = NSSet(array: Lesson.testLessons())
        }
        
        
        var lessons = self.getAllLessonsToArray()
        if lessons.count < tless.count {
        
            
            UserInfo.ContextSemaphore.wait()
            UserInfo.context?.performAndWait {
               self.lessons = NSSet(array: Lesson.testLessons())
            }
            UserInfo.ContextSemaphore.signal()
        }
        lessons = self.getAllLessonsToArray()
        
        lessons =  lessons.filter { (lesson) -> Bool in
            lesson.read != nil
        }
        
        
        
        return lessons
    }
    
    
    public func getMotPreferences() -> [MotGroups]? {
        var motGRoups: [MotGroups]?
        UserInfo.ContextSemaphore.wait()
        
        motGRoups = self.motPreferences?.allObjects as? [MotGroups]
        
        UserInfo.ContextSemaphore.signal()
        
        return motGRoups
    }
    
    public func setMotPreferences(preferences: [MotGroups]) {
        UserInfo.ContextSemaphore.wait()
        UserInfo.context?.performAndWait {
            self.motPreferences = NSSet(array: preferences)
        }
        UserInfo.ContextSemaphore.signal()
    }
    
    public static func getInstance() -> MotivUser? {
        if let user = self.user,
            user.language == nil {
            user.language = Languages.getSmartPhoneDefaultCode()
        }
        return self.user
    }
    
    public func getToken() -> String {
        return self.token
    }
    
    public func refreshToken() {
        let sem = DispatchSemaphore(value: 0)
        print("getIdToken in MotivUser.refreshToken")
        MotivUser.getIdToken(processToken: ProcessSendToken(false, sem))
        sem.wait()
    }
    
    
    public static func LogIn(email: String, age: Int, userId: String, token: String, tmp: Bool = false) -> MotivUser {
        print("Start LogIn Func")
        let usersReq = NSFetchRequest<NSFetchRequestResult>(entityName: MotivUser.entityName)
        var User: MotivUser? = nil
        var lessons : [Any]?
        
        UserInfo.ContextSemaphore.wait()
        UserInfo.context?.performAndWait {
            do {
                let Users = try UserInfo.context?.fetch(usersReq) as! [MotivUser]
                User = Users.filter { (user) -> Bool in
                    return user.userid == userId
                    }.first
            } catch {
                //fatalError("Failed to fetch fulltrips: \(error)")
                Crashlytics.sharedInstance().recordError(error)
            }
            
            if User != nil {
                self.user = User
                self.user!.token = token
                
            } else {
                //                UserInfo.context?.performAndWait {
                print("Could not find user")
                self.user = MotivUser(email: email, age: age, userId: userId, token: token)
                //                }
            }
            
            if tmpPreferedMots.count > 0 {
                print("Login, tmpPreferedMots")
                self.user?.preferedMots = NSSet(array: tmpPreferedMots)
                tmpPreferedMots.removeAll()
                
                self.user?.prodValue = tmpprodValue
                self.user?.relValue = tmprelValue
                self.user?.actValue = tmpactValue
                
                tmpprodValue = 0
                tmprelValue = 0
                tmpactValue = 0
            }
            
            lessons = self.user?.lessons?.allObjects
            
            
        }
        UserInfo.ContextSemaphore.signal()
        self.user?.setMotPreferences(preferences: MotGroups.UpdateGroupChange(groups: self.user?.getMotPreferences()))
        
        if lessons == nil {
            self.user?.lessons = NSSet(array: Lesson.testLessons())
        } else {
            print("Lessons Count:" + String(lessons!.count))
            self.user?.lessons = NSSet(array: Lesson.loadLessonsIfNecessary(userLessons: (lessons as? [Lesson]) ?? [Lesson]()))
            
        }
        
        
        UserInfo.setRealMots()
        UserInfo.fetchUserTrips()
        UserInfo.sendConfirmedTripsNotSentToServer()
        
        
        return self.user!
    }
    
    public func signOut(view: UIViewController?){
        print("SignOut FUNC")
        let firebaseAuth = Auth.auth()
        do {
            if GIDSignIn.sharedInstance().hasAuthInKeychain() {
                GIDSignIn.sharedInstance().signOut()
            }
            try firebaseAuth.signOut()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MainViewController.MainViewOptions.LogOut.rawValue), object: nil)
            
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        MotivUser.user = nil
        DispatchQueue.global(qos: .background).async {
            UserInfo.closeOpenedTrips()
        }
    }

  
    static func getIdToken(view: GenericSignInVC? = nil, processToken: ProcessTokenResponse) {
        DispatchQueue.global(qos: .userInteractive).async {
            if let currentUser = Auth.auth().currentUser {
                UserInfo.authenticationToken = nil
                print("start get id token")
                currentUser.getIDTokenForcingRefresh(false) { idToken, error in
                    DispatchQueue.global(qos: .userInteractive).async {
                        print("executing block")
                        if let error = error as? NSError {
                            // Handle error
                            print("error: \(error)")
                            let user = LogIn(email: currentUser.email!, age: 0, userId: currentUser.uid, token: "")
                            if user.hasOnboardingInfo {
                                print("Login error, user has onBoarding")
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SignInViewController.goToNextScreen), object: nil)
                            } else {
                                print("Login error, user doesn't have onBoarding")
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: WoortiSignInV2ViewController.callbacks.notLoggedIn.rawValue), object: nil)
                            }
                            processToken.processToken(nil)
                            //                    view?.GoToMainMenu()
                        } else if currentUser.email == nil {
                            print("Log In, currentUser.email = nil")
                            MotivUser.getInstance()?.signOut(view: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: WoortiSignInV2ViewController.callbacks.notLoggedIn.rawValue), object: nil)
                        } else if let idToken = idToken {
                            print("got token")
                            processToken.processToken(idToken)
                            let user = MotivUser.LogIn(email: currentUser.email!, age: 0, userId: currentUser.uid, token: idToken)
                            print("Sleeping for 3 seconds")
                            Thread.sleep(forTimeInterval: 3)
                            //                            if user.hasOnboardingInfo {´
                            print("Go to next screen, posting SignIn.goToNextScreen notification")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SignInViewController.goToNextScreen), object: nil)
                            
                           
                        } else {
                            print("unidentified error get id token")
                            let user = LogIn(email: currentUser.email!, age: 0, userId: currentUser.uid, token: "")
                            if user.hasOnboardingInfo {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SignInViewController.goToNextScreen), object: nil)
                            } else {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: WoortiSignInV2ViewController.callbacks.notLoggedIn.rawValue), object: nil)
                            }
                            processToken.processToken(nil)
                        }
                    }
                }
            }
            else {
                processToken.processToken(nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: WoortiSignInV2ViewController.callbacks.notLoggedInOnStart.rawValue), object: nil)
            }
        }
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: MotivUser.entityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        
        UserInfo.ContextSemaphore.signal()
        

    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        
        try container.encode(self.prodValue, forKey: .prodValue)
        try container.encode(self.relValue, forKey: .relValue)
        try container.encode(self.actValue, forKey: .actValue)
        try container.encode(self.preferedMots.allObjects as! [MotSettings], forKey: .preferedMots)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.country, forKey: .country)
        try container.encode(self.city, forKey: .city)
        try container.encode(self.campaigns.allObjects as! [MockCampaign], forKey: .onCampaigns)
        try container.encode(self.chosenDefaultCampaignID, forKey: .chosenDefaultCampaignID)
        try container.encode(self.dontShowTellUsMorePopup, forKey: .dontShowTellUsMorePopup)
        try container.encode(self.lastSummarySent, forKey: .lastSummarySent)
        try container.encode(self.rewards.allObjects as! [Reward], forKey: .rewards)
        try container.encode(self.rewardStatus.allObjects as! [RewardStatus], forKey: .rewardStatus)
        try container.encode(self.minAge, forKey: .minAge)
        try container.encode(self.maxAge, forKey: .maxAge)
        try container.encode(self.gender, forKey: .gender)
        try container.encode(self.degree, forKey: .degree)
    }
    
    /******* Secondary and main modes of transport *******/
    
    
    func getMainFromSecondary(secondaryCode: Double) -> Double {
        // Used to get the code of the main mode of transport for the Leg when the user changes the mode of transport used on that Leg
        // Used to get the realMot for a Leg from the code received by the ML process.
        // input secondary mode of transport code OR ML process mode of transport code
        // output main mode of transport code for that group
        
        for group in self.getMotPreferences() ?? [MotGroups]() {
            if group.getMotFromCode(code: secondaryCode) != nil {
                return group.getMain().motCode
            }
        }
        
        return Double(0)
    }
    
    func setSecondaryasMain(mainCode: Double) {
        // Used to change the main mode of transport out of a group of modes of transport, when the user changes a mode of transport on a Leg, that mode of transport will default to the main mode of its group.
        var groups = self.getMotPreferences() ?? [MotGroups]()
        for group in groups {
            group.incMot(mode: mainCode)
        }
        
        setMotPreferences(preferences: groups)
    }
    
    func getMotFromText(text: String) -> Mot? {
        // get mot for text
        // input text string of the mot
        // output mot object of text string
        
        for group in self.getMotPreferences() ?? [MotGroups]() {
            if let mot = group.getMotFromText(text: text) {
                return mot
            }
        }
        return nil
    }
    
    func getMotFromCode(code: Double) -> Mot? {
        // get mot for text
        // input text string of the mot
        // output mot object of text string
        
        for group in self.getMotPreferences() ?? [MotGroups]() {
            if let mot = group.getMotFromCode(code: code) {
                return mot
            }
        }
        return nil
    }
    
    // executed when answering a survey
    func answerSurvey(survey: Survey) {
        for campaign in self.getCampaigns() {
            let campaignID = campaign.getID()
            addPointsTo(campaignID: campaignID, points: survey.surveyPoints)
            if self.surveyPoints.index(forKey: campaignID) != nil {
                self.surveyPoints[campaignID] = self.surveyPoints[campaignID]! + survey.surveyPoints
            }
            self.surveyPoints[campaignID] = survey.surveyPoints
        }
    }
    
    func addPointsFromProfile(){
        for campaign in self.getCampaigns() {
            let campaignID = campaign.getID()
            addPointsTo(campaignID: campaignID, points: 25)
        }
    }
    
    func addPointsTo(campaignID: String, points: Double) {
        
        if fullPoints.index(forKey: campaignID) == nil  {
            fullPoints[campaignID] = points
        } else {
            fullPoints[campaignID] = fullPoints[campaignID]! + points
        }
        print("------Points after=" + String(fullPoints[campaignID]!))
    }
    
    func diffPoints(points: [String: Double]) {
        /*
         points.forEach { (kv) in
         print("++Iterating Key: " + kv.key)
         if self.fullPoints.index(forKey: kv.key) != nil {
         self.fullPoints[kv.key] = self.fullPoints[kv.key]! + kv.value
         }
         print("+++Final score for key:" + kv.key + ", score=" + String(kv.value))
         self.fullPoints[kv.key] = kv.value
         
         }*/
    }
    
    // get sum of survey points for a certain campaign
    func scoreForSurveys() -> Double {
        return self.surveyPoints.reduce(Double(0), { (prev, arg1) -> Double in
            let (key, value) = arg1
            return prev + value
        })
    }
    
    // get survey points for campaign
    func scoreForSurveys(campaignID: String) -> Double {
        return self.surveyPoints[campaignID] ?? Double(0)
    }
    
    //get surveys points per campaigns
    func scoreByCampaign() -> [String: Double] {
        return self.surveyPoints
    }
    
    //DTO
    // get data structure to send to server
    func getDTOUser() -> UserSchema{
        // increment the version number
        
        UserInfo.ContextSemaphore.wait()
        UserInfo.context?.performAndWait {
            self.increaseVersion()
        }
        UserInfo.ContextSemaphore.signal()
        
        //get DTO objects
        return UserSchema(user: self)
    }
    
    func increaseVersion() {
        print("Increasing local version")
        self.version += 1
    }
    
    //Solve bug with users that have the campaign name in points per campaign map
    //Make sure the id is from any campaign, else check if there is a campaign with name=id
    //If either case fails, return the given id
    public func getCampaignID(id: String) -> String {
        
        var realID = ""
        var suspectedID = ""
        
        for campaign in getCampaigns() {
            if campaign.campaignId == id {
                realID = id
            }
            if campaign.name == id {
                suspectedID = campaign.campaignId
            }
        }
        print("--- -Inside GetCampaignID with ID=" + id)
        if realID != "" {
            return id
        } else if suspectedID != "" {
            return suspectedID
        }
        
        return id
        
    }
    
    //update user from server object
    func updateUser(serverObjUser: UserSchema) {
        print("Update user from server object")
        serverObjUser.updateUser(user: self)
    }
    
    //determines if there is a need to get user from server
    func updateIfNeeded(version: Double) {
        if self.version < version {
            //get object from server
            MotivRequestManager.getInstance().getUserSettings()
        } else if self.version > version {
            //send the latest version to sever
            print("Local version higher than server, updating server")
            //MotivRequestManager.getInstance().requestSaveUserSettings()
        } else {
            //same version all is OK
        }
    }
    
    //yearlyInfo functions
    func getYearlyInfoForLastYear() -> DashInfo {
        return getYearlyInfoForSpecificYear(date: Date())
    }
    
    func getYearlyInfoForSpecificYear(date: Date) -> DashInfo {
        let year = Double(Calendar.current.component(.year, from: date))
        
        var dis = yearlyInfo.allObjects as? [DashInfo] ?? [DashInfo]()
        if !dis.contains(where: { (di) -> Bool in
            di.year == Double(Calendar.current.component(.year, from: Date()))
        }) {
            let di = DashInfo.getDashInfo(context: UserInfo.context!)
            di!.year = Double(Calendar.current.component(.year, from: Date()))
            dis.append(di!)
            yearlyInfo = NSSet(array: dis)
        }
        
        let di = dis.first!
        for diaux in dis {
            if diaux.year == year {
                return diaux
            }
        }
        return di
    }
    
    func getAllDashboardInformations() -> [DashInfo] {
        return yearlyInfo.allObjects as? [DashInfo] ?? [DashInfo]()
    }
    
    func processYearlyInfoForTrip(ft: FullTrip) {
        let DashboardInfo = getYearlyInfoForSpecificYear(date: Date())
        DashboardInfo.addInfoFromFT(ft: ft)
    }
    
    enum typeOfWorth {
        case prod, enj, fit
    }
    
    func getWorthwhilenessFor(mode: Trip.modesOfTransport, type: typeOfWorth) -> Double {
        
        return 0
    }
    
    // userNotifications
    func getSortedUserNotifications() -> [UserEngagementNotification] {
        if userNotifications == nil || userNotifications!.count < 4 {
            
            userNotifications = NSMutableSet(array: UserEngagementNotification.getUserEngagementNotifications())
        }
        
        guard var notifications = userNotifications?.allObjects as? [UserEngagementNotification] else {
            return [UserEngagementNotification]()
        }
        
        if notifications.count == 0 {
            userNotifications = NSMutableSet(array: UserEngagementNotification.getUserEngagementNotifications())
            notifications = userNotifications!.allObjects as! [UserEngagementNotification]
        }
        
        //save context so as to not get null pointers out of the main thread
        UserInfo.appDelegate?.saveContext()
        
        return notifications.sorted(by: { (e1, e2) -> Bool in
            e1.order < e2.order
        })
    }
    
    func trySendNextNotification(fromStartTrip: Bool, fromEndTrip: Bool) {
        let notifications = getSortedUserNotifications()
        UserEngagement().getValidateAndSendNextNotification(notifications: notifications, fromStartTrip: fromStartTrip, fromEndTrip: fromEndTrip)
    }
    
    func trySendNextNotificationOnStartTrip() {
        trySendNextNotification(fromStartTrip: true, fromEndTrip: false)
    }
    
    func trySendNextNotificationOnEndTrip() {
        trySendNextNotification(fromStartTrip: false, fromEndTrip: true)
    }
    
    func trySendNextNotificationFromElsewhere() {
        trySendNextNotification(fromStartTrip: false, fromEndTrip: false)
    }
    
}

class MotSettings: NSManagedObject, JsonParseable {
    public static let entityName = "MotSettings"
    
    @NSManaged var mot: Double
    @NSManaged var motText: String
    @NSManaged var motsProd: Double
    @NSManaged var motsRelax: Double
    @NSManaged var motsFit: Double
    var MotText = ""
    var Mot = 0.0
    
    enum CodingKeysSpec: String, CodingKey {
        case Mot
        case MotText
        case motsProd
        case motsRelax
        case motsFit
    }
    
    convenience init(mot: Double, motText: String) {
        let context = UserInfo.context!
        
        let entity = NSEntityDescription.entity(forEntityName: MotSettings.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        
        self.mot = mot
        self.motText = motText
        self.motsProd = -1
        self.motsRelax = -1
        self.motsFit = -1
    }
    
    static func getmotSettings(mot: Int, motText: String) -> MotSettings {
        let context = UserInfo.context!
        var settings: MotSettings? = nil
        UserInfo.ContextSemaphore.wait()
        context.performAndWait {
            settings = MotSettings(mot: Double(mot), motText: motText)
        }
        return settings!
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: MotSettings.entityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let motText = try container.decodeIfPresent(String.self, forKey: .MotText),
            let mot = try container.decodeIfPresent(Double.self, forKey: .Mot),
             let motsProd = try container.decodeIfPresent(Double.self, forKey: .motsProd),
             let motsRelax = try container.decodeIfPresent(Double.self, forKey: .motsRelax),
             let motsFit = try container.decodeIfPresent(Double.self, forKey: .motsFit) {
            
            print("DECODING MOTS: " + motText)
            
                self.motText = motText
                self.mot = mot
                self.motsProd = motsProd
                self.motsFit = motsFit
                self.motsRelax = motsRelax
            }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        
        try container.encode(self.mot, forKey: .Mot)
        try container.encode(self.motText, forKey: .MotText)
        try container.encode(self.motsProd, forKey: .motsProd)
        try container.encode(self.motsRelax, forKey: .motsRelax)
        try container.encode(self.motsFit, forKey: .motsFit) 
    }
}

class Languages {
    var smartphoneID: String
    var woortiID: String
    var name: String
    
    private init(smartphoneID: String, woortiID: String, name: String){
        self.smartphoneID = smartphoneID
        self.woortiID = woortiID
        self.name = name
    }
    
    static func getLanguages() -> [Languages] {
        var langs = [Languages]()
        langs.append(Languages(smartphoneID: "en", woortiID: "eng", name: "English"))
        langs.append(Languages(smartphoneID: "pt", woortiID: "por", name: "Portuguese"))
        langs.append(Languages(smartphoneID: "es", woortiID: "esp", name: "Spanish"))
        langs.append(Languages(smartphoneID: "ca-ES", woortiID: "cat", name: "Catalan"))
        langs.append(Languages(smartphoneID: "fi", woortiID: "fin", name: "Finish"))
        langs.append(Languages(smartphoneID: "de", woortiID: "ger", name: "Germany"))
        
        //Croatian
        langs.append(Languages(smartphoneID: "hr", woortiID: "hrv", name: "Croatian"))
        //Dutch
        langs.append(Languages(smartphoneID: "nl", woortiID: "dut", name: "Dutch"))
        //French
        langs.append(Languages(smartphoneID: "fr", woortiID: "fre", name: "French"))
        //Italian
        langs.append(Languages(smartphoneID: "it", woortiID: "ita", name: "Italian"))
        //Norwegian
        langs.append(Languages(smartphoneID: "nb", woortiID: "nob", name: "Norwegian"))
        //Slovak
        langs.append(Languages(smartphoneID: "sk", woortiID: "slo", name: "Slovak"))
        
        return langs
    }
    
    static func getOtherCountries() -> [Languages] {
        var langs = [Languages]()
        langs.append(Languages(smartphoneID: "AF",  woortiID: "AFG", name: "Afghanistan"))
        langs.append(Languages(smartphoneID: "AL",  woortiID: "ALB", name: "Albania"))
        langs.append(Languages(smartphoneID: "DZ",  woortiID: "DZA", name: "Algeria"))
        langs.append(Languages(smartphoneID: "AS",  woortiID: "ASM", name: "American Samoa"))
        langs.append(Languages(smartphoneID: "AD",  woortiID: "AND", name: "Andorra"))
        langs.append(Languages(smartphoneID: "AO",  woortiID: "AGO", name: "Angola"))
        langs.append(Languages(smartphoneID: "AI",  woortiID: "AIA", name: "Anguilla"))
        langs.append(Languages(smartphoneID: "AQ",  woortiID: "ATA", name: "Antarctica"))
        langs.append(Languages(smartphoneID: "AG",  woortiID: "ATG", name: "Antigua and Barbuda"))
        langs.append(Languages(smartphoneID: "AR",  woortiID: "ARG", name: "Argentina"))
        langs.append(Languages(smartphoneID: "AM",  woortiID: "ARM", name: "Armenia"))
        langs.append(Languages(smartphoneID: "AW",  woortiID: "ABW", name: "Aruba"))
        langs.append(Languages(smartphoneID: "AU",  woortiID: "AUS", name: "Australia"))
        langs.append(Languages(smartphoneID: "AT",  woortiID: "AUT", name: "Austria"))
        langs.append(Languages(smartphoneID: "AZ",  woortiID: "AZE", name: "Azerbaijan"))
        langs.append(Languages(smartphoneID: "BS",  woortiID: "BHS", name: "Bahamas"))
        langs.append(Languages(smartphoneID: "BH",  woortiID: "BHR", name: "Bahrain"))
        langs.append(Languages(smartphoneID: "BD",  woortiID: "BGD", name: "Bangladesh"))
        langs.append(Languages(smartphoneID: "BB",  woortiID: "BRB", name: "Barbados"))
        langs.append(Languages(smartphoneID: "BY",  woortiID: "BLR", name: "Belarus"))
        langs.append(Languages(smartphoneID: "BE",  woortiID: "BEL", name: "Belgique/België/Belgien"))
        langs.append(Languages(smartphoneID: "BZ",  woortiID: "BLZ", name: "Belize"))
        langs.append(Languages(smartphoneID: "BJ",  woortiID: "BEN", name: "Benin"))
        langs.append(Languages(smartphoneID: "BM",  woortiID: "BMU", name: "Bermuda"))
        langs.append(Languages(smartphoneID: "BT",  woortiID: "BTN", name: "Bhutan"))
        langs.append(Languages(smartphoneID: "BO",  woortiID: "BOL", name: "Bolivia"))
        langs.append(Languages(smartphoneID: "BQ",  woortiID: "BES", name: "Bonaire, Sint Eustatius and Saba"))
        langs.append(Languages(smartphoneID: "BA",  woortiID: "BIH", name: "Bosnia and Herzegovina"))
        langs.append(Languages(smartphoneID: "BW",  woortiID: "BWA", name: "Botswana"))
        langs.append(Languages(smartphoneID: "BV",  woortiID: "BVT", name: "Bouvet Island"))
        langs.append(Languages(smartphoneID: "BR",  woortiID: "BRA", name: "Brazil"))
        langs.append(Languages(smartphoneID: "IO",  woortiID: "IOT", name: "British Indian Ocean Territory"))
        langs.append(Languages(smartphoneID: "VG",  woortiID: "VGB", name: "British Virgin Islands"))
        langs.append(Languages(smartphoneID: "BN",  woortiID: "BRN", name: "Brunei"))
        langs.append(Languages(smartphoneID: "BG",  woortiID: "BGR", name: "Bulgaria"))
        langs.append(Languages(smartphoneID: "BF",  woortiID: "BFA", name: "Burkina Faso"))
        langs.append(Languages(smartphoneID: "BI",  woortiID: "BDI", name: "Burundi"))
        langs.append(Languages(smartphoneID: "KH",  woortiID: "KHM", name: "Cambodia"))
        langs.append(Languages(smartphoneID: "CM",  woortiID: "CMR", name: "Cameroon"))
        langs.append(Languages(smartphoneID: "CA",  woortiID: "CAN", name: "Canada"))
        langs.append(Languages(smartphoneID: "CV",  woortiID: "CPV", name: "Cape Verde"))
        langs.append(Languages(smartphoneID: "KY",  woortiID: "CYM", name: "Cayman Islands"))
        langs.append(Languages(smartphoneID: "CF",  woortiID: "CAF", name: "Central African Republic"))
        langs.append(Languages(smartphoneID: "TD",  woortiID: "TCD", name: "Chad"))
        langs.append(Languages(smartphoneID: "CL",  woortiID: "CHL", name: "Chile"))
        langs.append(Languages(smartphoneID: "CN",  woortiID: "CHN", name: "China"))
        langs.append(Languages(smartphoneID: "CX",  woortiID: "CXR", name: "Christmas Island"))
        langs.append(Languages(smartphoneID: "CC",  woortiID: "CCK", name: "Cocos Islands"))
        langs.append(Languages(smartphoneID: "CO",  woortiID: "COL", name: "Colombia"))
        langs.append(Languages(smartphoneID: "KM",  woortiID: "COM", name: "Comoros"))
        langs.append(Languages(smartphoneID: "CG",  woortiID: "COG", name: "Congo"))
        langs.append(Languages(smartphoneID: "CK",  woortiID: "COK", name: "Cook Islands"))
        langs.append(Languages(smartphoneID: "CR",  woortiID: "CRI", name: "Costa Rica"))
        langs.append(Languages(smartphoneID: "HR",  woortiID: "HRV", name: "Hrvatska"))
        langs.append(Languages(smartphoneID: "CU",  woortiID: "CUB", name: "Cuba"))
        langs.append(Languages(smartphoneID: "CW",  woortiID: "CUW", name: "Curaçao"))
        langs.append(Languages(smartphoneID: "CY",  woortiID: "CYP", name: "Cyprus"))
        langs.append(Languages(smartphoneID: "CZ",  woortiID: "CZE", name: "Czech Republic"))
        langs.append(Languages(smartphoneID: "CI",  woortiID: "CIV", name: "Côte d'Ivoire"))
        langs.append(Languages(smartphoneID: "DK",  woortiID: "DNK", name: "Denmark"))
        langs.append(Languages(smartphoneID: "DJ",  woortiID: "DJI", name: "Djibouti"))
        langs.append(Languages(smartphoneID: "DM",  woortiID: "DMA", name: "Dominica"))
        langs.append(Languages(smartphoneID: "DO",  woortiID: "DOM", name: "Dominican Republic"))
        langs.append(Languages(smartphoneID: "EC",  woortiID: "ECU", name: "Ecuador"))
        langs.append(Languages(smartphoneID: "EG",  woortiID: "EGY", name: "Egypt"))
        langs.append(Languages(smartphoneID: "SV",  woortiID: "SLV", name: "El Salvador"))
        langs.append(Languages(smartphoneID: "GQ",  woortiID: "GNQ", name: "Equatorial Guinea"))
        langs.append(Languages(smartphoneID: "ER",  woortiID: "ERI", name: "Eritrea"))
        langs.append(Languages(smartphoneID: "EE",  woortiID: "EST", name: "Estonia"))
        langs.append(Languages(smartphoneID: "ET",  woortiID: "ETH", name: "Ethiopia"))
        langs.append(Languages(smartphoneID: "FK",  woortiID: "FLK", name: "Falkland Islands"))
        langs.append(Languages(smartphoneID: "FO",  woortiID: "FRO", name: "Faroe Islands"))
        langs.append(Languages(smartphoneID: "FJ",  woortiID: "FJI", name: "Fiji"))
        langs.append(Languages(smartphoneID: "FI",  woortiID: "FIN", name: "Suomi"))
        langs.append(Languages(smartphoneID: "FR",  woortiID: "FRA", name: "France"))
        langs.append(Languages(smartphoneID: "GF",  woortiID: "GUF", name: "French Guiana"))
        langs.append(Languages(smartphoneID: "PF",  woortiID: "PYF", name: "French Polynesia"))
        langs.append(Languages(smartphoneID: "TF",  woortiID: "ATF", name: "French Southern Territories"))
        langs.append(Languages(smartphoneID: "GA",  woortiID: "GAB", name: "Gabon"))
        langs.append(Languages(smartphoneID: "GM",  woortiID: "GMB", name: "Gambia"))
        langs.append(Languages(smartphoneID: "GE",  woortiID: "GEO", name: "Georgia"))
        langs.append(Languages(smartphoneID: "DE",  woortiID: "DEU", name: "Germany"))
        langs.append(Languages(smartphoneID: "GH",  woortiID: "GHA", name: "Ghana"))
        langs.append(Languages(smartphoneID: "GI",  woortiID: "GIB", name: "Gibraltar"))
        langs.append(Languages(smartphoneID: "GR",  woortiID: "GRC", name: "Greece"))
        langs.append(Languages(smartphoneID: "GL",  woortiID: "GRL", name: "Greenland"))
        langs.append(Languages(smartphoneID: "GD",  woortiID: "GRD", name: "Grenada"))
        langs.append(Languages(smartphoneID: "GP",  woortiID: "GLP", name: "Guadeloupe"))
        langs.append(Languages(smartphoneID: "GU",  woortiID: "GUM", name: "Guam"))
        langs.append(Languages(smartphoneID: "GT",  woortiID: "GTM", name: "Guatemala"))
        langs.append(Languages(smartphoneID: "GG",  woortiID: "GGY", name: "Guernsey"))
        langs.append(Languages(smartphoneID: "GN",  woortiID: "GIN", name: "Guinea"))
        langs.append(Languages(smartphoneID: "GW",  woortiID: "GNB", name: "Guinea-Bissau"))
        langs.append(Languages(smartphoneID: "GY",  woortiID: "GUY", name: "Guyana"))
        langs.append(Languages(smartphoneID: "HT",  woortiID: "HTI", name: "Haiti"))
        langs.append(Languages(smartphoneID: "HM",  woortiID: "HMD", name: "Heard Island And McDonald Islands"))
        langs.append(Languages(smartphoneID: "HN",  woortiID: "HND", name: "Honduras"))
        langs.append(Languages(smartphoneID: "HK",  woortiID: "HKG", name: "Hong Kong"))
        langs.append(Languages(smartphoneID: "HU",  woortiID: "HUN", name: "Hungary"))
        langs.append(Languages(smartphoneID: "IS",  woortiID: "ISL", name: "Iceland"))
        langs.append(Languages(smartphoneID: "IN",  woortiID: "IND", name: "India"))
        langs.append(Languages(smartphoneID: "ID",  woortiID: "IDN", name: "Indonesia"))
        langs.append(Languages(smartphoneID: "IR",  woortiID: "IRN", name: "Iran"))
        langs.append(Languages(smartphoneID: "IQ",  woortiID: "IRQ", name: "Iraq"))
        langs.append(Languages(smartphoneID: "IE",  woortiID: "IRL", name: "Ireland"))
        langs.append(Languages(smartphoneID: "IM",  woortiID: "IMN", name: "Isle Of Man"))
        langs.append(Languages(smartphoneID: "IL",  woortiID: "ISR", name: "Israel"))
        langs.append(Languages(smartphoneID: "IT",  woortiID: "ITA", name: "Italia"))
        langs.append(Languages(smartphoneID: "JM",  woortiID: "JAM", name: "Jamaica"))
        langs.append(Languages(smartphoneID: "JP",  woortiID: "JPN", name: "Japan"))
        langs.append(Languages(smartphoneID: "JE",  woortiID: "JEY", name: "Jersey"))
        langs.append(Languages(smartphoneID: "JO",  woortiID: "JOR", name: "Jordan"))
        langs.append(Languages(smartphoneID: "KZ",  woortiID: "KAZ", name: "Kazakhstan"))
        langs.append(Languages(smartphoneID: "KE",  woortiID: "KEN", name: "Kenya"))
        langs.append(Languages(smartphoneID: "KI",  woortiID: "KIR", name: "Kiribati"))
        langs.append(Languages(smartphoneID: "KW",  woortiID: "KWT", name: "Kuwait"))
        langs.append(Languages(smartphoneID: "KG",  woortiID: "KGZ", name: "Kyrgyzstan"))
        langs.append(Languages(smartphoneID: "LA",  woortiID: "LAO", name: "Laos"))
        langs.append(Languages(smartphoneID: "LV",  woortiID: "LVA", name: "Latvia"))
        langs.append(Languages(smartphoneID: "LB",  woortiID: "LBN", name: "Lebanon"))
        langs.append(Languages(smartphoneID: "LS",  woortiID: "LSO", name: "Lesotho"))
        langs.append(Languages(smartphoneID: "LR",  woortiID: "LBR", name: "Liberia"))
        langs.append(Languages(smartphoneID: "LY",  woortiID: "LBY", name: "Libya"))
        langs.append(Languages(smartphoneID: "LI",  woortiID: "LIE", name: "Liechtenstein"))
        langs.append(Languages(smartphoneID: "LT",  woortiID: "LTU", name: "Lithuania"))
        langs.append(Languages(smartphoneID: "LU",  woortiID: "LUX", name: "Luxembourg"))
        langs.append(Languages(smartphoneID: "MO",  woortiID: "MAC", name: "Macao"))
        langs.append(Languages(smartphoneID: "MK",  woortiID: "MKD", name: "Macedonia"))
        langs.append(Languages(smartphoneID: "MG",  woortiID: "MDG", name: "Madagascar"))
        langs.append(Languages(smartphoneID: "MW",  woortiID: "MWI", name: "Malawi"))
        langs.append(Languages(smartphoneID: "MY",  woortiID: "MYS", name: "Malaysia"))
        langs.append(Languages(smartphoneID: "MV",  woortiID: "MDV", name: "Maldives"))
        langs.append(Languages(smartphoneID: "ML",  woortiID: "MLI", name: "Mali"))
        langs.append(Languages(smartphoneID: "MT",  woortiID: "MLT", name: "Malta"))
        langs.append(Languages(smartphoneID: "MH",  woortiID: "MHL", name: "Marshall Islands"))
        langs.append(Languages(smartphoneID: "MQ",  woortiID: "MTQ", name: "Martinique"))
        langs.append(Languages(smartphoneID: "MR",  woortiID: "MRT", name: "Mauritania"))
        langs.append(Languages(smartphoneID: "MU",  woortiID: "MUS", name: "Mauritius"))
        langs.append(Languages(smartphoneID: "YT",  woortiID: "MYT", name: "Mayotte"))
        langs.append(Languages(smartphoneID: "MX",  woortiID: "MEX", name: "Mexico"))
        langs.append(Languages(smartphoneID: "FM",  woortiID: "FSM", name: "Micronesia"))
        langs.append(Languages(smartphoneID: "MD",  woortiID: "MDA", name: "Moldova"))
        langs.append(Languages(smartphoneID: "MC",  woortiID: "MCO", name: "Monaco"))
        langs.append(Languages(smartphoneID: "MN",  woortiID: "MNG", name: "Mongolia"))
        langs.append(Languages(smartphoneID: "ME",  woortiID: "MNE", name: "Montenegro"))
        langs.append(Languages(smartphoneID: "MS",  woortiID: "MSR", name: "Montserrat"))
        langs.append(Languages(smartphoneID: "MA",  woortiID: "MAR", name: "Morocco"))
        langs.append(Languages(smartphoneID: "MZ",  woortiID: "MOZ", name: "Mozambique"))
        langs.append(Languages(smartphoneID: "MM",  woortiID: "MMR", name: "Myanmar"))
        langs.append(Languages(smartphoneID: "NA",  woortiID: "NAM", name: "Namibia"))
        langs.append(Languages(smartphoneID: "NR",  woortiID: "NRU", name: "Nauru"))
        langs.append(Languages(smartphoneID: "NP",  woortiID: "NPL", name: "Nepal"))
        langs.append(Languages(smartphoneID: "NL",  woortiID: "NLD", name: "Netherlands"))
        langs.append(Languages(smartphoneID: "AN",  woortiID: "ANT", name: "Netherlands Antilles"))
        langs.append(Languages(smartphoneID: "NC",  woortiID: "NCL", name: "New Caledonia"))
        langs.append(Languages(smartphoneID: "NZ",  woortiID: "NZL", name: "New Zealand"))
        langs.append(Languages(smartphoneID: "NI",  woortiID: "NIC", name: "Nicaragua"))
        langs.append(Languages(smartphoneID: "NE",  woortiID: "NER", name: "Niger"))
        langs.append(Languages(smartphoneID: "NG",  woortiID: "NGA", name: "Nigeria"))
        langs.append(Languages(smartphoneID: "NU",  woortiID: "NIU", name: "Niue"))
        langs.append(Languages(smartphoneID: "NF",  woortiID: "NFK", name: "Norfolk Island"))
        langs.append(Languages(smartphoneID: "KP",  woortiID: "PRK", name: "North Korea"))
        langs.append(Languages(smartphoneID: "MP",  woortiID: "MNP", name: "Northern Mariana Islands"))
        langs.append(Languages(smartphoneID: "NO",  woortiID: "NOR", name: "Norge"))
        langs.append(Languages(smartphoneID: "OM",  woortiID: "OMN", name: "Oman"))
        langs.append(Languages(smartphoneID: "PK",  woortiID: "PAK", name: "Pakistan"))
        langs.append(Languages(smartphoneID: "PW",  woortiID: "PLW", name: "Palau"))
        langs.append(Languages(smartphoneID: "PS",  woortiID: "PSE", name: "Palestine"))
        langs.append(Languages(smartphoneID: "PA",  woortiID: "PAN", name: "Panama"))
        langs.append(Languages(smartphoneID: "PG",  woortiID: "PNG", name: "Papua New Guinea"))
        langs.append(Languages(smartphoneID: "PY",  woortiID: "PRY", name: "Paraguay"))
        langs.append(Languages(smartphoneID: "PE",  woortiID: "PER", name: "Peru"))
        langs.append(Languages(smartphoneID: "PH",  woortiID: "PHL", name: "Philippines"))
        langs.append(Languages(smartphoneID: "PN",  woortiID: "PCN", name: "Pitcairn"))
        langs.append(Languages(smartphoneID: "PL",  woortiID: "POL", name: "Poland"))
        langs.append(Languages(smartphoneID: "PT",  woortiID: "PRT", name: "Portugal"))
        langs.append(Languages(smartphoneID: "PR",  woortiID: "PRI", name: "Puerto Rico"))
        langs.append(Languages(smartphoneID: "QA",  woortiID: "QAT", name: "Qatar"))
        langs.append(Languages(smartphoneID: "RE",  woortiID: "REU", name: "Reunion"))
        langs.append(Languages(smartphoneID: "RO",  woortiID: "ROU", name: "Romania"))
        langs.append(Languages(smartphoneID: "RU",  woortiID: "RUS", name: "Russia"))
        langs.append(Languages(smartphoneID: "RW",  woortiID: "RWA", name: "Rwanda"))
        langs.append(Languages(smartphoneID: "BL",  woortiID: "BLM", name: "Saint Barthélemy"))
        langs.append(Languages(smartphoneID: "SH",  woortiID: "SHN", name: "Saint Helena"))
        langs.append(Languages(smartphoneID: "KN",  woortiID: "KNA", name: "Saint Kitts And Nevis"))
        langs.append(Languages(smartphoneID: "LC",  woortiID: "LCA", name: "Saint Lucia"))
        langs.append(Languages(smartphoneID: "MF",  woortiID: "MAF", name: "Saint Martin"))
        langs.append(Languages(smartphoneID: "PM",  woortiID: "SPM", name: "Saint Pierre And Miquelon"))
        langs.append(Languages(smartphoneID: "VC",  woortiID: "VCT", name: "Saint Vincent And The Grenadines"))
        langs.append(Languages(smartphoneID: "WS",  woortiID: "WSM", name: "Samoa"))
        langs.append(Languages(smartphoneID: "SM",  woortiID: "SMR", name: "San Marino"))
        langs.append(Languages(smartphoneID: "ST",  woortiID: "STP", name: "Sao Tome And Principe"))
        langs.append(Languages(smartphoneID: "SA",  woortiID: "SAU", name: "Saudi Arabia"))
        langs.append(Languages(smartphoneID: "SN",  woortiID: "SEN", name: "Senegal"))
        langs.append(Languages(smartphoneID: "RS",  woortiID: "SRB", name: "Serbia"))
        langs.append(Languages(smartphoneID: "SC",  woortiID: "SYC", name: "Seychelles"))
        langs.append(Languages(smartphoneID: "SL",  woortiID: "SLE", name: "Sierra Leone"))
        langs.append(Languages(smartphoneID: "SG",  woortiID: "SGP", name: "Singapore"))
        langs.append(Languages(smartphoneID: "SX",  woortiID: "SXM", name: "Sint Maarten (Dutch part)"))
        langs.append(Languages(smartphoneID: "SK",  woortiID: "SVK", name: "Slovakia"))
        langs.append(Languages(smartphoneID: "SI",  woortiID: "SVN", name: "Slovenia"))
        langs.append(Languages(smartphoneID: "SB",  woortiID: "SLB", name: "Solomon Islands"))
        langs.append(Languages(smartphoneID: "SO",  woortiID: "SOM", name: "Somalia"))
        langs.append(Languages(smartphoneID: "ZA",  woortiID: "ZAF", name: "South Africa"))
        langs.append(Languages(smartphoneID: "GS",  woortiID: "SGS", name: "South Georgia And The South Sandwich Islands"))
        langs.append(Languages(smartphoneID: "KR",  woortiID: "KOR", name: "South Korea"))
        langs.append(Languages(smartphoneID: "SS",  woortiID: "SSD", name: "South Sudan"))
        langs.append(Languages(smartphoneID: "ES",  woortiID: "ESP", name: "España"))
        langs.append(Languages(smartphoneID: "LK",  woortiID: "LKA", name: "Sri Lanka"))
        langs.append(Languages(smartphoneID: "SD",  woortiID: "SDN", name: "Sudan"))
        langs.append(Languages(smartphoneID: "SR",  woortiID: "SUR", name: "Suriname"))
        langs.append(Languages(smartphoneID: "SJ",  woortiID: "SJM", name: "Svalbard And Jan Mayen"))
        langs.append(Languages(smartphoneID: "SZ",  woortiID: "SWZ", name: "Swaziland"))
        langs.append(Languages(smartphoneID: "SE",  woortiID: "SWE", name: "Sweden"))
        langs.append(Languages(smartphoneID: "CH",  woortiID: "CHE", name: "Suisse/Svizzera/Schweiz"))
        langs.append(Languages(smartphoneID: "SY",  woortiID: "SYR", name: "Syria"))
        langs.append(Languages(smartphoneID: "TW",  woortiID: "TWN", name: "Taiwan"))
        langs.append(Languages(smartphoneID: "TJ",  woortiID: "TJK", name: "Tajikistan"))
        langs.append(Languages(smartphoneID: "TZ",  woortiID: "TZA", name: "Tanzania"))
        langs.append(Languages(smartphoneID: "TH",  woortiID: "THA", name: "Thailand"))
        langs.append(Languages(smartphoneID: "CD",  woortiID: "COD", name: "The Democratic Republic Of Congo"))
        langs.append(Languages(smartphoneID: "TL",  woortiID: "TLS", name: "Timor-Leste"))
        langs.append(Languages(smartphoneID: "TG",  woortiID: "TGO", name: "Togo"))
        langs.append(Languages(smartphoneID: "TK",  woortiID: "TKL", name: "Tokelau"))
        langs.append(Languages(smartphoneID: "TO",  woortiID: "TON", name: "Tonga"))
        langs.append(Languages(smartphoneID: "TT",  woortiID: "TTO", name: "Trinidad and Tobago"))
        langs.append(Languages(smartphoneID: "TN",  woortiID: "TUN", name: "Tunisia"))
        langs.append(Languages(smartphoneID: "TR",  woortiID: "TUR", name: "Turkey"))
        langs.append(Languages(smartphoneID: "TM",  woortiID: "TKM", name: "Turkmenistan"))
        langs.append(Languages(smartphoneID: "TC",  woortiID: "TCA", name: "Turks And Caicos Islands"))
        langs.append(Languages(smartphoneID: "TV",  woortiID: "TUV", name: "Tuvalu"))
        langs.append(Languages(smartphoneID: "VI",  woortiID: "VIR", name: "U.S. Virgin Islands"))
        langs.append(Languages(smartphoneID: "UG",  woortiID: "UGA", name: "Uganda"))
        langs.append(Languages(smartphoneID: "UA",  woortiID: "UKR", name: "Ukraine"))
        langs.append(Languages(smartphoneID: "AE",  woortiID: "ARE", name: "United Arab Emirates"))
        langs.append(Languages(smartphoneID: "GB",  woortiID: "GBR", name: "United Kingdom"))
        langs.append(Languages(smartphoneID: "US",  woortiID: "USA", name: "United States"))
        langs.append(Languages(smartphoneID: "UM",  woortiID: "UMI", name: "United States Minor Outlying Islands"))
        langs.append(Languages(smartphoneID: "UY",  woortiID: "URY", name: "Uruguay"))
        langs.append(Languages(smartphoneID: "UZ",  woortiID: "UZB", name: "Uzbekistan"))
        langs.append(Languages(smartphoneID: "VU",  woortiID: "VUT", name: "Vanuatu"))
        langs.append(Languages(smartphoneID: "VA",  woortiID: "VAT", name: "Vatican"))
        langs.append(Languages(smartphoneID: "VE",  woortiID: "VEN", name: "Venezuela"))
        langs.append(Languages(smartphoneID: "VN",  woortiID: "VNM", name: "Vietnam"))
        langs.append(Languages(smartphoneID: "WF",  woortiID: "WLF", name: "Wallis And Futuna"))
        langs.append(Languages(smartphoneID: "EH",  woortiID: "ESH", name: "Western Sahara"))
        langs.append(Languages(smartphoneID: "YE",  woortiID: "YEM", name: "Yemen"))
        langs.append(Languages(smartphoneID: "ZM",  woortiID: "ZMB", name: "Zambia"))
        langs.append(Languages(smartphoneID: "ZW",  woortiID: "ZWE", name: "Zimbabwe"))
        langs.append(Languages(smartphoneID: "AX",  woortiID: "ALA", name: "Åland Islands"))
        return langs
    }
    
    static func getSmartPhoneDefaultCode() -> String {
        return Locale.preferredLanguages.first ?? getLanguages().first!.smartphoneID
    }
    
    static func getLanguageForWoortiCode(woortiID: String) -> Languages? {
        let langs = getLanguages()
        for lang in langs {
            if lang.woortiID == woortiID {
                return lang
            }
        }
        return nil
    }
    
    static func getLanguageForSMCode(smartphoneID: String) -> Languages? {
        let langs = getLanguages()
        for lang in langs {
            if lang.smartphoneID == smartphoneID {
                return lang
            }
        }
        return nil
    }
    
    static func getCountriesForWoortiCode(woortiID: String) -> Languages? {
        let langs = getOtherCountries()
        for lang in langs {
            if lang.woortiID == woortiID {
                return lang
            }
        }
        return nil
    }
    
    static func getCountriesForCountry(country: String) -> Languages? {
        let langs = getOtherCountries()
        for lang in langs {
            if lang.name == country {
                return lang
            }
        }
        return nil
    }
}

//data transfer objects
struct UserSchema: JsonParseable {
    let userid: String
    let email: String
    let pushNotificationToken: String
    var onCampaigns: [String]
    var userSettings: UserSettings
    
    init(user: MotivUser) {
        self.userid = user.userid
        self.email = user.email
        
        self.pushNotificationToken = Messaging.messaging().fcmToken ?? ""
        
        self.onCampaigns = (user.getCampaigns() as! [MockCampaign]).map({ (campaign) -> String in
            return campaign.campaignId
        })
        
        self.onCampaigns = self.onCampaigns.filter( {$0 != ""})
        
        print("onCampaigns Count \(onCampaigns.count)")
        for campaign in onCampaigns {
            print("-ONCAMPAIGN=" + campaign)
        }
        
        var campaignIDS = [String]()
        for campaignID in self.onCampaigns {
            if campaignID != "dummyCampaignID" && campaignID != "" {
                campaignIDS.append(campaignID)
            }
        }
        self.onCampaigns = campaignIDS
        
        UserInfo.ContextSemaphore.wait()
        self.userSettings = UserSettings(user: user)
        UserInfo.ContextSemaphore.signal()
        
        
    }
    
    func updateUser(user: MotivUser) {
        user.userid = self.userid
        user.email = self.email
        
        
        self.userSettings.updateUser(user: user)
        user.hasOnboardingFilledInfo = true
        user.hasOnboardingInfo = true
    }
}

struct UserSettings: JsonParseable {
    let version: Double
    let prodValue: Float
    let relValue: Float
    let actValue: Float
    let name: String
    let country: String
    let city: String
    let minAge: Double
    let maxAge: Double
    let gender: String
    let degree: String
    let chosenDefaultCampaignID: String?
    let dontShowTellUsMorePopup: Bool?
    let lastSummarySent: Double?
    let preferedMots: [MotSettings]
    
    var maritalStatusHousehold: String?
    var numberPeopleHousehold: String?
    var yearsOfResidenceHousehold: String?
    var labourStatusHousehold: String?
    
    let seenBateryPopup: Bool?
    
    //added
    let stories: [StoryStateful]
    let hasSetMobilityGoal: Bool?
    let mobilityGoalChosen: Int?
    let mobilityGoalPoints: Int?
    let pointsPerCampaign: [CampaignScore]
    let lang: String?
    
    var homeAddress : HomeWorkAddress?
    var workAddress : HomeWorkAddress?
    
    init(user: MotivUser) {
        print("Init User Settings")
        
        self.version = user.version
        self.prodValue = user.prodValue
        self.relValue = user.relValue
        self.actValue = user.actValue
        self.name = user.name
        if let country = Languages.getCountriesForCountry(country: user.country) {
            user.country = country.smartphoneID
        }
        self.country = user.country
        self.city = user.city
        self.minAge = user.minAge
        self.maxAge = user.maxAge
        self.gender = user.gender
        self.degree = user.degree
        self.preferedMots = (user.preferedMots.allObjects as! [MotSettings])
        
        //added
        self.stories = (user.lessons?.allObjects as! [Lesson]).map({ (lesson) -> StoryStateful in
            return StoryStateful(lesson: lesson)
        })
        self.hasSetMobilityGoal = user.hasSetGoal
        self.mobilityGoalChosen = Int(user.mobilityGoalChosen)
        self.mobilityGoalPoints = Int(user.mobilityGoalPoints)
        
        self.chosenDefaultCampaignID = user.chosenDefaultCampaignID ?? ""
        self.dontShowTellUsMorePopup = user.dontShowTellUsMorePopup ?? false
        self.lastSummarySent = user.lastSummarySent ?? 0.0
        
        user.fullPoints = user.fullPoints.filter( {$0.key != ""})
        
        self.pointsPerCampaign = user.fullPoints.map({ (tuples) -> CampaignScore in
            return CampaignScore(campaignID: user.getCampaignID(id: tuples.key), campaignScore: Int(tuples.value))
        })
        
        print("--- -points per campaign")
        for point in pointsPerCampaign {
            print("--- -ID=" + point.campaignID + ", score=" + String(point.campaignScore))
        }
        self.lang = (Languages.getLanguageForSMCode(smartphoneID: user.language ?? "") ?? Languages.getLanguages().first)?.woortiID
        
        //more info
        self.maritalStatusHousehold = user.maritalStatusHousehold ?? ""
        self.numberPeopleHousehold = user.humberPeopleHousehold ?? ""
        self.yearsOfResidenceHousehold = user.yearsOfResidenceHousehold ?? ""
        self.labourStatusHousehold = user.labourStatusHousehold ?? ""
        
        self.seenBateryPopup = user.seenBateryPopup
        //        self.carOwner = user.carOwner
        //        self.motorbikeOwner = user.motorbikeOwner
        //        self.subsPubTrans = user.subsPubTrans
        //        self.subsCarShare = user.subsCarShare
        //        self.subsBikShare = user.subsBikShare
        
        if let homeAddr = user.homeAddress {
            self.homeAddress = HomeWorkAddress(location: LatLng(), address: homeAddr)
        }
        if let workAddr = user.workAddress {
            self.workAddress = HomeWorkAddress(location: LatLng(), address: workAddr)
        }
        
    }
    

    
    func updateUser(user: MotivUser) {
        print("Update user settings")
        user.version = self.version
        user.prodValue = self.prodValue
        user.relValue = self.relValue
        user.actValue = self.actValue
        user.name = self.name
        user.country = self.country
        user.city = self.city
        user.minAge = self.minAge
        user.maxAge = self.maxAge
        user.gender = self.gender
        user.degree = self.degree
        
        user.preferedMots = NSSet(array: self.preferedMots)
        
        print("New preferedMots count = \(user.preferedMots.count)")
        
        //added
        user.lessons = NSSet(array: Lesson.getLessonsForStoryStatefull(stories: self.stories))
        user.hasSetGoal = self.hasSetMobilityGoal ?? false
        user.mobilityGoalChosen = Double(self.mobilityGoalChosen ?? -1)
        user.mobilityGoalPoints = Double(self.mobilityGoalPoints ?? 0)
        
        var pointsDict = [String: Double]()
        
        //Save dummy status
        if let value = user.fullPoints["dummyCampaignID"] {
            pointsDict["dummyCampaignID"] = value
        }
        
        self.pointsPerCampaign.forEach { (score) in
            pointsDict[score.campaignID] = Double(score.campaignScore)
        }
        
        user.fullPoints = pointsDict
        user.language = (Languages.getLanguageForWoortiCode(woortiID: self.lang ?? "") ?? Languages.getLanguages().first!).smartphoneID
        
        //more info
        if let maritalStatusHousehold = self.maritalStatusHousehold {
            user.maritalStatusHousehold = self.maritalStatusHousehold
        }
        if let numberPeopleHousehold = self.numberPeopleHousehold {
            user.humberPeopleHousehold = self.numberPeopleHousehold
        }
        if let yearsOfResidenceHousehold = self.yearsOfResidenceHousehold {
            user.yearsOfResidenceHousehold = self.yearsOfResidenceHousehold
        }
        if let labourStatusHousehold = self.labourStatusHousehold {
            user.labourStatusHousehold = self.labourStatusHousehold
        }
        
        //        user.carOwner = self.carOwner
        //        user.motorbikeOwner = self.motorbikeOwner
        //        user.subsPubTrans = self.subsPubTrans
        //        user.subsCarShare = self.subsCarShare
        //        user.subsBikShare = self.subsBikShare
        
        user.hasOnboardingInfo = true
        user.hasOnboardingFilledInfo = true
        user.seenBateryPopup = self.seenBateryPopup ?? false
        
        if let chosenCampaignId = self.chosenDefaultCampaignID {
            user.chosenDefaultCampaignID = chosenCampaignId
        }
        
        if let dontShowTellUsMorePopup = self.dontShowTellUsMorePopup {
            user.dontShowTellUsMorePopup = dontShowTellUsMorePopup
        }
        if let lastSummarySent = self.lastSummarySent {
            user.lastSummarySent = lastSummarySent
        }
    }
}

struct StoryStateful: JsonParseable {
    let storyID: Double
    let read: Bool
    let readTimestamp: Double
    let availableTimestamp: Double
    
    init(lesson: Lesson) {
        self.storyID = lesson.order
        self.read = (lesson.read != nil)
        let date = (lesson.read ?? Date(timeIntervalSince1970: 0))
        self.readTimestamp = date.timeIntervalSince1970 * 1000
        self.availableTimestamp = UtilityFunctions.getDateFromDateTimeWithHourAndMinute(date: date, dayDistance: 1).timeIntervalSince1970 * 1000
    }
}

struct CampaignScore: JsonParseable {
    let campaignID: String
    let campaignScore: Int
    
    init(campaignID: String, campaignScore: Int) {
        self.campaignID = campaignID
        self.campaignScore = campaignScore
    }
}
