//
//  AGMPredefinedResponsesStorage.swift
//
//
//  Created by Alex Golovenkov on 26.12.2021.
//

import Foundation

class AGMPredefinedResponsesStorage {
    struct PredefinedResponse {
        let url: URL
        let response: AGMockServer.CustomResponse
    }

    private var storage: [PredefinedResponse] = []
    private let storageLock = NSLock()

    func addResponse(_ response: AGMockServer.CustomResponse, for url: URL) {
        storageLock.lock(); defer { storageLock.unlock() }
        storage.append(PredefinedResponse(url: url, response: response))
    }

    func response(for url: URL) -> AGMockServer.CustomResponse? {
        storageLock.lock(); defer { storageLock.unlock() }
        return storage.first { $0.url == url }?.response
    }

    func removeResponse(for url: URL) {
        storageLock.lock(); defer { storageLock.unlock() }
        guard let index = storage.firstIndex(where: { $0.url == url }) else {
            return
        }
        storage.remove(at: index)
    }
}
