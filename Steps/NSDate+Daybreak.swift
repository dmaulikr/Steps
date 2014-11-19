//
//  NSDate+Daybreak.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2014 Adam Binsz
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

extension NSDate {
    
    // MARK: Days
    
    class func beginningOfToday() -> NSDate {
        return NSDate().beginningOfDay()
    }
    
    class func endOfToday() -> NSDate {
        return NSDate().endOfDay()
    }
    
    class func dateDaysFromNow(days: Int) -> NSDate {
        return NSDate().addDays(days)
    }
    
    func beginningOfDay() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit, fromDate: self)
        
        return calendar.dateFromComponents(components)!
    }
    
    func endOfDay() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.day = 1
        
        return calendar.dateByAddingComponents(components, toDate: self.beginningOfDay(), options: nil)!.dateByAddingTimeInterval(-1)
    }
    
    func addDays(days: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.day = days
        
        return calendar.dateByAddingComponents(components, toDate: self, options: nil)!
    }
    
    
    // MARK: Weeks
    
    class func beginningOfThisWeek() -> NSDate {
        return NSDate().beginningOfWeek()
    }
    
    class func endOfThisWeek() -> NSDate {
        return NSDate().endOfWeek()
    }
    
    class func dateWeeksFromNow(weeks: Int) -> NSDate {
        return NSDate().addWeeks(weeks)
    }
    
    func beginningOfWeek() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit | .WeekdayCalendarUnit, fromDate: self)
        
        let daysToBeginningOfWeek = components.weekday - calendar.firstWeekday
        components.day -= daysToBeginningOfWeek
        
        return calendar.dateFromComponents(components)!
    }
    
    func endOfWeek() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.weekOfMonth = 1
        
        return calendar.dateByAddingComponents(components, toDate: self.beginningOfWeek(), options: nil)!.dateByAddingTimeInterval(-1)
    }
    
    func addWeeks(weeks: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.weekOfYear = weeks
        
        return calendar.dateByAddingComponents(components, toDate: self, options: nil)!
    }
    
    
    // MARK: Months
    
    class func beginningOfThisMonth() -> NSDate {
        return NSDate().beginningOfMonth()
    }
    
    class func endOfThisMonth() -> NSDate {
        return NSDate().beginningOfMonth()
    }
    
    class func dateMonthsFromNow(months: Int) -> NSDate {
        return NSDate().addMonths(months)
    }
    
    func beginningOfMonth() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components(.YearCalendarUnit | .MonthCalendarUnit, fromDate: self)
        
        return calendar.dateFromComponents(components)!
    }
    
    func endOfMonth() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.month = 1
        
        return calendar.dateByAddingComponents(components, toDate: self.self.beginningOfMonth(), options: nil)!.dateByAddingTimeInterval(-1)
    }
    
    func addMonths(months: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.month = months
        
        return calendar.dateByAddingComponents(components, toDate: self, options: nil)!
    }
    
    // MARK: Years
    
    class func beginningOfThisYear() -> NSDate {
        return NSDate().beginningOfYear()
    }
    
    class func endOfThisYear() -> NSDate {
        return NSDate().endOfYear()
    }
    
    class func dateYearsFromNow(years: Int) -> NSDate {
        return NSDate().addYears(years)
    }
    
    func beginningOfYear() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components(.YearCalendarUnit, fromDate: self)
        
        return calendar.dateFromComponents(components)!
    }
    
    func endOfYear() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.year = 1
        
        return calendar.dateByAddingComponents(components, toDate: self.self.beginningOfYear(), options: nil)!.dateByAddingTimeInterval(-1)
    }
    
    func addYears(years: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.year = years
        
        return calendar.dateByAddingComponents(components, toDate: self, options: nil)!
    }
}