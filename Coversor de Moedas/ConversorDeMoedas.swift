//
//  ConversorDeMoedas.swift
//  Conversor de Moedas
//
//  Este módulo lida com a lógica de conversão de moedas, incluindo chamadas à API ExchangeRatesAPI.io.
//  Criado por Bruno Maciel em 28/11/2024.
//

import Foundation

struct ConversorDeMoedas {
    private let apiKey = "efebc6d955f06f85ecba2d8a1490b358" // Chave da API para autenticação
    private let baseUrl = "https://api.exchangeratesapi.io/v1/latest" // URL base da API

    /// Função para buscar a taxa de câmbio usando a API
    /// - Parameters:
    ///   - from: Moeda de origem
    ///   - to: Moeda de destino
    ///   - completion: Callback com a taxa de câmbio (Double?)
    func fetchExchangeRate(from: String, to: String, completion: @escaping (Double?) -> Void) {
        // Cria a URL com os parâmetros fornecidos
        let urlString = "\(baseUrl)?access_key=\(apiKey)&symbols=\(from),\(to)"
        
        // Valida a URL gerada
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            completion(nil)
            return
        }

        // Faz a chamada HTTP para a API
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Erro ao buscar dados: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("Nenhum dado recebido")
                completion(nil)
                return
            }

            do {
                // Processa o JSON retornado pela API
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let rates = json["rates"] as? [String: Double],
                   let fromRate = rates[from],
                   let toRate = rates[to] {
                    
                    // Calcula a taxa de câmbio entre as moedas
                    let rate = toRate / fromRate
                    completion(rate)
                } else {
                    print("Erro ao processar os dados")
                    completion(nil)
                }
            } catch {
                print("Erro ao decodificar JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume() // Inicia a tarefa da URLSession
    }
}
