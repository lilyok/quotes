//
//  NotificationSettingsView.swift
//  quotes
//
//  Created by Liliia Ivanova on 27.05.2021.
//

import SwiftUI

struct NotificationSettingsView: View {
    @State private var isExpanded: Bool = loadNotificationSettings(propertyName: "AllowNotification") as? Bool ?? false
    @State private var currentStartTime: Date = loadNotificationSettings(propertyName: "NotificationStartTime") as? Date ?? dateFormatter.date(from: "08:00")!
    @State private var currentStopTime: Date = loadNotificationSettings(propertyName: "NotificationStopTime") as? Date ?? dateFormatter.date(from: "20:00")!
    @State private var numberOfQuotes: Int = loadNotificationSettings(propertyName: "NumberOfQuotes") as? Int ?? 1

    @State private var showsStartTimePicker = false
    @State private var showsStopTimePicker = false
    
    private let animationTime = 0.3
    
    private func foldTimePickerSmoothly(isStartToggled: Bool = false, isStopToggled: Bool = false) {
        withAnimation(.linear(duration: animationTime)) {
            if isStartToggled {
                self.showsStartTimePicker.toggle()
            } else {
                self.showsStartTimePicker = false
            }
            if isStopToggled {
                self.showsStopTimePicker.toggle()
            } else {
                self.showsStopTimePicker = false
            }
        }
    }
    
    var body: some View {
        VStack {
            Toggle("Send me motivation quote", isOn: $isExpanded.animation())
                .toggleStyle(SwitchToggleStyle(tint: .black)).font(.custom("San Francisco", size: 22))
                .onChange(of: isExpanded) { value in
                    saveNotificationSettings(propertyName: "AllowNotification", propertyValue: value)
                    if value == false {
                        foldTimePickerSmoothly()
                    }
                 }
                .onTapGesture {foldTimePickerSmoothly()}
            if isExpanded {
                VStack {
                    Stepper(value: $numberOfQuotes, in: 1...12, step: 1) {
                        HStack {
                            Text("\(numberOfQuotes) quotes per day")
                            Spacer()
                        }
                        .contentShape(Rectangle()).onTapGesture {foldTimePickerSmoothly()}
                    }
                    .onChange(of: numberOfQuotes) { value in
                        saveNotificationSettings(propertyName: "NumberOfQuotes", propertyValue: value)
                        foldTimePickerSmoothly()
                    }
                    VStack {
                        HStack{
                            Spacer()
                            Text("Allowed time for notifications")
                                .font(.custom("San Francisco", size: 20)).padding(.vertical, 1)
                            Spacer()
                        }
                        .contentShape(Rectangle()).onTapGesture {foldTimePickerSmoothly()}
                        HStack{
                            Text("Start time:")
                            Spacer()
                            Text("\(dateFormatter.string(from: currentStartTime))")
                        }
                        .padding(.vertical, 1)
                        .contentShape(Rectangle()).onTapGesture {foldTimePickerSmoothly(isStartToggled: true)}
                        
                        if showsStartTimePicker {
                            DatePicker("", selection: $currentStartTime, displayedComponents: .hourAndMinute).datePickerStyle(WheelDatePickerStyle())
                                .onChange(of: currentStartTime) { value in
                                    saveNotificationSettings(propertyName: "NotificationStartTime", propertyValue: value)
                                    if value > currentStopTime {
                                        currentStopTime = value
                                        saveNotificationSettings(propertyName: "NotificationStopTime", propertyValue: value)
                                    }
                                }
                        }
                        HStack{
                            Text("Stop time:")
                            Spacer()
                            Text("\(dateFormatter.string(from: currentStopTime))")
                        }
                        .padding(.vertical, 1)
                        .contentShape(Rectangle()).onTapGesture {foldTimePickerSmoothly(isStopToggled: true)}
                        
                        if showsStopTimePicker {
                            DatePicker("", selection: $currentStopTime, in: currentStartTime..., displayedComponents: .hourAndMinute)
                                .datePickerStyle(WheelDatePickerStyle())
                                .onChange(of: currentStopTime) { value in
                                    saveNotificationSettings(propertyName: "NotificationStopTime", propertyValue: value)
                                }
                        }
                    }
                }
            }
        }.padding(20)
        .onAppear() {
            (isExpanded, currentStartTime, currentStopTime, numberOfQuotes) = loadAllNotificationSettings()
        }
    }
}

func loadAllNotificationSettings() -> (Bool, Date, Date, Int) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat =  "HH:mm"
    let isExpanded = loadNotificationSettings(propertyName: "AllowNotification") as? Bool ?? false
    let currentStartTime = loadNotificationSettings(propertyName: "NotificationStartTime") as? Date ?? dateFormatter.date(from: "08:00")!
    let currentStopTime = loadNotificationSettings(propertyName: "NotificationStopTime") as? Date ?? dateFormatter.date(from: "20:00")!
    let numberOfQuotes = loadNotificationSettings(propertyName: "NumberOfQuotes") as? Int ?? 1
    return (isExpanded, currentStartTime, currentStopTime, numberOfQuotes)
}

func saveNotificationSettings(propertyName: String, propertyValue: Any) {
    UserDefaults.standard.set(propertyValue, forKey: propertyName)
}

func loadNotificationSettings(propertyName: String) -> Any? {
    return UserDefaults.standard.object(forKey: propertyName)
}

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .none
    df.timeStyle = .short
    
    return df
}()
