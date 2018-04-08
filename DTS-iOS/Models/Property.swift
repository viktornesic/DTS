//
//  Property.swift
//  CoucouApp
//
//  Created by Viktor on 03/11/2016.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import SwiftyJSON

enum PropertyKeys : String {
    case id = "id"
    case key = "key"
    case type = "type"
    case source = "source"
    case authorUserId = "author_user_id"
    case reviewed = "reviewed"
    case deactivated = "deactivated"
    case deactivationType = "deactivation_type"
    case mainPhotoId = "main_photo_id"
    case title = "title"
    case propertyDescription = "description"
    case status = "status"
    case yearsBuilt = "year_built"
    case lotSize = "lot_size"
    case modificationTimeStamp = "modification_timestamp"
    case cat = "cat"
    case dog = "dog"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case bed = "bed"
    case bath = "bath"
    case price = "price"
    case term = "term"
    case address1 = "address1"
    case address2 = "address2"
    case zip = "zip"
    case city = "city"
    case stateOrProvince = "state_or_province"
    case country = "country"
    case unitAmenAc = "unit_amen_ac"
    case unitAmenParkingReserved = "unit_amen_parking_reserved"
    case unitAmenBalcony = "unit_amen_balcony"
    case unitAmenDeck = "unit_amen_deck"
    case unitAmenCeilingFan = "unit_amen_ceiling_fan"
    case unitAmenDishwasher = "unit_amen_dishwasher"
    case unitAmenFireplace = "unit_amen_fireplace"
    case unitAmenFurnished = "unit_amen_furnished"
    case unitAmenLaundry = "unit_amen_laundry"
    case unitAmenFloorCarpet = "unit_amen_floor_carpet"
    case unitAmenFloorHardWood = "unit_amen_floor_hard_wood"
    case unitAmenCarpet = "unit_amen_carpet"
    case buildAmenFitnessCenter = "build_amen_fitness_center"
    case buildAmenBizCenter = "build_amen_biz_center"
    case buildAmenConcierge = "build_amen_concierge"
    case buildAmenDoorman = "build_amen_doorman"
    case buildAmenDryCleaning = "build_amen_dry_cleaning"
    case buildAmenElevator = "build_amen_elevator"
    case buildAmenParkGarage = "build_amen_park_garage"
    case buildAmenSwimPool = "build_amen_swim_pool"
    case buildAmenSecureEntry = "build_amen_secure_entry"
    case buildAmenStorage = "build_amen_storage"
    case keywords = "keywords"
    case latitude = "latitude"
    case longitude = "longitude"
    case disabled = "disabled"
    case deleted = "deleted"
    case availabilityDate = "availability_date"
    case bot = "bot"
    case selectedUnitAmenities = "selected_unit_amenities"
    case selectedBuildingAmenities = "selected_building_amenities"
    
}

class Property : NSObject {
    
    var id: Int?
    var key: String?
    var type: String?
    var source: String?
    var authorUserId: Int?
    var reviewed: String?
    var deactivated: Int?
    var deactivationType: String?
    var mainPhotoId: String?
    var title: String?
    var propertyDescription: String?
    var status:String?
    var yearsBuilt: Int?
    var lotSize: Int?
    var modificationTimeStamp: String?
    var cat: Int?
    var dog: Int?
    var createdAt: String?
    var updatedAt: String?
    var bed: Int?
    var bath: Int?
    var price: Int?
    var term: String?
    var address1: String?
    var address2: String?
    var zip: String?
    var city: String?
    var stateOrProvince: String?
    var country: String?
    var unitAmenAc: Int?
    var unitAmenParkingReserved: Int?
    var unitAmenBalcony: Int?
    var unitAmenDeck: Int?
    var unitAmenCeilingFan: Int?
    var unitAmenDishwasher: Int?
    var unitAmenFireplace: Int?
    var unitAmenFurnished:Int?
    var unitAmenLaundry:Int?
    var unitAmenFloorCarpet: Int?
    var unitAmenFloorHardWood: Int?
    var unitAmenCarpet: Int?
    var buildAmenFitnessCenter: Int?
    var buildAmenBizCenter:Int?
    var buildAmenConcierge: Int?
    var buildAmenDoorman: Int?
    var buildAmenDryCleaning: Int?
    var buildAmenElevator: Int?
    var buildAmenParkGarage: Int?
    var buildAmenSwimPool: Int?
    var buildAmenSecureEntry: Int?
    var buildAmenStorage: Int?
    var keywords: String?
    var latitude: String?
    var longitude:String?
    var disabled: Int?
    var deleted: Int?
    var availabilityDate: String?
    var bot: Int?
    var selectedUnitAmenities: String?
    var selectedBuildingAmenities: String?
    
    
    
    
    
    init?(id: Int, key: String, type: String, source: String, authorUserId: Int, reviewed: String,deactivated: Int, deactivationType: String, mainPhotoId: String, title: String, description: String, status: String, yearsBuilt: Int,lotSize: Int, modificationTimeStamp: String, cat: Int, dog: Int, createdAt: String, updatedAt: String, bed: Int, bath: Int, price: Int, term: String,address1: String, address2: String, zip: String, city: String?,stateOrProvince: String, country: String, unitAmenAc: Int,unitAmenParkingReserved: Int,unitAmenBalcony: Int,unitAmenDeck: Int, unitAmenCeilingFan: Int, unitAmenDishwasher: Int, unitAmenFireplace: Int, unitAmenFurnished:Int,unitAmenLaundry:Int, unitAmenFloorCarpet: Int,unitAmenFloorHardWood: Int,unitAmenCarpet: Int,buildAmenFitnessCenter: Int,buildAmenBizCenter:Int,buildAmenConcierge: Int,buildAmenDoorman: Int,buildAmenDryCleaning: Int,buildAmenElevator: Int,buildAmenParkGarage: Int,buildAmenSwimPool: Int,buildAmenSecureEntry: Int,buildAmenStorage: Int,keywords: String,latitude: String,longitude:String,disabled: Int,deleted: Int,availabilityDate: String,bot: Int,selectedUnitAmenities: String,selectedBuildingAmenities: String)
    {
        self.id = id
        self.key = key
        self.type = type
        self.source = source
        self.authorUserId = authorUserId
        self.reviewed = reviewed
        self.deactivated = deactivated
        self.deactivationType = deactivationType
        self.mainPhotoId = mainPhotoId
        self.title = title
        self.propertyDescription = description
        self.status = status
        self.yearsBuilt = yearsBuilt
        self.lotSize = lotSize
        self.modificationTimeStamp = modificationTimeStamp
        self.cat = cat
        self.dog = dog
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.bed = bed
        self.bath = bath
        self.price = price
        self.term = term
        self.address1 = address1
        self.address2 = address2
        self.zip = zip
        self.city = city
        self.stateOrProvince = stateOrProvince
        self.country = country
        self.unitAmenAc = unitAmenAc
        self.unitAmenParkingReserved = unitAmenParkingReserved
        self.unitAmenBalcony = unitAmenBalcony
        self.unitAmenDeck = unitAmenDeck
        self.unitAmenCeilingFan = unitAmenCeilingFan
        self.unitAmenDishwasher = unitAmenDishwasher
        self.unitAmenFireplace = unitAmenFireplace
        self.unitAmenFurnished = unitAmenFurnished
        self.unitAmenLaundry = unitAmenLaundry
        self.unitAmenFloorCarpet = unitAmenFloorCarpet
        self.unitAmenFloorHardWood = unitAmenFloorHardWood
        self.unitAmenCarpet = unitAmenCarpet
        self.buildAmenFitnessCenter = buildAmenFitnessCenter
        self.buildAmenBizCenter = buildAmenBizCenter
        self.buildAmenConcierge = buildAmenConcierge
        self.buildAmenDoorman = buildAmenDoorman
        self.buildAmenDryCleaning = buildAmenDryCleaning
        self.buildAmenElevator = buildAmenElevator
        self.buildAmenParkGarage = buildAmenParkGarage
        self.buildAmenSwimPool = buildAmenSwimPool
        self.buildAmenSecureEntry = buildAmenSecureEntry
        self.buildAmenStorage = buildAmenStorage
        self.keywords = keywords
        self.latitude = latitude
        self.longitude = longitude
        self.disabled = disabled
        self.deleted = deleted
        self.availabilityDate = availabilityDate
        self.bot = bot
        self.selectedUnitAmenities = selectedUnitAmenities
        self.selectedBuildingAmenities = selectedBuildingAmenities
        
        
        
        //        if id.isEmpty || selectedBuildingAmenities .isEmpty {
        //            return nil
        //        }
    }
    
    required init(withAttributes attributes: OptionalSwiftJSONParameters) throws {
        super.init()
        
        self.id = PropertyKeys.id.rawValue =/ attributes
        self.key = PropertyKeys.key.rawValue => attributes
        self.type = PropertyKeys.type.rawValue => attributes
        self.source = PropertyKeys.source.rawValue => attributes
        self.authorUserId = PropertyKeys.authorUserId.rawValue =/ attributes
        self.reviewed = PropertyKeys.reviewed.rawValue => attributes
        self.deactivated = PropertyKeys.deactivated.rawValue =/ attributes
        self.deactivationType = PropertyKeys.deactivationType.rawValue => attributes
        self.mainPhotoId = PropertyKeys.mainPhotoId.rawValue => attributes
        self.title = PropertyKeys.title.rawValue => attributes
        self.propertyDescription = PropertyKeys.propertyDescription.rawValue => attributes
        self.status = PropertyKeys.status.rawValue => attributes
        self.yearsBuilt = PropertyKeys.yearsBuilt.rawValue =/ attributes
        self.lotSize = PropertyKeys.lotSize.rawValue =/ attributes
        self.modificationTimeStamp = PropertyKeys.modificationTimeStamp.rawValue => attributes
        self.cat = PropertyKeys.cat.rawValue =/ attributes
        self.dog = PropertyKeys.dog.rawValue =/ attributes
        self.createdAt = PropertyKeys.createdAt.rawValue => attributes
        self.updatedAt = PropertyKeys.updatedAt.rawValue => attributes
        self.bed = PropertyKeys.bed.rawValue =/ attributes
        self.bath = PropertyKeys.bath.rawValue =/ attributes
        self.price = PropertyKeys.price.rawValue =/ attributes
        self.term = PropertyKeys.term.rawValue => attributes
        self.address1 = PropertyKeys.address1.rawValue => attributes
        self.address2 = PropertyKeys.address2.rawValue => attributes
        self.zip = PropertyKeys.zip.rawValue => attributes
        self.city = PropertyKeys.city.rawValue => attributes
        self.stateOrProvince = PropertyKeys.stateOrProvince.rawValue => attributes
        self.country = PropertyKeys.country.rawValue => attributes
        self.unitAmenAc = PropertyKeys.unitAmenAc.rawValue =/ attributes
        self.unitAmenParkingReserved = PropertyKeys.unitAmenParkingReserved.rawValue =/ attributes
        self.unitAmenBalcony = PropertyKeys.unitAmenBalcony.rawValue =/ attributes
        self.unitAmenDeck = PropertyKeys.unitAmenDeck.rawValue =/ attributes
        self.unitAmenCeilingFan = PropertyKeys.unitAmenCeilingFan.rawValue =/ attributes
        self.unitAmenDishwasher = PropertyKeys.unitAmenDishwasher.rawValue =/ attributes
        self.unitAmenFireplace = PropertyKeys.unitAmenFireplace.rawValue =/ attributes
        self.unitAmenFurnished = PropertyKeys.unitAmenFurnished.rawValue =/ attributes
        self.unitAmenLaundry = PropertyKeys.unitAmenLaundry.rawValue =/ attributes
        self.unitAmenFloorCarpet = PropertyKeys.unitAmenFloorCarpet.rawValue =/ attributes
        self.unitAmenFloorHardWood = PropertyKeys.unitAmenFloorHardWood.rawValue =/ attributes
        self.unitAmenCarpet = PropertyKeys.unitAmenCarpet.rawValue =/ attributes
        self.buildAmenFitnessCenter = PropertyKeys.buildAmenFitnessCenter.rawValue =/ attributes
        self.buildAmenBizCenter = PropertyKeys.buildAmenBizCenter.rawValue =/ attributes
        self.buildAmenConcierge = PropertyKeys.buildAmenConcierge.rawValue =/ attributes
        self.buildAmenDoorman = PropertyKeys.buildAmenDoorman.rawValue =/ attributes
        self.buildAmenDryCleaning = PropertyKeys.buildAmenDryCleaning.rawValue =/ attributes
        self.buildAmenElevator = PropertyKeys.buildAmenElevator.rawValue =/ attributes
        self.buildAmenParkGarage = PropertyKeys.buildAmenParkGarage.rawValue =/ attributes
        self.buildAmenSwimPool = PropertyKeys.buildAmenSwimPool.rawValue =/ attributes
        self.buildAmenSecureEntry = PropertyKeys.buildAmenSecureEntry.rawValue =/ attributes
        self.buildAmenStorage = PropertyKeys.buildAmenStorage.rawValue =/ attributes
        self.keywords = PropertyKeys.keywords.rawValue => attributes
        self.latitude = PropertyKeys.latitude.rawValue => attributes
        self.longitude = PropertyKeys.longitude.rawValue => attributes
        self.disabled = PropertyKeys.disabled.rawValue =/ attributes
        self.deleted = PropertyKeys.deleted.rawValue =/ attributes
        self.availabilityDate = PropertyKeys.availabilityDate.rawValue => attributes
        self.bot = PropertyKeys.bot.rawValue =/ attributes
        self.selectedUnitAmenities = PropertyKeys.selectedUnitAmenities.rawValue => attributes
        self.selectedBuildingAmenities = PropertyKeys.selectedBuildingAmenities.rawValue => attributes
        
        
        
    }
    override init () {
        super.init()
    }
    
    
    class func parseArrayinToModal(withAttributes attributes : [JSON]?) -> AnyObject {
        
        var properties: [Property] = []
        
        guard let attri = attributes else {
            
            return([] as? AnyObject?)!!
        }
        for dict in attri {
            do {
                let modal = try Property(withAttributes: dict.dictionaryValue)
                properties.append(modal)
            }
            catch _ {
                
            }
        }
        return (properties as AnyObject?)!
    }
    
}








