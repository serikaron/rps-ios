//
//  font.swift
//  rps-ios
//
//  Created by serika on 2023/11/7.
//

import SwiftUI
import Combine

struct CustomText: ViewModifier {
    let size: CGFloat
    let color: Color?
    let weight: Font.Weight
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight))
            .foregroundColor(color)
    }
}
extension View {
    func customText(size: CGFloat, color: Color?, weight: Font.Weight = .regular) -> some View {
        modifier(CustomText(size: size, color: color, weight: weight))
    }
}

extension View {
    func earseToAnyView() -> AnyView {
        AnyView(self)
    }
}

struct SetupNavigationBar: ViewModifier {
    let title: String
    let backAction: () -> Void
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        backAction()
                    } label: {
                        Image.main.arrowIcon
                    }
                }
            }
    }
}

extension View {
    func setupNavigationBar(title: String, _ backAction: @escaping () -> Void) -> some View {
        modifier(SetupNavigationBar(title: title, backAction: backAction))
    }
}


struct SectionStyleModifier: ViewModifier {
    let vPadding: Double
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, vPadding)
            .padding(.horizontal, 16)
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal, 12)
    }
}
extension View {
    func sectionStyle(vPadding: Double = 20) -> some View {
        modifier(SectionStyleModifier(vPadding: vPadding))
    }
}

struct HeaderTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .customText(size: 16, color: .text.gray3, weight: .medium)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
extension View {
    func headerText() -> some View {
        modifier(HeaderTextModifier())
    }
    func itemTitle() -> some View {
        modifier(CustomText(size: 14, color: .text.gray3, weight: .regular))
    }
    func itemContent() -> some View {
        modifier(CustomText(size: 14, color: .text.gray6, weight: .regular))
    }
    func itemPlaceholder() -> some View {
        modifier(CustomText(size: 14, color: .text.grayCD, weight: .regular))
    }
}

// MARK: -

extension UIApplication {
    var key: UIWindow? {
        self.connectedScenes
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?
            .windows
            .filter({$0.isKeyWindow})
            .first
    }
}


extension UIView {
    func allSubviews() -> [UIView] {
        var subs = self.subviews
        for subview in self.subviews {
            let rec = subview.allSubviews()
            subs.append(contentsOf: rec)
        }
        return subs
    }
}
    

struct TabBarModifier {
    static func showTabBar() {
        UIApplication.shared.key?.allSubviews().forEach({ subView in
            if let view = subView as? UITabBar {
                view.isHidden = false
            }
        })
    }
    
    static func hideTabBar() {
        UIApplication.shared.key?.allSubviews().forEach({ subView in
            if let view = subView as? UITabBar {
                view.isHidden = true
                view.backgroundColor = .clear
            }
        })
    }
}

struct ShowTabBar: ViewModifier {
    func body(content: Content) -> some View {
        return content.padding(.zero).onAppear {
            TabBarModifier.showTabBar()
        }
    }
}
struct HiddenTabBar: ViewModifier {
    func body(content: Content) -> some View {
        return content.padding(.zero).onAppear {
            TabBarModifier.hideTabBar()
        }
    }
}

extension View {
    
    func showTabBar() -> some View {
        return self.modifier(ShowTabBar())
    }

    func hiddenTabBar() -> some View {
        return self.modifier(HiddenTabBar())
    }
}

// MARK: -

extension Publishers {
    // 1.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // 2.
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        // 3.
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight / 2)
            .onReceive(Publishers.keyboardHeight) { h in
                withAnimation {
                    self.keyboardHeight = h
                }
            }
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

private struct DatePickerSheetModifier: ViewModifier {
    let height: CGFloat
    var binding: Binding<Date>
    
    @State private var date = Date()
    @State private var show = false
    
    func body(content: Content) -> some View {
        content
            .onTapGesture { show = true }
            .sheet(isPresented: $show) {
                VStack {
                    HStack {
                        Text("取消")
                            .customText(size: 14, color: .text.gray6)
                            .background(.white)
                            .onTapGesture {
                                show = false
                            }
                        Spacer()
                        Text("确定")
                            .customText(size: 14, color: .text.gray3)
                            .background(.white)
                            .onTapGesture {
                                show = false
                                binding.wrappedValue = date
                            }
                    }
                    .padding()
                    DatePicker("", selection: $date, displayedComponents: [.date])
                        .datePickerStyle(.wheel)
                        .presentationDetents([.height(height)])
                        .labelsHidden()
                        .environment(\.locale, Locale.init(identifier: "zh"))
                }
        }
    }
}

private extension Binding<String> {
    func toDateBinding() -> Binding<Date> {
        Binding<Date> (
            get: { wrappedValue.toDate() ?? Date() },
            set: { wrappedValue = $0.toString() }
        )
    }
}

private extension Binding<String?> {
    func toDateBinding() -> Binding<Date> {
        Binding<Date> (
            get: { wrappedValue?.toDate() ?? Date() },
            set: { wrappedValue = $0.toString() }
        )
    }
}

extension View {
    func plugDatePicker(height: CGFloat = 350, date: Binding<Date>? = nil, str: Binding<String>? = nil, optionalStr: Binding<String?>? = nil) -> some View {
        ModifiedContent(content: self, modifier: DatePickerSheetModifier(height: height, binding: date ?? str?.toDateBinding() ?? optionalStr?.toDateBinding() ?? .constant(Date())))
    }
}

private struct PlugAreaPickerModifier: ViewModifier {
    @State private var show = false
    
    var provinceCode: Binding<Int>
    var provinceName: Binding<String>
    var cityCode: Binding<Int>
    var cityName: Binding<String>
    var areaCode: Binding<Int>
    var areaName: Binding<String>
    
    func body(content: Content) -> some View {
        content
            .onTapGesture { show = true }
            .sheet(isPresented: $show) {
                AreaPicker(
                    provinceCode: provinceCode,
                    provinceName: provinceName,
                    cityCode: cityCode,
                    cityName: cityName,
                    areaCode: areaCode,
                    areaName: areaName,
                    show: $show
                )
                .presentationDetents([.medium, .large])
            }
    }
}

extension View {
    func plugAreaPicker(
        provinceCode: Binding<Int>,
        provinceName: Binding<String>,
        cityCode: Binding<Int>,
        cityName: Binding<String>,
        areaCode: Binding<Int>,
        areaName: Binding<String>
    ) -> some View {
        ModifiedContent(content: self, modifier: PlugAreaPickerModifier(
            provinceCode: provinceCode,
            provinceName: provinceName,
            cityCode: cityCode,
            cityName: cityName,
            areaCode: areaCode,
            areaName: areaName
        ))
    }
}
