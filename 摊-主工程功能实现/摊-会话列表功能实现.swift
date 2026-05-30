//
//  ConversationListView.swift
//  3180941
//
//  Created by student01 on 2026/3/29.
//

import SwiftUI

struct ConversationListView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject private var store: ConversationStore

    var body: some View {
        List {
            ForEach(store.conversations) { conv in
                NavigationLink(value: conv.id) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(conv.title)
                        Text(conv.createdAt, format: .dateTime.day().month().hour().minute())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .contextMenu {
                    Button(role: .destructive) {
                        store.deleteConversation(id: conv.id)
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("聊天")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // 预留
                } label: {
                    Image(systemName: "line.3.horizontal")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let id = store.createConversation()
                    path.append(id)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct ConversationListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ConversationListView(path: .constant(NavigationPath()))
        }
        .environmentObject(ConversationStore())
    }
}
