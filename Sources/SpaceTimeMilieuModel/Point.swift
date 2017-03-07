//
//  Point.swift
//  SpaceTimeMilieuModel
//
//  Created by Carl Brown on 2/25/17.
//
//

import Foundation
#if os(iOS)
import CoreLocation
#endif

public struct Point: Hashable {

    public static let pointKey = "pointKey"

    private static let latitudeDegreesKey = "latitudeDegreesKey"
    private static let latitudeHemisphereKey = "latitudeHemisphereKey"
    private static let longitudeDegreesKey = "longitudeDegreesKey"
    private static let longitudeHemisphereKey = "longitudeHemisphereKey"
    private static let datetimeKey = "datetimeKey"
    private static let timezoneKey = "timezoneKey"
    private static let versionKey = "versionKey"
    public static let iso8601Format = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    
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
    
    public static func decodeJSON(data:Data, dateFormatter: DateFormatter = DateFormatter()) throws -> [Point] {
        if (dateFormatter.dateFormat != Point.iso8601Format) {
            dateFormatter.dateFormat = Point.iso8601Format
        }
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return []
        }
        guard let pointArray = dict[pointKey] as? [[String: Any]] else {
            return []
        }

        return pointArray.flatMap {Point(fromDict: $0, dateFormatter: dateFormatter)}
    }
    
    public static func encodeJSON(points:[Point], dateFormatter: DateFormatter = DateFormatter()) throws -> Data {
        if (dateFormatter.dateFormat != Point.iso8601Format) {
            dateFormatter.dateFormat = Point.iso8601Format
        }
        let pointsArray : [[String: Any]] = points.flatMap { $0.toDictionary() }
        let dictToEncode: [String: Any] = [ pointKey: pointsArray ]
        return try JSONSerialization.data(withJSONObject: dictToEncode)
    }
    
    public init(lat: Double, latHemisphere:LatitudeHemisphereEnum, long: Double, longHemisphere: LongitudeHemisphereEnum, datetime: Date, timezone: String) {
        latitudeHemisphere = latHemisphere
        if (latHemisphere == .north) {
            if (lat > 0) {
                latitudeDegrees = lat
            } else {
                latitudeDegrees = lat * -1.0
            }
        } else {
            if (lat < 0) {
                latitudeDegrees = lat
            } else {
                latitudeDegrees = lat * -1.0
            }
        }
        longitudeHemisphere = longHemisphere
        if (longHemisphere == .west) {
            if (long < 0) {
                longitudeDegrees = long
            } else {
                longitudeDegrees = long * -1.0
            }
        } else {
            if (long > 0) {
                longitudeDegrees = long
            } else {
                longitudeDegrees = long * -1.0
            }
        }
        self.datetime = datetime
        self.timezone = timezone
        version = Point.currentVersion
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
    
#if os(iOS)
    public var coordinate:  CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitudeDegrees, longitudeDegrees)
    }
    
    public static func region(_ points: [Point]) -> (center: CLLocationCoordinate2D, latitudinalDelta: CLLocationDegrees, longitudinalDelta: CLLocationDegrees)? {
        guard points.count > 0 else {
            return nil
        }
        if let latMin: Double = points.map({$0.latitudeDegrees}).min(),
            let latMax: Double = points.map({$0.latitudeDegrees}).max(),
            let longMin: Double = points.map({$0.longitudeDegrees}).min(),
            let longMax: Double = points.map({$0.longitudeDegrees}).max() {
            let latDelta: Double = latMax - latMin
            let longDelta: Double = longMax - longMin
            let center = CLLocationCoordinate2DMake(latMin + latDelta/2.0, longMin + longDelta / 2.0)
            return (center, latDelta, longDelta)
        }
        return nil
    }
    
    public init(coordinate: CLLocationCoordinate2D, datetime: Date) {
        latitudeDegrees = coordinate.latitude
        longitudeDegrees = coordinate.longitude
        timezone = NSTimeZone.local.identifier
        if (latitudeDegrees > 0) {
            latitudeHemisphere = .north
        } else {
            latitudeHemisphere = .south
        }
        if (longitudeDegrees < 0) {
            longitudeHemisphere = .west
        } else {
            longitudeHemisphere = .east
        }
        self.datetime = datetime
        version = Point.currentVersion
    }

#endif
    
    
    public static func ==(lhs: Point, rhs: Point) -> Bool {
        guard lhs.version == rhs.version else { return false}
        guard lhs.latitudeDegrees == rhs.latitudeDegrees else { return false}
        guard lhs.latitudeHemisphere == rhs.latitudeHemisphere else { return false}
        guard lhs.longitudeDegrees == rhs.longitudeDegrees else { return false}
        guard lhs.longitudeHemisphere == rhs.longitudeHemisphere else { return false}
        guard lhs.datetime == rhs.datetime else { return false}
        guard lhs.timezone == rhs.timezone else { return false}
        
        return true
    }
    
    public var hashValue: Int {
        return version.hashValue ^ latitudeDegrees.hashValue ^ latitudeHemisphere.hashValue ^ longitudeDegrees.hashValue ^ longitudeHemisphere.hashValue ^ datetime.hashValue ^
            timezone.hashValue
    }


}
