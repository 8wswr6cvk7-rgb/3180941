//
//  ChatView.swift
//  3180941
//
//  Created by student01 on 2026/3/29.
//

import PhotosUI
import SwiftUI
import UIKit

struct ChatView: View {
    let conversationId: UUID
    @EnvironmentObject private var store: ConversationStore
    @StateObject private var viewModel: ChatViewModel
    @State private var inputText = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?
    @State private var selectedImageBase64: String?
    /// 用系统 scrollPosition 跟到底部，避免 ScrollViewReader + scrollTo 在布局未完成时触发 CoreGraphics NaN
    @State private var scrollAnchorId: UUID?

    init(conversationId: UUID, store: ConversationStore) {
        self.conversationId = conversationId
        _viewModel = StateObject(wrappedValue: ChatViewModel(conversationId: conversationId, store: store))
    }

    private var messages: [Message] {
        store.conversation(id: conversationId)?.messages ?? []
    }

    private var navigationTitle: String {
        store.conversation(id: conversationId)?.title ?? "聊天"
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("服务", selection: $viewModel.serviceProvider) {
                ForEach(ChatViewModel.ServiceProvider.allCases, id: \.self) { provider in
                    Text(provider.rawValue).tag(provider)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .scrollPosition(id: $scrollAnchorId, anchor: .bottom)
            .onChange(of: messages.count) { _, _ in
                scrollAnchorId = messages.last?.id
            }
            .onAppear {
                scrollAnchorId = messages.last?.id
            }

            Divider()

            VStack(spacing: 8) {
                if let selectedUIImage {
                    HStack {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: selectedUIImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 88, height: 88)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            Button {
                                clearSelectedImage()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.white, .black.opacity(0.7))
                                    .font(.title3)
                            }
                            .offset(x: 8, y: -8)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                }

                HStack(alignment: .bottom, spacing: 8) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "photo")
                            .font(.title3)
                    }

                    Button {
                        if let image = UIPasteboard.general.image {
                            setSelectedImage(image)
                        }
                    } label: {
                        Image(systemName: "doc.on.clipboard")
                            .font(.title3)
                    }

                    TextField("输入消息…", text: $inputText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(1 ... 6)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onTapGesture(count: 2) {
                            if let image = UIPasteboard.general.image {
                                setSelectedImage(image)
                            }
                        }

                    if viewModel.isLoading {
                        ProgressView()
                            .padding(8)
                    } else {
                        Button {
                            let text = inputText
                            let imageBase64 = selectedImageBase64
                            inputText = ""
                            clearSelectedImage()
                            Task { await viewModel.sendUserMessage(text, imageBase64: imageBase64) }
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                        }
                        .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImageBase64 == nil)
                    }
                }
                .padding(.horizontal, 12)
            }
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    setSelectedImage(image)
                }
            }
        }
        .alert("错误", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("好", role: .cancel) { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func setSelectedImage(_ image: UIImage) {
        selectedUIImage = image
        let imageData = image.jpegData(compressionQuality: 0.8) ?? image.pngData()
        selectedImageBase64 = imageData?.base64EncodedString()
    }

    private func clearSelectedImage() {
        selectedUIImage = nil
        selectedImageBase64 = nil
        selectedPhotoItem = nil
    }

}

private struct MessageBubble: View {
    let message: Message

    var body: some View {
        switch message.role {
        case .user:
            HStack {
                Spacer(minLength: 48)
                bubbleContent
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .id(message.id)
        case .assistant:
            HStack {
                bubbleContent
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray5))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                Spacer(minLength: 48)
            }
            .id(message.id)
        }
    }

    @ViewBuilder
    private var bubbleContent: some View {
        if let image = decodedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 140)
                .clipped()
        } else {
            Text(message.content)
        }
    }

    private var decodedImage: UIImage? {
        guard let imageBase64 = message.imageBase64,
              let data = Data(base64Encoded: imageBase64),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
