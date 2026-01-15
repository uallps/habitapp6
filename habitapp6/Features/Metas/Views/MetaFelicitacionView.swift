//
//  MetaFelicitacionView.swift
//  HabitTracker
//
//  Feature: Metas - Vista de felicitación cuando se completa una meta
//

import SwiftUI

/// Vista de felicitación que aparece cuando se completa una meta
struct MetaFelicitacionView: View {
    
    let metas: [Meta]
    let onDismiss: () -> Void
    
    @State private var showAnimation = false
    @State private var confettiCounter = 0
    
    var body: some View {
        ZStack {
            // Fondo semi-transparente
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Contenido principal
            VStack(spacing: 24) {
                // Animación de celebración
                ZStack {
                    // Círculo animado de fondo
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [.green.opacity(0.3), .clear]),
                                center: .center,
                                startRadius: 0,
                                endRadius: showAnimation ? 150 : 50
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(showAnimation ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                            value: showAnimation
                        )
                    
                    // Icono principal
                    VStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                            .rotationEffect(.degrees(showAnimation ? 10 : -10))
                            .animation(
                                .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                                value: showAnimation
                            )
                        
                        // Estrellas decorativas
                        HStack(spacing: 4) {
                            ForEach(0..<3) { i in
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                    .opacity(showAnimation ? 1 : 0.5)
                                    .scaleEffect(showAnimation ? 1.2 : 0.8)
                                    .animation(
                                        .easeInOut(duration: 0.3)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(i) * 0.1),
                                        value: showAnimation
                                    )
                            }
                        }
                    }
                }
                
                // Título
                Text("🎉 ¡Felicitaciones! 🎉")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Mensaje
                Text(mensajeFelicitacion)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Lista de metas completadas
                VStack(spacing: 12) {
                    ForEach(metas) { meta in
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading) {
                                Text(meta.nombre)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(meta.descripcionObjetivo)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            MetaPeriodoChipView(periodo: meta.periodo)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.1))
                        )
                    }
                }
                .padding(.horizontal)
                
                // Botón de cerrar
                Button {
                    onDismiss()
                } label: {
                    Text("¡Genial!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.green, .blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .padding(.horizontal, 32)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            )
            .padding(24)
            .scaleEffect(showAnimation ? 1 : 0.9)
            .opacity(showAnimation ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showAnimation = true
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var mensajeFelicitacion: String {
        if metas.count == 1 {
            return "¡Has completado tu meta!"
        } else {
            return "¡Has completado \(metas.count) metas!"
        }
    }
}

/// Vista de overlay para mostrar la felicitación en TodayView
struct MetaFelicitacionOverlayView: View {
    
    @ObservedObject var viewModel: MetasCompletadasViewModel
    
    var body: some View {
        if viewModel.showingFelicitacion && !viewModel.metasCompletadas.isEmpty {
            MetaFelicitacionView(
                metas: viewModel.metasCompletadas,
                onDismiss: {
                    viewModel.cerrarFelicitacion()
                }
            )
            .transition(.opacity.combined(with: .scale))
            .zIndex(100)
        }
    }
}

/// Banner pequeño para mostrar en la parte superior cuando hay metas recién completadas
struct MetaCompletadaBannerView: View {
    
    let meta: Meta
    let onTap: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        if isVisible {
            HStack(spacing: 12) {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("¡Meta completada!")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(meta.nombre)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
            .onTapGesture {
                onTap()
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MetaFelicitacionView_Previews: PreviewProvider {
    static var previews: some View {
        let metas = [
            Meta(habitID: UUID(), nombre: "Correr 100 veces", objetivo: 100, periodo: .año),
            Meta(habitID: UUID(), nombre: "Meditar 30 días", objetivo: 30, periodo: .mes)
        ]
        
        MetaFelicitacionView(metas: metas, onDismiss: {})
    }
}
#endif
