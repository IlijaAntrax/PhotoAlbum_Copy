//
//  Date+.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 4/6/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation

extension String
{
    func getDate() -> Date?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        if let string = self.components(separatedBy: " +").first
        {
            return dateFormatter.date(from: string)
        }
        return nil
    }
}
