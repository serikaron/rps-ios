//
//  YearMonthPicker.swift
//  rps-ios
//
//  Created by serika on 2023/11/20.
//

import SwiftUI


struct YearMonthPicker: View {
    @Binding var dateString: String?
    @Binding var shown: Bool
    
    @State private var year: String
    
    private let months = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
    
    private let orgYear: String
    private let orgMonth: Int
    
    init(dateString: Binding<String?>, shown: Binding<Bool>) {
        self._dateString = dateString
        self._shown = shown
        
        if let date = dateString.wrappedValue?.toDate(format: "YYYY-MM") {
            self.orgYear = date.toString(format: "YYYY")
            self.year = date.toString(format: "YYYY")
            
            let month = date.toString(format: "MM")
            self.orgMonth = Int(month) ?? 0
        } else {
            self.year = Date().toString(format: "YYYY")
            self.orgYear = ""
            self.orgMonth = 0
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Image.main.arrowIcon
                    .resizable()
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        guard var y = Int(year) else { return }
                        y -= 1
                        y = max(1000, y)
                        year = "\(y)"
                    }
                TextField("", text: $year)
                    .customText(size: 16, color: .text.gray3)
                    .frame(width: 100)
                    .multilineTextAlignment(.center)
                Image.main.arrowIcon
                    .resizable()
                    .frame(width: 20, height: 20)
                    .rotationEffect(Angle(degrees: 180))
                    .onTapGesture {
                        guard var y = Int(year) else { return }
                        y += 1
                        y = min(3000, y)
                        year = "\(y)"
                    }
            }
            VStack(spacing: 0) {
                ForEach(1...3, id: \.self) { row in
                    HStack {
                        ForEach((row-1)*4+1...row*4, id: \.self) { i in
                            Button {
                                dateString = "\(year)-\(String(format: "%02d", i))"
                                shown = false
                            } label: {
                                Text(months[i-1])
                                    .customText(size: 16, color: textColor(month: i))
                                    .frame(width: 60, height: 60)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 10)
    }
    
    private func textColor(month: Int) -> Color {
        guard year == orgYear else { return .text.gray3 }
        return month == orgMonth ? .main : .text.gray3
    }
}

struct YearMonthButton: View {
    let placeholder: String
    @Binding var isShown: Bool
    @Binding var time: String?
    
    var body: some View {
        HStack {
            Image.main.calendarIcon
            Text(time ?? placeholder)
                .customText(size: 14, color: time == nil ? .text.grayCD : .text.gray3)
        }
        .padding(7)
        .frame(width: 119)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.hex("#F2F2F2"), lineWidth: 1)
        )
        .plugDatePicker(optionalStr: $time)
//        .alwaysPopover(isPresented: $isShown) {
//            YearMonthPicker(dateString: $time, shown: $isShown)
//        }
    }
}

#Preview("YearMonthPicker") {
    YearMonthPicker(dateString: .constant("2016-01"), shown: .constant(false))
}
