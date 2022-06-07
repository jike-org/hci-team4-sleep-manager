//
//  CustomDatePicker.swift
//  RoutineManger
//
//  Created by 문다 on 2022/05/09.
//

import SwiftUI

struct CustomDatePicker: View {
    
    @Binding var currentDate: Date
    @ObservedObject var viewModel: HistoryViewModel
    
    // Month update on arrow button clicks
    @State var currentMonth: Int = 0
    
    func fetchMonthData() {
        viewModel.queryWeekSleep(date: "2022-06-02", offset: 3)
    }
    
    var body: some View {
        VStack() {
            
            // Days
            let days: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(extraDate()[0])
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(extraDate()[1])
                        .font(.title.bold())
                }
                
                Spacer(minLength: 0)
                
                Button {
                    withAnimation {
                        currentMonth -= 1
                    }
                } label : {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                Button {
                    withAnimation {
                        currentMonth += 1
                    }
                } label : {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            // Day View
            
            HStack() {
                ForEach(days, id: \.self) {day in
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity) // 자동 간격 최대
                }
            }
            //Dates
            // Lazy Grid
            let columns = Array(repeating: GridItem() , count: 7)
            
            LazyVGrid(columns: columns) {
                ForEach(extractDate()) { value in
                    NavigationLink (destination: HistoryView(historyDate: value, viewModel: viewModel), label: {
                        CardView(value: value)
                            .frame(height: 70, alignment: .top)
                    })
                }
            }
        }
        .onChange(of: currentMonth) { newValue in
            // updating Month
            currentDate = getCurrentMonth()
        }
        .onAppear {
            fetchMonthData()
        }
    }
    
    @ViewBuilder
    func CardView(value: DateValue) -> some View {
        HStack {
            if value.day != -1 {
                Text("\(value.day)")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .padding([.leading, .top], 10)
            }
            Spacer()
        }
    }
    
    // extraction Year and Month for display
    func extraDate() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        
        let date = formatter.string(from: currentDate)
        
        return date.components(separatedBy: " ")
    }
    
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        
        // Getting current month date
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else { return Date() }
        return currentMonth
    }
    
    func extractDate() -> [DateValue] {
        
        let calendar = Calendar.current
        
        //Getting Current Month Date
        let currentMonth = getCurrentMonth()
        
        var days = currentMonth.getAllDates().compactMap { date ->
            DateValue in
            
            //getting day
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        
        // adding offset dys to get exact week day
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in (0..<(firstWeekday - 1)) {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        return days
    }
}

// Extending Date to get Current Month Dates
extension Date {
    func getAllDates() -> [Date] {
        let calendar = Calendar.current
        
        // getting start date
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        
        let range = calendar.range(of: .day, in: .month, for: self)!
        
        // getting date
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}
