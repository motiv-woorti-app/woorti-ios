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

/*
 * Rest Communication Manager
 */
class RestModule: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    var urlString: String
    var jsonData: Data
    var method: Method
    var responseFunction: JsonRequest
    var accessToken: String?
    var dataString: String = ""
    var retry = 0
    
    enum Method: String {
        case PUT, GET, POST, DELETE
    }
    
    init(urlString: String, jsonData: Data, method: Method, responseFunction: JsonRequest, accessToken: String?){
        self.urlString = urlString
        self.jsonData = jsonData
        self.method = method
        self.responseFunction = responseFunction
        self.accessToken = accessToken
    }
    
    public func makeRequest(){
        if  let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let url = URL(string: encoded) {
            var request = URLRequest(url: url)
            request.httpMethod = self.method.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if self.accessToken != nil {
                request.setValue("Bearer " + self.accessToken!, forHTTPHeaderField: "Authorization")
            }
            
            if self.method != Method.GET {
                request.httpBody = self.jsonData
            }
            
            let configuration = URLSessionConfiguration.default
            
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue:OperationQueue.main)
            
            let task = session.dataTask(with: request) { data, response, error in
                DispatchQueue.global(qos: .utility).async {
                    print("DataTask with Request=" + self.urlString)
                    if let error = error as? NSError {
                        print("error \(error)")
                        if error.code == -1009 {
                            
                            print(error.localizedDescription)
                        }
                        self.responseFunction.responseFunc(response: "")
                        return
                    }

                    if let response = response as? HTTPURLResponse {

                        if (200...299).contains(response.statusCode){
                            if let mimeType = response.mimeType,
                                mimeType == "application/json",
                                let data = data,
                                let dataString = String(data: data, encoding: .utf8) {
                                print ("got data: \(dataString)")
                                self.responseFunction.responseFunc(response: dataString)
                            }
                        } else {
                            Crashlytics.sharedInstance().recordCustomExceptionName("network response status", reason: "code: \(response.statusCode) on request: \(self.urlString) ", frameArray: [CLSStackFrame]())
                            print ("network response status code: \(response.statusCode) on request: \(self.urlString) ")
                            if 403 == response.statusCode {
                                if let mimeType = response.mimeType,
                                    mimeType == "application/json",
                                    let data = data,
                                    let dataString = String(data: data, encoding: .utf8) {
                                    print ("got data: \(dataString)")
                                    print ("response Code: \(response.statusCode)")

                                    self.responseFunction.responseFuncError(response: dataString)
                                }
                                return
                            } else if 401 == response.statusCode {
                                print("Status code = 401")
                                if self.retry > 2 {
                                    return
                                }
                                
                                self.retry += 1
                                MotivUser.getInstance()?.refreshToken()
                                Thread.sleep(forTimeInterval: 60)
                                self.accessToken = MotivUser.getInstance()?.getToken() ?? ""
                                self.makeRequest()
                            } else {
                                print("Status code = ELSE")
                                if self.retry > 2 {
                                    return
                                }
                                self.retry += 1
                                Thread.sleep(forTimeInterval: 60)
                                self.makeRequest()
                            }
                        }

                    } else {
                        return
                    }
                }
            }
            
            task.resume()
        }
    }
    
    //Testing https Methods
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod == (NSURLAuthenticationMethodServerTrust) {
            
            
            let serverTrust:SecTrust = challenge.protectionSpace.serverTrust!
            print(" trust Server: \(challenge.protectionSpace.host)")
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!)) //Workarround
//            let certificate: SecCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0)!
//            let remoteCertificateData = CFBridgingRetain(SecCertificateCopyData(certificate))!
//            let cerPath: String = Bundle.main.path(forResource: "example.com", ofType: "cer")!
//            let localCertificateData = NSData(contentsOfFile:cerPath)!
//
//            if (remoteCertificateData.isEqual(localCertificateData as Data) == true) {
//                let credential:URLCredential = URLCredential(trust: serverTrust)
//
//                challenge.sender?.use(credential, for: challenge)
//
//                completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
//            } else {
//
//                completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
//            }
        }
        else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate
        {
            
            let path: String = Bundle.main.path(forResource: "client", ofType: "p12")!
            let PKCS12Data = NSData(contentsOfFile:path)!
            
            
            let identityAndTrust:IdentityAndTrust = self.extractIdentity(certData: PKCS12Data);
            
            let urlCredential:URLCredential = URLCredential(
                identity: identityAndTrust.identityRef,
                certificates: identityAndTrust.certArray as? [AnyObject],
                persistence: URLCredential.Persistence.forSession);
            
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, urlCredential);
        }
        else
        {
            completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil);
        }
    }
    
    struct IdentityAndTrust {
        
        var identityRef:SecIdentity
        var trust:SecTrust
        var certArray:AnyObject
    }
    
    func extractIdentity(certData:NSData) -> IdentityAndTrust {
        var identityAndTrust:IdentityAndTrust!
        var securityError:OSStatus = errSecSuccess
        
        let path: String = Bundle.main.path(forResource: "client", ofType: "p12")!
        let PKCS12Data = NSData(contentsOfFile:path)!
        let key : NSString = kSecImportExportPassphrase as NSString
        let options : NSDictionary = [key : "xyz"]
        //create variable for holding security information
        //var privateKeyRef: SecKeyRef? = nil
        
        var items : CFArray?
        
        securityError = SecPKCS12Import(PKCS12Data, options, &items)
        
        if securityError == errSecSuccess {
            let certItems:CFArray = items as CFArray!;
            let certItemsArray:Array = certItems as Array
            let dict:AnyObject? = certItemsArray.first;
            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {
                
                // grab the identity
                let identityPointer:AnyObject? = certEntry["identity"];
                let secIdentityRef:SecIdentity = identityPointer as! SecIdentity!;
                print("\(identityPointer)  :::: \(secIdentityRef)")
                // grab the trust
                let trustPointer:AnyObject? = certEntry["trust"];
                let trustRef:SecTrust = trustPointer as! SecTrust;
                print("\(trustPointer)  :::: \(trustRef)")
                // grab the cert
                let chainPointer:AnyObject? = certEntry["chain"];
                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef, trust: trustRef, certArray:  chainPointer!);
            }
        }
        return identityAndTrust;
    }
}
