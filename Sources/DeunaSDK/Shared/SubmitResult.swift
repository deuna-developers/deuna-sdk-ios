//
//  SubmitResult.swift
//  DeunaSDK
//
//  Created by deuna on 27/3/25.
//

import Foundation

public class SubmitResult: Codable {
    public let status: Status
    public let message: String?
    
    init(status: Status, message: String? = nil) {
        self.status = status
        self.message = message
    }
    
    public enum Status: String, Codable {
        case success
        case error
    }
    
    
    // Método estático para conversión con manejo de errores
      static func from(dictionary: Json) -> SubmitResult {
          do {
              let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
              let decoder = JSONDecoder()
              return try decoder.decode(SubmitResult.self, from: jsonData)
          } catch {
              // Si falla, retornamos un SubmitResult con error
              return SubmitResult(
                  status: .error,
                  message: "Error al procesar la solicitud"
              )
          }
      }
}
