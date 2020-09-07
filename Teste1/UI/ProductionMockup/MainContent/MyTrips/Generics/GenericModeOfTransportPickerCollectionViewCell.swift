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

class GenericModeOfTransportPickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var MotLabel: UILabel!
    
    var motSelected = false
    
    var mot: motToCell?
    
    func loadCell(mot: motToCell, motSelected: Bool) {
        self.mot = mot
        self.imageView.image = mot.image
        self.imageView.tintColor = UIColor.black
        MotivAuxiliaryFunctions.RoundView(view: self)
        if motSelected {
            selectMot()
        } else {
            deselectMot()
        }
    }
    
    private func selectMot() {
        MotivFont.motivBoldFontFor(key: self.mot!.text, comment: "", label: self.MotLabel, size: 9)
        self.MotLabel.textColor = MotivColors.WoortiOrange
        self.backgroundColor = MotivColors.WoortiOrangeT3
        motSelected = true
        
        DispatchQueue.main.async {
            self.layoutIfNeeded()
        }
    }
    
    private func deselectMot() {
        MotivFont.motivRegularFontFor(key: self.mot!.text, comment: "", label: self.MotLabel, size: 9)
        self.MotLabel.textColor = UIColor.black
        self.backgroundColor = UIColor.white
//        self.backgroundColor = UIColor.blue
        motSelected = false
        
        DispatchQueue.main.async {
            self.layoutIfNeeded()
        }
    }
    
    func selecteMotIfDeselected() -> motToCell? {
        if self.motSelected {
            deselectMot()
            return nil
        } else {
            selectMot()
            return mot
        }
    }
    
    func deselectIfSelected() {
        if self.motSelected {
            deselectMot()
        }
    }
    
}

@objc public class motToCell: NSObject {
    
    let text: String
    let image: UIImage
    let imageFaded: UIImage
    let mode: Int
    let strMode: String
    var otherValue = ""
    
    private init(text: String, image: String, mode: Int, strMode: String) {
        self.text = text
        self.image = UIImage(named: image)!
        self.imageFaded = UIImage(named: "\(image)_Orange")!
        self.mode = mode
        self.strMode = strMode
    }
    
    enum typeOfMot {
        case publicMot, activeMot, privateMot
    }
    
//    static func getMotCells() -> [motToCell] {
//        var mtc = [motToCell]()
//
//        mtc.append(motToCell(text: "Walk", image: "directions_walk_black", mode: Trip.modesOfTransport.walking.rawValue, strMode: ActivityClassfier.WALKING))
//        mtc.append(motToCell(text: "Bicycle", image: "directions_bike_black", mode: Trip.modesOfTransport.cycling.rawValue, strMode: ActivityClassfier.CYCLING))
//        mtc.append(motToCell(text: "Car (Driver)", image: "directions_car_black", mode: Trip.modesOfTransport.Car.rawValue, strMode: ActivityClassfier.CAR))
//        mtc.append(motToCell(text: "Bus", image: "directions_bus_black", mode: Trip.modesOfTransport.Bus.rawValue, strMode: ActivityClassfier.BUS))
//        mtc.append(motToCell(text: "Tram", image: "directions_railway_black", mode: Trip.modesOfTransport.Tram.rawValue, strMode: ActivityClassfier.TRAM))
//        mtc.append(motToCell(text: "Metro", image: "baseline_subway_black_18dp", mode: Trip.modesOfTransport.Subway.rawValue, strMode: ActivityClassfier.METRO))
//        mtc.append(motToCell(text: "Train", image: "baseline_train_black_18dp", mode: Trip.modesOfTransport.Train.rawValue, strMode: ActivityClassfier.TRAIN))
//        mtc.append(motToCell(text: "Ferry/Boat", image: "directions_boat_black", mode: Trip.modesOfTransport.Ferry.rawValue, strMode: ActivityClassfier.FERRY))
////        mtc.append(motToCell(text: "Motorcycle", image: "directions_walk_black", mode: Trip.modesOfTransport.Car.rawValue))
////        mtc.append(motToCell(text: "Moped", image: "directions_walk_black", mode: Trip.modesOfTransport.Car.rawValue))
////        mtc.append(motToCell(text: "Electric Bicycle", image: "directions_walk_black", mode: Trip.modesOfTransport.cycling.rawValue))
////        mtc.append(motToCell(text: "Bike Sharing", image: "directions_walk_black", mode: Trip.modesOfTransport.cycling.rawValue))
////        mtc.append(motToCell(text: "Car (Passenger)", image: "directions_walk_black", mode: Trip.modesOfTransport.Car.rawValue))
////        mtc.append(motToCell(text: "Taxi", image: "directions_walk_black", mode: Trip.modesOfTransport.Car.rawValue))
////        mtc.append(motToCell(text: "Ride Hailing (eg Uber)", image: "directions_walk_black", mode: Trip.modesOfTransport.Car.rawValue))
////        mtc.append(motToCell(text: "Car Sharing", image: "directions_walk_black", mode: Trip.modesOfTransport.Car.rawValue))
////        mtc.append(motToCell(text: "Car Pooling", image: "directions_walk_black", mode: Trip.modesOfTransport.Car.rawValue))
//        mtc.append(motToCell(text: "Airplane", image: "baseline_airplanemode_active_black_18dp", mode: Trip.modesOfTransport.Plane.rawValue, strMode: ActivityClassfier.PLANE))
////        mtc.append(motToCell(text: "High-Speed Train", image: "directions_walk_black", mode: Trip.modesOfTransport.Train.rawValue))
////        mtc.append(motToCell(text: "Bus (Long Distance)", image: "directions_walk_black", mode: Trip.modesOfTransport.Bus.rawValue))
//        mtc.append(motToCell(text: "Run", image: "directions_walk_black", mode: Trip.modesOfTransport.running.rawValue, strMode: ActivityClassfier.RUNNING))
////        mtc.append(motToCell(text: "Micro Scooter", image: "directions_walk_black", mode: Trip.modesOfTransport.walking.rawValue))
////        mtc.append(motToCell(text: "Skate", image: "directions_walk_black", mode: Trip.modesOfTransport.walking.rawValue))
////        mtc.append(motToCell(text: "Shared moped", image: "directions_walk_black", mode: Trip.modesOfTransport.cycling.rawValue))
//        mtc.append(getOtherMotToCell())
//        return mtc
//    }
    
    static func getPublicMOTCells() -> [motToCell] {
        var mtc = [motToCell]()
        
        mtc.append(motToCell(text: "Metro", image: "Icon_Metro", mode: Trip.modesOfTransport.Subway.rawValue, strMode: ActivityClassfier.METRO))
        mtc.append(motToCell(text: "Tram", image: "Icon_Tram", mode: Trip.modesOfTransport.Tram.rawValue, strMode: ActivityClassfier.TRAM))
        mtc.append(motToCell(text: "Bus_Trolley_Bus", image: "Icon_Bus", mode: Trip.modesOfTransport.Bus.rawValue, strMode: ActivityClassfier.BUS))
        mtc.append(motToCell(text: "Coach_Long_Distance_Bus", image: "Icon_Coach", mode: Trip.modesOfTransport.busLongDistance.rawValue, strMode: ActivityClassfier.BUS))
        mtc.append(motToCell(text: "Urban_Train", image: "Icon_Urban_Train", mode: Trip.modesOfTransport.Train.rawValue, strMode: ActivityClassfier.TRAIN))
        mtc.append(motToCell(text: "Regional_Intercity_Train", image: "Icon_Regional_Intercity_Train", mode: Trip.modesOfTransport.intercityTrain.rawValue, strMode: ActivityClassfier.TRAIN))
        mtc.append(motToCell(text: "high_speed_train", image: "Icon_High_Speed_Train", mode: Trip.modesOfTransport.highSpeedTrain.rawValue, strMode: ActivityClassfier.TRAIN))
        mtc.append(motToCell(text: "Ferry_Boat", image: "Icon_Ferry_Boat", mode: Trip.modesOfTransport.Ferry.rawValue, strMode: ActivityClassfier.FERRY))
        mtc.append(motToCell(text: "Plane", image: "Icon_Airplane", mode: Trip.modesOfTransport.Plane.rawValue, strMode: ActivityClassfier.PLANE))
        mtc.append(getOtherPublicMotToCell())
        return mtc
    }
    
    static func getActiveMOTCells() -> [motToCell] {
        var mtc = [motToCell]()
        
        mtc.append(motToCell(text: "Walking", image: "Icon_Walking", mode: Trip.modesOfTransport.walking.rawValue, strMode: ActivityClassfier.WALKING))
        mtc.append(motToCell(text: "Jogging_Running", image: "Icon_Jogging", mode: Trip.modesOfTransport.running.rawValue, strMode: ActivityClassfier.RUNNING))
        mtc.append(motToCell(text: "Wheelchair", image: "Icon_Wheelchair", mode: Trip.modesOfTransport.wheelChair.rawValue, strMode: ActivityClassfier.CYCLING))
        mtc.append(motToCell(text: "Bicycle", image: "Icon_Bicycle", mode: Trip.modesOfTransport.cycling.rawValue, strMode: ActivityClassfier.CYCLING))
        mtc.append(motToCell(text: "Electric_Bike", image: "Icon_Electric_Bike", mode: Trip.modesOfTransport.electricBike.rawValue, strMode: ActivityClassfier.CYCLING))
        mtc.append(motToCell(text: "Cargo_Bike", image: "Icon_Cargo_Bike", mode: Trip.modesOfTransport.cargoBike.rawValue, strMode: ActivityClassfier.CYCLING))
        mtc.append(motToCell(text: "Bike_Sharing", image: "Icon_Bike_Sharing", mode: Trip.modesOfTransport.bikeSharing.rawValue, strMode: ActivityClassfier.CYCLING))
        mtc.append(motToCell(text: "Micro_Scooter", image: "Icon_Micro_Scooter", mode: Trip.modesOfTransport.microScooter.rawValue, strMode: ActivityClassfier.CYCLING))
        mtc.append(motToCell(text: "Skate", image: "Icon_Skateboard", mode: Trip.modesOfTransport.skate.rawValue, strMode: ActivityClassfier.CYCLING))
        mtc.append(getOtherActiveMotToCell())
        return mtc
    }
    
    static func getPrivateMOTCells() -> [motToCell] {
        var mtc = [motToCell]()
        
        mtc.append(motToCell(text: "Car_Driver", image: "Icon_Private_Car_Driver", mode: Trip.modesOfTransport.Car.rawValue, strMode: ActivityClassfier.CAR))
        mtc.append(motToCell(text: "Car_Passenger", image: "Icon_Private_Car_Passenger", mode: Trip.modesOfTransport.carPassenger.rawValue, strMode: ActivityClassfier.CAR))
        mtc.append(motToCell(text: "Taxi_Ride_Hailing", image: "Icon_Taxi", mode: Trip.modesOfTransport.taxi.rawValue, strMode: ActivityClassfier.CAR))
        mtc.append(motToCell(text: "Car_Sharing_Rental_Driver", image: "Icon_Car_Sharing_Driver", mode: Trip.modesOfTransport.carSharing.rawValue, strMode: ActivityClassfier.CAR))
        mtc.append(motToCell(text: "Car_Sharing_Rental_Passenger", image: "Icon_Car_Sharing_Passenger", mode: Trip.modesOfTransport.carSharingPassenger.rawValue, strMode: ActivityClassfier.CAR))
        mtc.append(motToCell(text: "Moped", image: "Icon_Moped", mode: Trip.modesOfTransport.moped.rawValue, strMode: ActivityClassfier.CAR))
        mtc.append(motToCell(text: "Motorcycle", image: "Icon_Motorcycle", mode: Trip.modesOfTransport.motorcycle.rawValue, strMode: ActivityClassfier.CAR))
        mtc.append(motToCell(text: "Electric_Wheelchair_Cart", image: "Icon_Electric_Wheelchair", mode: Trip.modesOfTransport.electricWheelchair.rawValue, strMode: ActivityClassfier.CAR))
        
        mtc.append(getOtherPrivateMotToCell())
        return mtc
    }
    
    static func getOtherMotToCell() -> motToCell {
        return motToCell(text: "Other", image: "Icon_Other", mode: Trip.modesOfTransport.other.rawValue, strMode: ActivityClassfier.UNKNOWN)
    }
    static func getOtherPublicMotToCell() -> motToCell {
        return motToCell(text: "Other", image: "Icon_Other", mode: Trip.modesOfTransport.otherPublic.rawValue, strMode: ActivityClassfier.UNKNOWN)
    }
    static func getOtherActiveMotToCell() -> motToCell {
        return motToCell(text: "Other", image: "Icon_Other", mode: Trip.modesOfTransport.otherActive.rawValue, strMode: ActivityClassfier.UNKNOWN)
    }
    static func getOtherPrivateMotToCell() -> motToCell {
        return motToCell(text: "Other", image: "Icon_Other", mode: Trip.modesOfTransport.otherPrivate.rawValue, strMode: ActivityClassfier.UNKNOWN)
    }
    
    static func getTypeFromCode(mode: Trip.modesOfTransport) -> typeOfMot {
//        getPublicMOTCells().contains(where: { (a) -> Bool in
//            a.mode == mode.rawValue
//        })
        if getPublicMOTCells().contains(where: { $0.mode == mode.rawValue }) || mode.rawValue == Trip.modesOfTransport.transfer.rawValue {
            return typeOfMot.publicMot
        } else if getActiveMOTCells().contains(where: { $0.mode == mode.rawValue }) {
            return typeOfMot.activeMot
        } else {
            return typeOfMot.privateMot
        }
    }
    
    static func getTextForModeOfTransport(mode: Int, otherText: String) -> String {
        var trasportModes = getPublicMOTCells()
        trasportModes.append(contentsOf: getActiveMOTCells())
        trasportModes.append(contentsOf: getPrivateMOTCells())
        
        for mot in trasportModes {
            if mot.mode == mode {
                if mot.text == getOtherMotToCell().text {
                    return otherText
                } else {
                    return mot.text
                }
            }
        }
        return trasportModes.first?.text ?? ""
    }
    
    static func getImageForModeOfTransport(mode: Int) -> UIImage? {
        var trasportModes = getPublicMOTCells()
        trasportModes.append(contentsOf: getActiveMOTCells())
        trasportModes.append(contentsOf: getPrivateMOTCells())
        
         //print("--- FINDING MODE =" + String(mode))
        
        for mot in trasportModes {
            if mot.mode == mode {
                //print("--- MODE=" + String(mot.mode) + ", text=" + mot.strMode)
                return mot.image
            }
        }
        //print("--- Returning mode=" + String(trasportModes.first!.mode))
        return trasportModes.first!.image
    }
    
    static func getImageFadedForModeOfTransport(mode: Int) -> UIImage? {
        var trasportModes = getPublicMOTCells()
        trasportModes.append(contentsOf: getActiveMOTCells())
        trasportModes.append(contentsOf: getPrivateMOTCells())
        
        for mot in trasportModes {
            if mot.mode == mode {
                return mot.imageFaded
            }
        }
        
        return trasportModes.first!.imageFaded
    }
    
    static func getMotFromText(text: String) -> motToCell? {
        var trasportModes = getPublicMOTCells()
        trasportModes.append(contentsOf: getActiveMOTCells())
        trasportModes.append(contentsOf: getPrivateMOTCells())
        
        for mot in trasportModes {
            if mot.text == text {
                return mot
            }
        }
        
        return nil
    }
}
