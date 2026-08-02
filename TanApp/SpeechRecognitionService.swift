import AVFoundation
import Foundation

enum ArchiveDialect: String, CaseIterable, Sendable {
    case mandarin
    case chengdu
    case zigong

    var title: String {
        switch self {
        case .mandarin:
            return "普通话"
        case .chengdu:
            return "成都话"
        case .zigong:
            return "自贡话"
        }
    }

    var recognitionNote: String {
        switch self {
        case .mandarin:
            return "普通话实时识别"
        case .chengdu:
            return "使用四川话识别能力"
        case .zigong:
            return "使用四川话识别能力"
        }
    }

    var contextHint: String {
        switch self {
        case .mandarin:
            return "当前说话方式为普通话。"
        case .chengdu:
            return "当前说话方式为四川话中的成都口音。"
        case .zigong:
            return "当前说话方式为四川话中的自贡口音。"
        }
    }
}

enum SpeechRecognitionState: Equatable {
    case idle
    case requestingPermission
    case connecting
    case listening
    case finalizing
    case failed

    var isBusy: Bool {
        switch self {
        case .requestingPermission, .connecting, .listening, .finalizing:
            return true
        case .idle, .failed:
            return false
        }
    }
}

enum SpeechRecognitionFailure: Equatable, Error {
    case permissionDenied
    case missingAPIKey
    case microphoneUnavailable
    case networkUnavailable
    case noSpeechDetected
    case microphoneSilent
    case serviceUnavailable

    var message: String {
        switch self {
        case .permissionDenied:
            return "没有麦克风权限，仍可继续使用键盘输入。"
        case .missingAPIKey:
            return "语音识别配置暂不可用，仍可继续使用键盘输入。"
        case .microphoneUnavailable:
            return "麦克风暂时不可用，请稍后重试或继续打字。"
        case .networkUnavailable:
            return "语音识别暂时无法连接，可继续打字或重试。"
        case .noSpeechDetected:
            return "没有识别到有效语音，请靠近麦克风后重试。"
        case .microphoneSilent:
#if targetEnvironment(simulator)
            return "模拟器没有收到麦克风声音，请在“输入/输出”中选择 Mac 麦克风后重试。"
#else
            return "麦克风没有收到声音，请检查输入设备后重试。"
#endif
        case .serviceUnavailable:
            return "语音识别暂时不可用，可继续打字或重试。"
        }
    }

    var offersSettings: Bool {
        self == .permissionDenied
    }
}

enum SpeechRecognitionEvent: Equatable {
    case connecting
    case ready
    case audioActivity(level: Float, totalBytes: Int)
    case partial(sentenceID: Int, text: String)
    case final(sentenceID: Int, text: String)
    case finished
    case failed(SpeechRecognitionFailure)
}

protocol SpeechRecognitionService: AnyObject {
    var eventHandler: ((SpeechRecognitionEvent) -> Void)? { get set }

    func start(dialect: ArchiveDialect)
    func stop()
    func cancel()
}

struct SpeechRecognitionCompletion: Identifiable, Equatable {
    let id = UUID()
    let text: String
}

enum SpeechTranscriptMerger {
    static func merge(existing: String, transcript: String) -> String {
        let existing = existing.trimmingCharacters(in: .whitespacesAndNewlines)
        let transcript = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !transcript.isEmpty else { return existing }
        guard !existing.isEmpty else { return transcript }

        let punctuation = CharacterSet(charactersIn: "，。！？；：,.!?;:")
        if let scalar = existing.unicodeScalars.last,
           punctuation.contains(scalar) {
            return existing + transcript
        }
        return existing + " " + transcript
    }
}

@MainActor
final class SpeechRecognitionController: ObservableObject {
    @Published private(set) var state: SpeechRecognitionState = .idle
    @Published private(set) var liveTranscript = ""
    @Published private(set) var elapsedSeconds = 0
    @Published private(set) var completion: SpeechRecognitionCompletion?
    @Published private(set) var failure: SpeechRecognitionFailure?
    @Published private(set) var audioLevel: Float = 0
    @Published private(set) var sentAudioBytes = 0
    @Published private(set) var hasReceivedTaskStarted = false
    @Published private(set) var hasReceivedResult = false
    @Published private(set) var hasDetectedVoice = false
    @Published private(set) var warningText: String?

    private let service: SpeechRecognitionService
    private var finalizedSentences: [Int: String] = [:]
    private var partialSentences: [Int: String] = [:]
    private var timerTask: Task<Void, Never>?

    init(service: SpeechRecognitionService = DashScopeSpeechRecognitionService()) {
        self.service = service
        service.eventHandler = { [weak self] event in
            Task { @MainActor in
                self?.handle(event)
            }
        }
    }

    var isRecording: Bool {
        state == .listening
    }

    var statusText: String {
        switch state {
        case .idle:
            return ""
        case .requestingPermission:
            return "正在请求麦克风权限…"
        case .connecting:
            return "正在连接语音识别服务…"
        case .listening:
            return "正在听你讲述 · \(formattedDuration)"
        case .finalizing:
            return "正在整理最后一句…"
        case .failed:
            return failure?.message ?? "语音识别暂时不可用。"
        }
    }

    var captureStatusText: String? {
        guard state == .listening else { return nil }
        if sentAudioBytes == 0 {
            return "正在等待麦克风数据"
        }
        if hasDetectedVoice {
            return hasReceivedResult ? "已收到识别文字" : "已采集到声音"
        }
        return "麦克风已连接，等待你开口"
    }

    func start(dialect: ArchiveDialect) {
        guard !state.isBusy else { return }
        resetTranscript()
        failure = nil
        completion = nil
        state = .requestingPermission
        service.start(dialect: dialect)
    }

    func stop() {
        guard state == .listening || state == .connecting else { return }
        state = .finalizing
        stopTimer()
        service.stop()
    }

    func cancel(preservingTranscript: Bool = false) {
        if preservingTranscript {
            publishCompletionIfNeeded()
        }
        stopTimer()
        service.cancel()
        state = .idle
        failure = nil
        resetTranscript()
    }

    func consumeCompletion() {
        completion = nil
        resetTranscript()
    }

    private var formattedDuration: String {
        String(format: "%02d:%02d", elapsedSeconds / 60, elapsedSeconds % 60)
    }

    private func handle(_ event: SpeechRecognitionEvent) {
        switch event {
        case .connecting:
            state = .connecting
        case .ready:
            hasReceivedTaskStarted = true
            state = .listening
            startTimer()
        case let .audioActivity(level, totalBytes):
            audioLevel = level
            sentAudioBytes = totalBytes
            if level >= 0.012 {
                hasDetectedVoice = true
                warningText = nil
            }
        case let .partial(sentenceID, text):
            hasReceivedResult = true
            warningText = nil
            partialSentences[sentenceID] = text
            refreshTranscript()
        case let .final(sentenceID, text):
            hasReceivedResult = true
            warningText = nil
            finalizedSentences[sentenceID] = text
            partialSentences.removeValue(forKey: sentenceID)
            refreshTranscript()
        case .finished:
            stopTimer()
            publishCompletionIfNeeded()
            if liveTranscript.isEmpty {
                failure = sentAudioBytes == 0 || !hasDetectedVoice
                    ? .microphoneSilent
                    : .noSpeechDetected
                state = .failed
            } else {
                state = .idle
                failure = nil
            }
        case let .failed(error):
            stopTimer()
            publishCompletionIfNeeded()
            failure = error
            state = .failed
        }
    }

    private func startTimer() {
        stopTimer()
        elapsedSeconds = 0
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled, let self else { return }
                self.elapsedSeconds += 1
                if self.elapsedSeconds >= 5,
                   !self.hasReceivedResult {
                    if self.sentAudioBytes == 0 {
#if targetEnvironment(simulator)
                        self.warningText = "没有收到音频数据，请确认模拟器已选择 Mac 麦克风。"
#else
                        self.warningText = "没有收到音频数据，请检查麦克风后重试。"
#endif
                    } else if !self.hasDetectedVoice {
                        self.warningText = "未检测到声音，请靠近麦克风后重试。"
                    } else {
                        self.warningText = "已采集到声音，正在等待识别文字…"
                    }
                }
                if self.elapsedSeconds >= 60 {
                    self.stop()
                    return
                }
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func refreshTranscript() {
        let identifiers = Set(finalizedSentences.keys).union(partialSentences.keys).sorted()
        liveTranscript = identifiers.compactMap { identifier in
            finalizedSentences[identifier] ?? partialSentences[identifier]
        }
        .joined()
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func publishCompletionIfNeeded() {
        refreshTranscript()
        guard !liveTranscript.isEmpty else { return }
        completion = SpeechRecognitionCompletion(text: liveTranscript)
    }

    private func resetTranscript() {
        finalizedSentences = [:]
        partialSentences = [:]
        liveTranscript = ""
        elapsedSeconds = 0
        audioLevel = 0
        sentAudioBytes = 0
        hasReceivedTaskStarted = false
        hasReceivedResult = false
        hasDetectedVoice = false
        warningText = nil
    }
}

final class DashScopeSpeechRecognitionService: SpeechRecognitionService {
    var eventHandler: ((SpeechRecognitionEvent) -> Void)?

    private static let endpoint = URL(string: "wss://dashscope.aliyuncs.com/api-ws/v1/inference")!

    private let queue = DispatchQueue(label: "com.tanteam.urbanecho.speech-service")
    private let audioCapture = PCM16AudioCapture()
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var taskID: String?
    private var pendingStartID: UUID?
    private var isActive = false
    private var isFinishing = false
    private var sentAudioByteCount = 0
    private var hasReceivedAudioBuffer = false
    private var captureWatchdog: DispatchWorkItem?

    func start(dialect: ArchiveDialect) {
        queue.async { [weak self] in
            guard let self, !self.isActive, self.pendingStartID == nil else { return }
            let startID = UUID()
            self.pendingStartID = startID
            self.requestPermissionAndConnect(dialect: dialect, startID: startID)
        }
    }

    func stop() {
        queue.async { [weak self] in
            self?.finishTask()
        }
    }

    func cancel() {
        queue.async { [weak self] in
            self?.pendingStartID = nil
            self?.tearDown(closeCode: .goingAway)
        }
    }

    private func requestPermissionAndConnect(dialect: ArchiveDialect, startID: UUID) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            connect(dialect: dialect, startID: startID)
        case .denied:
            pendingStartID = nil
            emit(.failed(.permissionDenied))
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                self?.queue.async {
                    guard let self, self.pendingStartID == startID else { return }
                    if granted {
                        self.connect(dialect: dialect, startID: startID)
                    } else {
                        self.pendingStartID = nil
                        self.emit(.failed(.permissionDenied))
                    }
                }
            }
        @unknown default:
            pendingStartID = nil
            emit(.failed(.microphoneUnavailable))
        }
    }

    private func connect(dialect: ArchiveDialect, startID: UUID) {
        guard pendingStartID == startID else { return }
        let configuration = LocalDashScopeConfiguration.load()
        guard let apiKey = configuration.apiKey, !apiKey.isEmpty else {
            pendingStartID = nil
            emit(.failed(.missingAPIKey))
            return
        }

        pendingStartID = nil
        isActive = true
        isFinishing = false
        sentAudioByteCount = 0
        hasReceivedAudioBuffer = false
        let identifier = UUID().uuidString.lowercased()
        taskID = identifier

        var request = URLRequest(url: Self.endpoint)
        request.timeoutInterval = 20
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("Tan-Urban-Echo-iOS", forHTTPHeaderField: "User-Agent")

        let session = URLSession(configuration: .default)
        let socket = session.webSocketTask(with: request)
        self.session = session
        webSocketTask = socket

        emit(.connecting)
        socket.resume()
        receiveNextMessage()

        do {
            let command = try DashScopeSpeechCommand.runTask(
                taskID: identifier,
                model: configuration.asrModel,
                dialect: dialect
            )
            socket.send(.string(command)) { [weak self] error in
                guard let error else { return }
                self?.queue.async {
                    guard self?.isActive == true else { return }
                    self?.fail(for: error)
                }
            }
        } catch {
            fail(with: .serviceUnavailable)
        }
    }

    private func receiveNextMessage() {
        guard let socket = webSocketTask, isActive else { return }
        socket.receive { [weak self] result in
            self?.queue.async {
                guard let self, self.isActive else { return }
                switch result {
                case let .success(message):
                    self.handle(message)
                    if self.isActive {
                        self.receiveNextMessage()
                    }
                case let .failure(error):
                    self.fail(for: error)
                }
            }
        }
    }

    private func handle(_ message: URLSessionWebSocketTask.Message) {
        let data: Data
        switch message {
        case let .string(text):
            guard let value = text.data(using: .utf8) else { return }
            data = value
        case let .data(value):
            data = value
        @unknown default:
            return
        }

        guard let envelope = try? JSONDecoder().decode(DashScopeSpeechServerEnvelope.self, from: data),
              envelope.header.taskID == taskID else {
#if DEBUG
            print("[ASR] 收到无法解析或任务不匹配的服务端事件")
#endif
            return
        }

        switch envelope.header.event {
        case "task-started":
#if DEBUG
            print("[ASR] task-started")
#endif
            startAudioCapture()
        case "result-generated":
            guard let sentence = envelope.payload?.output?.sentence,
                  !sentence.heartbeat,
                  !sentence.text.isEmpty else {
                return
            }
            if sentence.sentenceEnd {
                emit(.final(sentenceID: sentence.sentenceID, text: sentence.text))
            } else {
                emit(.partial(sentenceID: sentence.sentenceID, text: sentence.text))
            }
        case "task-finished":
#if DEBUG
            print("[ASR] task-finished")
#endif
            tearDown(closeCode: .normalClosure, shouldEmitFinished: true)
        case "task-failed":
#if DEBUG
            print("[ASR] task-failed: \(envelope.header.errorCode ?? "UNKNOWN")")
#endif
            fail(with: .serviceUnavailable)
        default:
            break
        }
    }

    private func startAudioCapture() {
        guard isActive else { return }
        do {
            try audioCapture.start { [weak self] data in
                guard let self else { return }
                self.queue.async {
                    guard self.isActive, !self.isFinishing, let socket = self.webSocketTask else { return }
                    self.hasReceivedAudioBuffer = true
                    self.sentAudioByteCount += data.count
                    self.emit(
                        .audioActivity(
                            level: Self.normalizedAudioLevel(in: data),
                            totalBytes: self.sentAudioByteCount
                        )
                    )
                    socket.send(.data(data)) { [weak self] error in
                        guard let error else { return }
                        self?.queue.async {
                            guard self?.isActive == true else { return }
                            self?.fail(for: error)
                        }
                    }
                }
            }
            emit(.ready)
            scheduleCaptureWatchdog()
        } catch {
            fail(with: .microphoneUnavailable)
        }
    }

    private func scheduleCaptureWatchdog() {
        captureWatchdog?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self,
                  self.isActive,
                  !self.isFinishing,
                  !self.hasReceivedAudioBuffer else {
                return
            }
            self.fail(with: .microphoneSilent)
        }
        captureWatchdog = workItem
        queue.asyncAfter(deadline: .now() + 4, execute: workItem)
    }

    private func finishTask() {
        guard isActive, !isFinishing else { return }
        isFinishing = true
        audioCapture.stop()

        guard let identifier = taskID, let socket = webSocketTask else {
            tearDown(closeCode: .normalClosure, shouldEmitFinished: true)
            return
        }

        do {
            let command = try DashScopeSpeechCommand.finishTask(taskID: identifier)
            socket.send(.string(command)) { [weak self] error in
                guard let error else { return }
                self?.queue.async {
                    guard self?.isActive == true else { return }
                    self?.fail(for: error)
                }
            }
            queue.asyncAfter(deadline: .now() + 6) { [weak self] in
                guard let self, self.isActive, self.isFinishing else { return }
                self.tearDown(closeCode: .normalClosure, shouldEmitFinished: true)
            }
        } catch {
            tearDown(closeCode: .normalClosure, shouldEmitFinished: true)
        }
    }

    private func fail(for error: Error) {
        let failure: SpeechRecognitionFailure
        if let urlError = error as? URLError,
           [.notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotConnectToHost, .dnsLookupFailed]
            .contains(urlError.code) {
            failure = .networkUnavailable
        } else {
            failure = .serviceUnavailable
        }
        fail(with: failure)
    }

    private func fail(with failure: SpeechRecognitionFailure) {
        tearDown(closeCode: .goingAway)
        emit(.failed(failure))
    }

    private func tearDown(
        closeCode: URLSessionWebSocketTask.CloseCode,
        shouldEmitFinished: Bool = false
    ) {
        captureWatchdog?.cancel()
        captureWatchdog = nil
        audioCapture.stop()
        webSocketTask?.cancel(with: closeCode, reason: nil)
        session?.invalidateAndCancel()
        webSocketTask = nil
        session = nil
        taskID = nil
        pendingStartID = nil
        isActive = false
        isFinishing = false
        if shouldEmitFinished {
            emit(.finished)
        }
    }

    private func emit(_ event: SpeechRecognitionEvent) {
        DispatchQueue.main.async { [weak self] in
            self?.eventHandler?(event)
        }
    }

    private static func normalizedAudioLevel(in data: Data) -> Float {
        guard data.count >= MemoryLayout<Int16>.size else { return 0 }
        return data.withUnsafeBytes { rawBuffer in
            let samples = rawBuffer.bindMemory(to: Int16.self)
            guard !samples.isEmpty else { return 0 }
            var sum: Double = 0
            for sample in samples {
                let normalized = Double(sample) / Double(Int16.max)
                sum += normalized * normalized
            }
            return Float(min(1, sqrt(sum / Double(samples.count)) * 5))
        }
    }
}

private enum DashScopeSpeechCommand {
    static func runTask(
        taskID: String,
        model: String,
        dialect: ArchiveDialect
    ) throws -> String {
        _ = dialect
        let object: [String: Any] = [
            "header": [
                "action": "run-task",
                "task_id": taskID,
                "streaming": "duplex"
            ],
            "payload": [
                "task_group": "audio",
                "task": "asr",
                "function": "recognition",
                "model": model,
                "parameters": [
                    "format": "pcm",
                    "sample_rate": 16_000
                ],
                "input": [:] as [String: String]
            ]
        ]
        return try jsonString(from: object)
    }

    static func finishTask(taskID: String) throws -> String {
        try jsonString(
            from: [
                "header": [
                    "action": "finish-task",
                    "task_id": taskID,
                    "streaming": "duplex"
                ],
                "payload": [
                    "input": [:] as [String: String]
                ]
            ]
        )
    }

    private static func jsonString(from object: [String: Any]) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: object)
        guard let text = String(data: data, encoding: .utf8) else {
            throw SpeechRecognitionFailure.serviceUnavailable
        }
        return text
    }
}

struct DashScopeSpeechServerEnvelope: Decodable {
    var header: Header
    var payload: Payload?

    struct Header: Decodable {
        var taskID: String
        var event: String
        var errorCode: String?
        var errorMessage: String?

        enum CodingKeys: String, CodingKey {
            case taskID = "task_id"
            case event
            case errorCode = "error_code"
            case errorMessage = "error_message"
        }
    }

    struct Payload: Decodable {
        var output: Output?
    }

    struct Output: Decodable {
        var sentence: Sentence?
    }

    struct Sentence: Decodable {
        var text: String
        var heartbeat: Bool
        var sentenceEnd: Bool
        var sentenceID: Int

        enum CodingKeys: String, CodingKey {
            case text
            case heartbeat
            case sentenceEnd = "sentence_end"
            case sentenceID = "sentence_id"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
            heartbeat = try container.decodeIfPresent(Bool.self, forKey: .heartbeat) ?? false
            sentenceEnd = try container.decodeIfPresent(Bool.self, forKey: .sentenceEnd) ?? false
            sentenceID = try container.decodeIfPresent(Int.self, forKey: .sentenceID) ?? 0
        }
    }
}

private final class PCM16AudioCapture {
    private let engine = AVAudioEngine()
    private var converter: AVAudioConverter?
    private var isRunning = false

    func start(onAudioData: @escaping (Data) -> Void) throws {
        guard !isRunning else { return }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .measurement,
            options: [.defaultToSpeaker, .allowBluetoothHFP]
        )
        if session.preferredInput == nil,
           let builtInMicrophone = session.availableInputs?.first(where: {
               $0.portType == .builtInMic
           }) {
            try? session.setPreferredInput(builtInMicrophone)
        }
        try session.setPreferredSampleRate(16_000)
        try session.setPreferredIOBufferDuration(0.1)
        try session.setActive(true)

        guard !session.currentRoute.inputs.isEmpty else {
            throw SpeechRecognitionFailure.microphoneUnavailable
        }

        engine.stop()
        engine.reset()
        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        guard inputFormat.sampleRate > 0,
              inputFormat.channelCount > 0,
              let targetFormat = AVAudioFormat(
                commonFormat: .pcmFormatInt16,
                sampleRate: 16_000,
                channels: 1,
                interleaved: true
              ),
              let converter = AVAudioConverter(from: inputFormat, to: targetFormat) else {
            throw SpeechRecognitionFailure.microphoneUnavailable
        }
        self.converter = converter

        inputNode.installTap(onBus: 0, bufferSize: 4_096, format: inputFormat) { [weak self] buffer, _ in
            guard let data = self?.convert(buffer, using: converter, targetFormat: targetFormat),
                  !data.isEmpty else {
                return
            }
            onAudioData(data)
        }

        engine.prepare()
        try engine.start()
        isRunning = true
    }

    func stop() {
        guard isRunning || converter != nil else { return }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        engine.reset()
        converter = nil
        isRunning = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func convert(
        _ buffer: AVAudioPCMBuffer,
        using converter: AVAudioConverter,
        targetFormat: AVAudioFormat
    ) -> Data? {
        let ratio = targetFormat.sampleRate / buffer.format.sampleRate
        let capacity = AVAudioFrameCount((Double(buffer.frameLength) * ratio).rounded(.up)) + 1
        guard let output = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: capacity) else {
            return nil
        }

        var didProvideInput = false
        var conversionError: NSError?
        let status = converter.convert(to: output, error: &conversionError) { _, inputStatus in
            if didProvideInput {
                inputStatus.pointee = .noDataNow
                return nil
            }
            didProvideInput = true
            inputStatus.pointee = .haveData
            return buffer
        }

        guard conversionError == nil,
              status != .error,
              output.frameLength > 0,
              let audioData = output.audioBufferList.pointee.mBuffers.mData else {
            return nil
        }
        return Data(
            bytes: audioData,
            count: Int(output.audioBufferList.pointee.mBuffers.mDataByteSize)
        )
    }
}
