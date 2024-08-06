//
//  QueueProcessor.swift
//
//
//  Created by 박종상 on 8/6/24.
//

import Foundation

final class QueueProcessor<T> {
    struct QueueItem {
        let element: T
        let execute: ((T) -> Void)

        init(element: T, execute: @escaping (T) -> Void) {
            self.element = element
            self.execute = execute
        }
    }

    enum Error: Swift.Error {
        case maxQueue
        case noItem
    }

    private var items: [QueueItem] = []
    private let maxQueueSize: Int
    private let locker = NSRecursiveLock()
    private var timer: DispatchSourceTimer?

    init(maxQueueSize: Int) {
        self.maxQueueSize = maxQueueSize
    }

    deinit {
        stopProcessing()
    }

    func enqueue(_ item: QueueItem) throws {
        defer {
            locker.unlock()
        }
        locker.lock()

        if items.count < maxQueueSize {
            let wasEmpty = items.isEmpty
            items.append(item)
            
            if wasEmpty {
                startProcessing()
            }
        } else {
            throw Error.maxQueue
        }
    }


    // 큐에서 항목을 소비하는 메서드
    @objc private func processQueue() {
        guard items.isEmpty == false, let item = items.first else {
            stopProcessing()
            return
        }

        item.execute(item.element)
        items.removeFirst()
    }

    // 소비 프로세스를 시작하는 메서드
    private func startProcessing() {
        guard timer == nil else { return }  // 이미 타이머가 있으면 종료하지 않음

        let queue = DispatchQueue(label: "com.sendbird.userManager.queueProcessor")
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: .seconds(1))

        timer?.setEventHandler { [weak self] in
            self?.processQueue()
        }

        timer?.resume()
    }

    // 소비 프로세스를 중지하는 메서드
    func stopProcessing() {
        timer?.cancel()
        timer = nil
    }
}
