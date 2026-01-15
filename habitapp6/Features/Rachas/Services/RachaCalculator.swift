//
//  RachaCalculator.swift
//  HabitTracker
//
//  Feature: Rachas
//  Servicio para calcular rachas de hábitos
//

import Foundation

/// Protocolo para el calculador de rachas (útil para testing y SPL)
public protocol RachaCalculatorProtocol {
    func calcularRacha(para habit: Habit, instancias: [HabitInstance]) -> RachaInfo
    func calcularRachaActual(para habit: Habit, instancias: [HabitInstance]) -> Int
    func calcularMejorRacha(para habit: Habit, instancias: [HabitInstance]) -> Int
}

/// Servicio para calcular rachas de hábitos
public class RachaCalculator: RachaCalculatorProtocol {
    
    // MARK: - Singleton
    
    public static let shared = RachaCalculator()
    
    private let calendar: Calendar
    
    // MARK: - Initialization
    
    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }
    
    // MARK: - Public Methods
    
    /// Calcula toda la información de racha para un hábito
    public func calcularRacha(para habit: Habit, instancias: [HabitInstance]) -> RachaInfo {
        // Filtrar instancias de este hábito
        let instanciasHabito = instancias
            .filter { $0.habitID == habit.id }
            .sorted { $0.fecha < $1.fecha }
        
        guard !instanciasHabito.isEmpty else {
            return RachaInfo(frecuencia: habit.frecuencia)
        }
        
        // Calcular períodos según frecuencia
        let periodos = agruparPorPeriodo(instancias: instanciasHabito, frecuencia: habit.frecuencia)
        
        // Calcular rachas
        let rachaActual = calcularRachaActualDesdePeriodos(periodos, frecuencia: habit.frecuencia)
        let mejorRacha = calcularMejorRachaDesdePeriodos(periodos)
        let totalCompletados = periodos.filter { $0.completado }.count
        let totalPeriodos = periodos.count
        
        // Determinar si la racha está en riesgo
        let rachaEnRiesgo = determinarRachaEnRiesgo(periodos: periodos, frecuencia: habit.frecuencia)
        
        // Fecha de inicio de la racha actual
        let inicioRacha = calcularInicioRachaActual(periodos: periodos, rachaActual: rachaActual)
        
        return RachaInfo(
            rachaActual: rachaActual,
            mejorRacha: max(mejorRacha, rachaActual),
            inicioRachaActual: inicioRacha,
            totalCompletados: totalCompletados,
            totalPeriodos: totalPeriodos,
            rachaEnRiesgo: rachaEnRiesgo,
            frecuencia: habit.frecuencia
        )
    }
    
    /// Calcula solo la racha actual
    public func calcularRachaActual(para habit: Habit, instancias: [HabitInstance]) -> Int {
        let instanciasHabito = instancias.filter { $0.habitID == habit.id }
        let periodos = agruparPorPeriodo(instancias: instanciasHabito, frecuencia: habit.frecuencia)
        return calcularRachaActualDesdePeriodos(periodos, frecuencia: habit.frecuencia)
    }
    
    /// Calcula la mejor racha histórica
    public func calcularMejorRacha(para habit: Habit, instancias: [HabitInstance]) -> Int {
        let instanciasHabito = instancias.filter { $0.habitID == habit.id }
        let periodos = agruparPorPeriodo(instancias: instanciasHabito, frecuencia: habit.frecuencia)
        let mejorHistorica = calcularMejorRachaDesdePeriodos(periodos)
        let actual = calcularRachaActualDesdePeriodos(periodos, frecuencia: habit.frecuencia)
        return max(mejorHistorica, actual)
    }
    
    // MARK: - Private Methods
    
    /// Representa un período (día o semana) con su estado de completado
    private struct Periodo: Comparable {
        let identificador: String // "2024-01-15" para diario, "2024-W03" para semanal
        let fecha: Date
        let completado: Bool
        
        static func < (lhs: Periodo, rhs: Periodo) -> Bool {
            return lhs.fecha < rhs.fecha
        }
    }
    
    /// Agrupa las instancias por período según la frecuencia
    private func agruparPorPeriodo(instancias: [HabitInstance], frecuencia: Frecuencia) -> [Periodo] {
        var periodosDict: [String: (fecha: Date, completado: Bool)] = [:]
        
        for instancia in instancias {
            let id = identificadorPeriodo(fecha: instancia.fecha, frecuencia: frecuencia)
            
            if let existente = periodosDict[id] {
                // Si ya existe, mantener completado si alguna instancia está completada
                periodosDict[id] = (existente.fecha, existente.completado || instancia.completado)
            } else {
                periodosDict[id] = (instancia.fecha, instancia.completado)
            }
        }
        
        return periodosDict.map { Periodo(identificador: $0.key, fecha: $0.value.fecha, completado: $0.value.completado) }
            .sorted()
    }
    
    /// Genera un identificador único para el período
    private func identificadorPeriodo(fecha: Date, frecuencia: Frecuencia) -> String {
        switch frecuencia {
        case .diario:
            let components = calendar.dateComponents([.year, .month, .day], from: fecha)
            return "\(components.year!)-\(components.month!)-\(components.day!)"
            
        case .semanal:
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: fecha)
            return "\(components.yearForWeekOfYear!)-W\(components.weekOfYear!)"
        }
    }
    
    /// Calcula la racha actual desde los períodos ordenados
    private func calcularRachaActualDesdePeriodos(_ periodos: [Periodo], frecuencia: Frecuencia) -> Int {
        guard !periodos.isEmpty else { return 0 }
        
        let hoy = TimeConfiguration.shared.now
        let periodoActualId = identificadorPeriodo(fecha: hoy, frecuencia: frecuencia)
        
        // Ordenar períodos de más reciente a más antiguo
        let periodosOrdenados = periodos.sorted { $0.fecha > $1.fecha }
        
        var racha = 0
        var periodoEsperado = periodoActualId
        var fechaEsperada = hoy
        
        for periodo in periodosOrdenados {
            let periodoId = identificadorPeriodo(fecha: periodo.fecha, frecuencia: frecuencia)
            
            // Si es el período esperado
            if periodoId == periodoEsperado {
                if periodo.completado {
                    racha += 1
                    // Calcular el período anterior esperado
                    fechaEsperada = retrocederPeriodo(desde: fechaEsperada, frecuencia: frecuencia)
                    periodoEsperado = identificadorPeriodo(fecha: fechaEsperada, frecuencia: frecuencia)
                } else {
                    // Período actual no completado, verificar si hay racha desde ayer/semana pasada
                    if racha == 0 {
                        // Intentar desde el período anterior
                        fechaEsperada = retrocederPeriodo(desde: hoy, frecuencia: frecuencia)
                        periodoEsperado = identificadorPeriodo(fecha: fechaEsperada, frecuencia: frecuencia)
                        continue
                    } else {
                        break
                    }
                }
            } else if periodo.fecha < fechaEsperada {
                // Si el período es anterior al esperado, la racha se rompe
                // (hay un hueco)
                break
            }
        }
        
        return racha
    }
    
    /// Calcula la mejor racha histórica
    private func calcularMejorRachaDesdePeriodos(_ periodos: [Periodo]) -> Int {
        guard !periodos.isEmpty else { return 0 }
        
        let periodosOrdenados = periodos.sorted()
        var mejorRacha = 0
        var rachaActual = 0
        var periodoAnterior: Periodo?
        
        for periodo in periodosOrdenados {
            if periodo.completado {
                if let anterior = periodoAnterior {
                    // Verificar si es consecutivo
                    if sonConsecutivos(anterior, periodo) {
                        rachaActual += 1
                    } else {
                        rachaActual = 1
                    }
                } else {
                    rachaActual = 1
                }
                mejorRacha = max(mejorRacha, rachaActual)
                periodoAnterior = periodo
            } else {
                rachaActual = 0
                periodoAnterior = periodo
            }
        }
        
        return mejorRacha
    }
    
    /// Verifica si dos períodos son consecutivos
    private func sonConsecutivos(_ periodo1: Periodo, _ periodo2: Periodo) -> Bool {
        // Extraer componentes del identificador para determinar frecuencia
        if periodo1.identificador.contains("-W") {
            // Semanal
            let diff = calendar.dateComponents([.weekOfYear], from: periodo1.fecha, to: periodo2.fecha)
            return abs(diff.weekOfYear ?? 0) <= 1
        } else {
            // Diario
            let diff = calendar.dateComponents([.day], from: periodo1.fecha, to: periodo2.fecha)
            return abs(diff.day ?? 0) <= 1
        }
    }
    
    /// Retrocede un período según la frecuencia
    private func retrocederPeriodo(desde fecha: Date, frecuencia: Frecuencia) -> Date {
        switch frecuencia {
        case .diario:
            return calendar.date(byAdding: .day, value: -1, to: fecha) ?? fecha
        case .semanal:
            return calendar.date(byAdding: .weekOfYear, value: -1, to: fecha) ?? fecha
        }
    }
    
    /// Determina si la racha está en riesgo (período actual no completado)
    private func determinarRachaEnRiesgo(periodos: [Periodo], frecuencia: Frecuencia) -> Bool {
        let hoy = TimeConfiguration.shared.now
        let periodoActualId = identificadorPeriodo(fecha: hoy, frecuencia: frecuencia)
        
        // Buscar el período actual
        if let periodoActual = periodos.first(where: { 
            identificadorPeriodo(fecha: $0.fecha, frecuencia: frecuencia) == periodoActualId 
        }) {
            return !periodoActual.completado
        }
        
        // Si no hay período actual, la racha podría estar en riesgo
        return true
    }
    
    /// Calcula la fecha de inicio de la racha actual
    private func calcularInicioRachaActual(periodos: [Periodo], rachaActual: Int) -> Date? {
        guard rachaActual > 0 else { return nil }
        
        let periodosCompletados = periodos
            .filter { $0.completado }
            .sorted { $0.fecha > $1.fecha }
        
        guard periodosCompletados.count >= rachaActual else { return nil }
        
        // El inicio es el período más antiguo de la racha actual
        return periodosCompletados[rachaActual - 1].fecha
    }
}
