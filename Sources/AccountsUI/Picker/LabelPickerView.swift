//
//  LabelPickerView.swift
//
//
//  Created by Bastián Véliz Vega on 13-09-20.
//

import Combine
import Foundation
import SwiftUI

/// View with a label and a picker compatible with iOS / iPadOs, tvOS, macOS and watchOS
public struct LabelPickerView: View {
    @Binding var selection: Int
    @State var showPicker: Bool = true

    let title: String
    let elements: [PickerElement<String>]

    /// Default initializer
    /// - Parameters:
    ///   - title: View title
    ///   - elements: elements to be used in the Picker
    ///   - selection: Binding to picker selected index
    public init(title: String,
                elements: [PickerElement<String>],
                selection: Binding<Int>) {
        self.title = title
        self.elements = elements
        self._selection = selection
        #if os(iOS)
            self._showPicker = State<Bool>(initialValue: false)
        #endif
    }

    /**
     View body

     View with a label and a picker

      - Important:
      This view applies different logics for each OS:
        - PickerStyle:
           - In iOS, iPadOS and watchOS `WheelPickerStyle` is used.
           - In macOS `PopUpButtonPickerStyle` is used.
           - In tvOS and other OS `DefaultPickerStyle` is used.
       - Aditional label:
         - In iOS and iPadOS a label with the selected option is shown.
         - This label has a tap gesture that show/hide the wheel picker.

     */
    public var body: some View {
        VStack {
            HStack {
                Text(self.title)
                    .bold()
                    .mobilePickerLabel(self.elements[self.selection].element)
            }
            .mobileTapGesture(self.$showPicker)
            if self.showPicker {
                Picker("", selection: self.$selection) {
                    ForEach(self.elements, id: \.id) { result in
                        Text(result.element).tag(result.id)
                    }
                }
                .pickerStyle(self.pickerStyle)
                .labelsHidden()
            }
        }
    }

    var pickerStyle: some PickerStyle {
        #if os(macOS)
            return PopUpButtonPickerStyle()
        #elseif os(iOS) || os(watchOS)
            return WheelPickerStyle()
        #else
            return DefaultPickerStyle()
        #endif
    }
}

// MARK: - Private view modifiers

private struct MobileLabel: ViewModifier {
    var selectedElement: String

    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
            #if os(iOS)
                Text(self.selectedElement)
            #endif
        }
    }
}

private struct MobileTapGesture: ViewModifier {
    @Binding var showPicker: Bool

    func body(content: Content) -> some View {
        #if os(iOS)
            return content.onTapGesture(count: 1, perform: {
                self.showPicker.toggle()
            })
        #else
            return content
        #endif
    }
}

extension View {
    func mobileTapGesture(_ showPicker: Binding<Bool>) -> some View {
        return self.modifier(MobileTapGesture(showPicker: showPicker))
    }

    func mobilePickerLabel(_ selectedElement: String) -> some View {
        return self.modifier(MobileLabel(selectedElement: selectedElement))
    }
}

// MARK: - Previews

struct LabelPickerView_Previews: PreviewProvider {
    class TestViewModel: ObservableObject {
        @Published var selection: Int = 0
    }

    @ObservedObject static var viewModel = TestViewModel()

    static let elements: [PickerElement<String>] = [
        PickerElement<String>(id: 0, element: "Option 1"),
        PickerElement<String>(id: 1, element: "Option 2"),
        PickerElement<String>(id: 2, element: "Option 3"),
    ]

    static var previews: some View {
        Group {
            LabelPickerView(title: "Title", elements: self.elements, selection: self.$viewModel.selection)
        }
    }
}
