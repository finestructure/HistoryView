//
//  HistoryView.swift
//  Playgrounder
//
//  Created by Sven A. Schmidt on 11/03/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CasePaths
import CompArch
import SwiftUI


public struct HistoryView: View {
    @ObservedObject var store: Store<State, Action>
    @SwiftUI.State var targeted = false

    func rowView(for step: Step) -> AnyView {
        guard let step = store.value.history.first(where: { $0.id == step.id }) else {
            return AnyView(EmptyView())
        }
        let row = RowView.State(step: step, selected: step.id == store.value.selection?.id)
        return AnyView(
            RowView(store: self.store.view(
                value: { _ in row },
                action: { .row(IdentifiedRow(id: row.id, action: $0)) }))
        )
    }

    public var body: some View {
        let stack = VStack(alignment: .leading) {
            #if os(macOS)
            Text("History").font(.system(.headline)).padding([.leading, .top])
            #else
            Text("History").font(.system(.headline)).padding()
            #endif

            #if os(iOS)
            List(selection: store.binding(value: \.selection, action: /Action.selection)) {
                ForEach(store.value.history.reversed()) {
                    self.rowView(for: $0)
                }
            }
            #else
            List(selection: store.binding(value: \.selection, action: /Action.selection)) {
                ForEach(store.value.history.reversed(), id: \.self) {
                    self.rowView(for: $0)
                }
            }
            .onDrop(of: [uti], isTargeted: $targeted, perform: dropHandler)
            #endif

            HStack {
                Button(action: { self.store.send(.deleteTapped) }, label: {
                    #if os(iOS)
                    Image(systemName: "trash").padding()
                    #else
                    Text("Delete")
                    #endif
                })
                Spacer()
                Button(action: { self.store.send(.backTapped) }, label: {
                    #if os(iOS)
                    Image(systemName: "backward").padding()
                    #else
                    Text("←")
                    #endif
                })
                Button(action: { self.store.send(.forwardTapped) }, label: {
                    #if os(iOS)
                    Image(systemName: "forward").padding()
                    #else
                    Text("→")
                    #endif
                })
            }
            .padding()
        }

        #if os(macOS)
        return stack.frame(minWidth: 500, minHeight: 300)
        #else
        return stack
        #endif
    }
}



// MARK: - Initializers / Setup

extension HistoryView {
    public static func store(history: [Step], broadcastEnabled: Bool) -> Store<State, Action> {
        return Store(initialValue: State(history: history, broadcastEnabled: broadcastEnabled),
                     reducer: reducer)
    }

    public init(store: Store<State, Action>) { self.store = store }

    public init(history: [Step], broadcastEnabled: Bool) {
        self.store = Self.store(history: history, broadcastEnabled: broadcastEnabled)
    }
}



// MARK: - Drop handler

#if os(macOS)
extension HistoryView {
    var uti: String { "public.utf8-plain-text" }

    func dropHandler(_ items: [NSItemProvider]) -> Bool {
        guard let item = items.first else { return false }
        print(item.registeredTypeIdentifiers)
        item.loadItem(forTypeIdentifier: uti, options: nil) { (data, error) in
            DispatchQueue.main.async {
                if self.store.value.broadcastEnabled, let data = data as? Data {
                    let msg = Message(kind: .reset, action: "", state: data)
                    Transceiver.shared.broadcast(msg)
                }
            }
        }
        return true
    }
}
#endif
