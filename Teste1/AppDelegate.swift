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

import UIKit
import CoreData
import os.log
import Firebase
import GoogleSignIn
//import FirebaseAuthUI
//import FirebaseGoogleAuthUI
import Crashlytics
import Fabric
import UserNotifications
import FirebaseMessaging

import CoreML
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, MessagingDelegate {
    
    var window: UIWindow?
    var context: NSManagedObjectContext?
    var application: UIApplication?
    
    func requestAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound ]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
    }
    
    public func startUpTripDetectionOnStart() {
        if Thread.isMainThread {
            //Cloud Messageing (Push notifiations)
            if #available(iOS 10.0, *) {
                // For iOS 10 display notification (sent via APNS)
                UNUserNotificationCenter.current().delegate = PushNotificationsDelegate()
                
                requestAuthorization()
            } else {
                let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                self.application!.registerUserNotificationSettings(settings)
            }
            self.application!.registerForRemoteNotifications()
            
            Messaging.messaging().delegate = self //MotivMessagingDelegate()
            
            //start trip detection
            DetectActivityModule.startAD()
            PowerManagementModule.GPSOnAppStart() //it has the timer to turn off if not in Trip in 5 min time
            PowerManagementModule.canToggle=true
            
            PowerManagementModule.startRunningTRansportDetection()
        } else {
            DispatchQueue.main.async {
                self.startUpTripDetectionOnStart()
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Firebase
        startFirebase(application: application)
        
        //Get context
        context = persistentContainer.viewContext
        context?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context?.shouldDeleteInaccessibleFaults = true
        
        UserInfo.appDelegate=self
        StartUpUserInfo()
        // Closes opened trips and turns the services on
        self.application = application
        return true
    }
    //Mark: Frirebase Start
    func startFirebase(application: UIApplication) {
        //Firebase
        FirebaseApp.configure()
        
        // Enable Crashlytics debug logging
        Fabric.sharedSDK().debug = true
        
        //Crashlitics
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        
        print("Firebase registration token: \(Messaging.messaging().fcmToken ?? "")")
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            print("ERROR ON SIGN IN WITH GOOGLE")
            // ...
            return
        }
        
        guard let authentication = user.authentication else {
            print("ERROR ON SIGN IN WITH GOOGLE")
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("ERROR ON SIGN IN WITH GOOGLE")
                return
            }
            if let user = user  {
                UserInfo.email = user.user.email
            }
            // User is signed in
            // ...
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    //Mark: Frirebase End
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        //        print("Memory warning")
        saveContext()
        //        print("saved Context after memory warning")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //self.saveContext()
        PowerManagementModule.toggleSemaphore.wait()
        PowerManagementModule.canToggle=false
        if PowerManagementModule.getGPSPower()==PowerManagementModule.GPSPower.PowerSaving && UserInfo.inFullTrip(){
            PowerManagementModule.TurnGpsOn()
        }
        PowerManagementModule.toggleSemaphore.signal()
        Crashlytics.sharedInstance().setObjectValue(true, forKey: "background")
//        saveContext()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        PowerManagementModule.canToggle=true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Crashlytics.sharedInstance().setObjectValue(false, forKey: "foreground")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        saveContext()
    }
    
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "MoTiV")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                var errorStr = "Unresolved Error load Store Data"
            } else if let store = storeDescription as? NSPersistentStoreDescription {

            }
        })
        
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext() {
        NotificationEngine.getInstance().debugNotification(title: "!!context!! context save start", body: "at: \(UtilityFunctions.getLocaleDate(date: Date()))", notify: false)
        //finite length task
        let bg = FiniteBackgroundTask()
        bg.registerBackgroundTask(withName: "saveContext")
        let sincSem = DispatchSemaphore(value: 0)
        let rds = RawDataSegmentation.getInstance()
        rds.saveContext(sem: sincSem)
        
        if (context == nil) {
            context = persistentContainer.viewContext
        }
//        context?.performAndWait {
        let uic = UserInfo.context
        print("uic: \(uic?.debugDescription ?? "")")
        UserInfo.ContextSemaphore.wait()
        uic?.performAndWait {
            let timeoutResult = sincSem.wait(timeout: DispatchTime(uptimeNanoseconds: 1000 * 1000)) // 1s
            if (uic?.hasChanges)! {
                do {
                    uic?.processPendingChanges()
                    try uic?.save()
                } catch {
                    let nserror = error as NSError
                    print("!!uic!!!!uic!!\n")
                    os_log("!!uic!! Unresolved error save store data" , type: .error)
                    print("error: \(error.localizedDescription)")
                    print("error: \(nserror.userInfo)")
                    print("error: \(nserror)")
                    print("\n")
                    UserInfo.writeToLog("!!uic!! Unresolved error save store data error: \(nserror.localizedDescription) !! \(nserror.userInfo)")
                    if let obj = nserror.userInfo["NSValidationErrorObject"] as? NSManagedObject {
                        if let obj1 = uic?.registeredObject(for: obj.objectID) {
//                            uic?.delete(obj1)
                        }
                    }
                }
            }
            print("parent: \(UserInfo.parentContext?.debugDescription ?? "")")
            UserInfo.parentContext?.performAndWait{
                print("startContextSave")
                if (UserInfo.parentContext?.hasChanges)! {
                    do {
                        try UserInfo.parentContext?.processPendingChanges()
                        try UserInfo.parentContext?.save()
                    } catch {
                        let nserror = error as NSError
                        print("!!context!!!!context!!\n")
                        os_log("!!context!! Unresolved error save store data" , type: .error)
                        print("error: \(error.localizedDescription)")
                        print("error: \(nserror.userInfo)")
                        print("error: \(nserror)")
                        print("\n")
                        UserInfo.writeToLog("!!context!! Unresolved error save store data error: \(error.localizedDescription) !! \(nserror.userInfo)")
                        if let obj = nserror.userInfo["NSValidationErrorObject"] as? NSManagedObject {
                            if let obj1 = UserInfo.parentContext?.registeredObject(for: obj.objectID) {
//                                UserInfo.parentContext?.delete(obj1)
                            }
                        } else if let mlinputmetadatas = nserror.userInfo["NSAffectedObjectsErrorKey"] as? [NSManagedObject] {
                            for ml in mlinputmetadatas {
                                UserInfo.writeToLog("!!context!! inserted missing: \(ml.debugDescription)")
                                UserInfo.parentContext?.insert(ml)
                            }
                        } else {
                            UserInfo.writeToLog("!!context!! undoing: from error: \(error.localizedDescription)")
                            UserInfo.parentContext?.undo()
                        }
                    }
                }
                bg.endBackgroundTask() 
                print("endContextSave")
            }
        }
        rds.managedObjectContextSemaphore.signal()
        NotificationEngine.getInstance().debugNotification(title: "!!context!! context save start", body: "at: \(UtilityFunctions.getLocaleDate(date: Date()))", notify: false)
        UserInfo.ContextSemaphore.signal()
    }
    
    //Mark: core Data
    public func StartUpUserInfo(){
        //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        UserInfo.startUp(context: context!)
    }
    
    //MARK: Push notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo["gcmMessageIDKey"] {
            print("Message ID: \(messageID)")
        }
        
        MotivRequestManager.getInstance().UpdateMySurveys()
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo["gcmMessageIDKey"] {
            print("Message ID: \(messageID)")
        }
        if let user = MotivUser.getInstance() {
            MotivRequestManager.getInstance(token: user.getToken()).UpdateMySurveys()
        } else {
            
        }
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //send token to server
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //failed
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        MotivUser.getIdToken(processToken: ProcessSendToken())
    }
    
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//        print("Firebase registration token: \(fcmToken)")
//        MotivUser.getIdToken(processToken: ProcessSendToken())
//        // TODO: If necessary send token to application server.
//        // Note: This callback is fired at each app startup and whenever a new token is generated.
//    }
    
}

