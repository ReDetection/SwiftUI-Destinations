import Foundation

extension Date {
    func toUTC() -> Date {
        return Calendar.current.date(byAdding: .second, value: -TimeZone.current.secondsFromGMT(), to: self)!
    }
    
    func toLocalTimeZone() -> Date {
        return Calendar.current.date(byAdding: .second, value: TimeZone.current.secondsFromGMT(), to: self)!
    }
    
    var isYesterday: Bool {
        return Calendar.current.isDate(self, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: self)!)
    }
}
