//
//  _180941Tests.swift
//  3180941Tests
//
//  Created by student01 on 2026/3/23.
//

import Testing
@testable import TanApp

struct _180941Tests {

    @Test func example() async throws {
        #expect(!MockArchiveData.archives.isEmpty)
        #expect(MockArchiveData.archives.allSatisfy { !$0.historicalStops.isEmpty })
    }

    @Test func xilianQuickQuestionKeepsLocalFallback() async throws {
        let reply = XilianCopy.reply(
            to: .nearby,
            selectedArchive: nil,
            nearbyArchives: MockArchiveData.archives
        )

        #expect(reply.contains("伙伴"))
        #expect(reply.contains("\(MockArchiveData.archives.count)"))
    }

    @Test func xilianRedirectsClearlyUnrelatedQuestions() async throws {
        let reply = try await XilianChatAgent().reply(
            to: "帮我写代码",
            selectedArchive: nil,
            nearbyArchives: MockArchiveData.archives,
            currentPage: .map
        )

        #expect(reply == "伙伴，这个问题我可能帮不上太多。不过我可以陪你看看附近的摊位故事。")
    }

}
