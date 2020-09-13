//
//  SegmentedLabelView.swift
//
//
//  Created by Bastián Véliz Vega on 13-09-20.
//

import Combine
import Foundation
import SwiftUI

@available(watchOS,
           unavailable,
           message: "SegmentedLabelView is not available in watchOS")
public struct SegmentedLabelView: View {
    let title: String
    let elements: [PickerElement<String>]
    @Binding private var selection: Int

    /// Default initializer
    /// - Parameters:
    ///   - title: view title
    ///   - elements: elements to be shown in the picker
    ///   - selection: Binding to picker selected index
    public init(title: String,
                elements: [PickerElement<String>],
                selection: Binding<Int>) {
        self.title = title
        self.elements = elements
        self._selection = selection
    }

    /// View body
    public var body: some View {
        VStack(alignment: .leading) {
            Text(self.title).bold()
            Picker(self.title, selection: self.$selection) {
                ForEach(self.elements, id: \.id) { result in
                    Text(result.element).tag(result.id)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .labelsHidden()
        }
    }
}

@available(watchOS,
           unavailable,
           message: "SegmentedLabelView is not available in watchOS")
struct SegmentedLabelView_Previews: PreviewProvider {
    @ObservedObject static var viewModel = TestViewModel()

    static let elements: [PickerElement<String>] = [
        PickerElement<String>(id: 0, element: "Option 1"),
        PickerElement<String>(id: 1, element: "Option 2"),
        PickerElement<String>(id: 2, element: "Option 3"),
    ]
    static var previews: some View {
        Group {
            SegmentedLabelView(title: "Title", elements: self.elements, selection: self.$viewModel.selection)
            Form {
                SegmentedLabelView(title: "Title", elements: self.elements, selection: self.$viewModel.selection)
            }
        }
    }

    class TestViewModel: ObservableObject, Identifiable {
        let id = UUID()
        let objectWillChange = PassthroughSubject<TestViewModel, Never>()

        var selection: Int = 0 {
            didSet {
                self.objectWillChange.send(self)
            }
        }
    }
}
