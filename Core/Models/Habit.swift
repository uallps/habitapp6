import Foundation
import SwiftData

@Model 
class Habit: Identifiable {
  let id: UUID
  var name: String
  var frequency: Frequency
  var reminderFrenquency: Frequency?
  var reminderHour: DateComponents?

  init(name: String, frequency: Frequency, reminderFrenquency: Frequency? = nil, reminderHour: DateComponents? = nil) {
    self.id = UUID()
    self.name = name
    self.frequency = frequency
    self.reminderFrenquency = reminderFrenquency
    self.reminderHour = reminderHour
  }

}

enum Frequency: String {
  case daily, weekly, monthly
}