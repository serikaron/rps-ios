//
//  DictTypePicker.swift
//  rps-ios
//
//  Created by serika on 2024/3/16.
//

import SwiftUI

struct DictTypePicker<T: CaseIterable & HasLabel & Hashable>: View {
    @State private var val: T
    
    init(binding: Binding<T>, show: Binding<Bool>) {
        self.val = binding.wrappedValue
        self.binding = binding
        self.show = show
    }
    
    private var binding: Binding<T>
    private var show: Binding<Bool>
    
    var body: some View {
        VStack {
            HStack {
                Text("取消")
                    .customText(size: 14, color: .text.gray6)
                    .background(.white)
                    .onTapGesture {
                        show.wrappedValue = false
                    }
                Spacer()
                Text("确定")
                    .customText(size: 14, color: .text.gray3)
                    .background(.white)
                    .onTapGesture {
                        show.wrappedValue = false
                        binding.wrappedValue = val
                    }
            }
            
            Picker("", selection: $val) {
                ForEach(list.indices, id: \.self) { idx in
                    Text(list[idx].label)
                        .tag(list[idx])
                }
            }
            .pickerStyle(.wheel)
        }
        .padding()
    }
    
    private var list: [T] {
        T.allCases as! [T]
    }
}

#Preview {
    DictTypePicker<DictType.Orientation>(binding: .constant(._1), show: .constant(false))
}
