//
//  Point.swift
//  SpaceTimeMilieuModel
//
//  Created by Carl Brown on 2/25/17.
//
//

import Foundation

public struct Point {
    public static let pointKey = "pointKey"

    private static let latitudeDegreesKey = "latitudeDegreesKey"
    private static let latitudeHemisphereKey = "latitudeHemisphereKey"
    private static let longitudeDegreesKey = "longitudeDegreesKey"
    private static let longitudeHemisphereKey = "longitudeHemisphereKey"
    private static let datetimeKey = "datetimeKey"
    private static let timezoneKey = "timezoneKey"
    private static let versionKey = "versionKey"
    private static let iso8601Format = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    
    private static let currentVersion = 1

    
    public enum LatitudeHemisphereEnum: String {
        case north = "N"
        case south = "S"
    }
    public let latitudeDegrees: Double
    public let latitudeHemisphere: LatitudeHemisphereEnum
    public enum LongitudeHemisphereEnum: String {
        case east = "E"
        case west = "W"
    }
    public let longitudeDegrees: Double
    public let longitudeHemisphere: LongitudeHemisphereEnum

    public let datetime: Date
    public let timezone: String
    
    public let version: Int
    
    public init(lat: Double, latHemisphere:LatitudeHemisphereEnum, long: Double, longHemisphere: LongitudeHemisphereEnum, datetime: Date, timezone: String) {
        latitudeDegrees = lat
        latitudeHemisphere = latHemisphere
        longitudeDegrees = long
        longitudeHemisphere = longHemisphere
        self.datetime = datetime
        self.timezone = timezone
        version = Point.currentVersion
    }
    
    public init?(fromJSON: Data, dateFormatter: DateFormatter = DateFormatter()) {
        if (dateFormatter.dateFormat != Point.iso8601Format) {
            dateFormatter.dateFormat = Point.iso8601Format
        }
        do {
            let obj = try JSONSerialization.jsonObject(with: fromJSON)
            guard
                let dict = obj as? [String: Any],
                let lat = dict[Point.latitudeDegreesKey] as? Double,
                let long = dict[Point.longitudeDegreesKey] as? Double,
                let latHemiString = dict[Point.latitudeHemisphereKey] as? String,
                let latitudeHemisphere = Point.LatitudeHemisphereEnum(rawValue: latHemiString),
                let longHemiString = dict[Point.longitudeHemisphereKey] as? String,
                let longitudeHemisphere = Point.LongitudeHemisphereEnum(rawValue: longHemiString),
                let datetimeString = dict[Point.datetimeKey] as? String,
                let datetime = dateFormatter.date(from: datetimeString),
                let timezone = dict[Point.timezoneKey] as? String,
                let version = dict[Point.versionKey] as? Int,
                version == Point.currentVersion
            else {
                    print ("Invalid JSON: \(fromJSON)")
                    return nil
            }
            latitudeDegrees = lat
            self.latitudeHemisphere = latitudeHemisphere
            longitudeDegrees = long
            self.longitudeHemisphere = longitudeHemisphere
            self.datetime = datetime
            self.timezone = timezone
            self.version = version
        } catch {
            print("\(error)")
            return nil
        }
        
    }
    
    public init?(fromDict dict: [String: Any], dateFormatter: DateFormatter = DateFormatter()) {
        if (dateFormatter.dateFormat != Point.iso8601Format) {
            dateFormatter.dateFormat = Point.iso8601Format
        }
        guard
            let lat = dict[Point.latitudeDegreesKey] as? Double,
            let long = dict[Point.longitudeDegreesKey] as? Double,
            let latHemiString = dict[Point.latitudeHemisphereKey] as? String,
            let latitudeHemisphere = Point.LatitudeHemisphereEnum(rawValue: latHemiString),
            let longHemiString = dict[Point.longitudeHemisphereKey] as? String,
            let longitudeHemisphere = Point.LongitudeHemisphereEnum(rawValue: longHemiString),
            let datetimeString = dict[Point.datetimeKey] as? String,
            let datetime = dateFormatter.date(from: datetimeString),
            let timezone = dict[Point.timezoneKey] as? String,
            let version = dict[Point.versionKey] as? Int,
            version == Point.currentVersion
            else {
                print ("Invalid Dictionary: \(dict)")
                return nil
        }
        latitudeDegrees = lat
        self.latitudeHemisphere = latitudeHemisphere
        longitudeDegrees = long
        self.longitudeHemisphere = longitudeHemisphere
        self.datetime = datetime
        self.timezone = timezone
        self.version = version
    }
    
    public func toDictionary(_ dateFormatter: DateFormatter = DateFormatter()) -> [String: Any] {
        if (dateFormatter.dateFormat != Point.iso8601Format) {
            dateFormatter.dateFormat = Point.iso8601Format
        }
        return [
            Point.latitudeDegreesKey: latitudeDegrees,
            Point.latitudeHemisphereKey: latitudeHemisphere.rawValue,
            Point.longitudeDegreesKey: longitudeDegrees,
            Point.longitudeHemisphereKey: longitudeHemisphere.rawValue,
            Point.timezoneKey: timezone,
            Point.datetimeKey: dateFormatter.string(from: datetime),
            Point.versionKey: version
        ]
    }
    
    public func toJSON(dateFormatter: DateFormatter = DateFormatter()) throws -> Data  {
        if (dateFormatter.dateFormat != Point.iso8601Format) {
            dateFormatter.dateFormat = Point.iso8601Format
        }
        return try JSONSerialization.data(withJSONObject: self.toDictionary(dateFormatter))
    }
}
