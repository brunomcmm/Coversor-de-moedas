//
//  ExchangeRateChart.swift
//  Conversor de Moedas
//
//  Este módulo gerencia o componente do gráfico para exibir a variação das taxas de câmbio.
//  Criado por Bruno Maciel.
//

import SwiftUI
import Charts

struct ExchangeRateChartView: View {
    let rates: [Double]
    let dates: [String] // Datas correspondentes às taxas

    var body: some View {
        Chart {
            // Gráfico de linha com interpolação suave
            ForEach(Array(rates.enumerated()), id: \.offset) { index, rate in
                LineMark(
                    x: .value("Data", dates[safe: index] ?? ""),
                    y: .value("Taxa", rate)
                )
                .interpolationMethod(.catmullRom) // Linha suave
                .foregroundStyle(rate > (rates.first ?? 0) ? .green : .red) // Cor baseada no valor inicial
                .lineStyle(StrokeStyle(lineWidth: 2)) // Define a espessura da linha
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel {
                    Text("\(value.as(Double.self) ?? 0.0, specifier: "%.2f")")
                        .font(.footnote) // Ajusta o tamanho da fonte do eixo Y
                        .foregroundColor(.secondary) // Cor secundária
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: Array(stride(from: 0, to: dates.count, by: max(1, dates.count / 6)))) { value in
                AxisValueLabel {
                    if let index = value.as(Int.self), index < dates.count {
                        Text(dates[index])
                            .font(.footnote) // Ajusta o tamanho da fonte do eixo X
                            .foregroundColor(.secondary) // Cor secundária
                    }
                }
            }
        }
        .chartYScale(domain: calculateYAxisDomain()) // Ajusta o domínio do eixo Y
        .frame(height: 250) // Altura do gráfico
        .padding() // Adiciona espaçamento ao redor do gráfico
    }

    /// Calcula o domínio do eixo Y com base nos valores
    private func calculateYAxisDomain() -> ClosedRange<Double> {
        let minRate = rates.min() ?? 0.0
        let maxRate = rates.max() ?? 1.0
        let padding = (maxRate - minRate) * 0.1
        return (minRate - padding)...(maxRate + padding)
    }
}

// Extensão para acessar arrays de forma segura
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
