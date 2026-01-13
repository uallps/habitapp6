
import SwiftUI

struct LogrosView: View {
    @StateObject private var viewModel = LogrosViewModel()
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "trophy.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                            .shadow(color: .orange.opacity(0.3), radius: 10, y: 5)
                        
                        Text("Mis Logros")
                            .font(.largeTitle).fontWeight(.bold)
                        
                        Text("Has desbloqueado \(viewModel.desbloqueadosCount) de \(viewModel.totalCount)")
                            .font(.subheadline).foregroundColor(.secondary)
                            .padding(.horizontal, 12).padding(.vertical, 4)
                            .background(Capsule().fill(Color.gray.opacity(0.1)))
                    }
                    .padding(.top, 20)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.logros) { logro in
                            LogroCard(logro: logro)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            
            if viewModel.showingFelicitacion, let logro = viewModel.logroParaMostrar {
                Color.black.opacity(0.4).ignoresSafeArea()
                    .onTapGesture { viewModel.cerrarFelicitacion() }
                    .zIndex(1)
                
                FelicitacionCard(logro: logro) { viewModel.cerrarFelicitacion() }
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(2)
            }
        }
        .navigationTitle("Logros")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LogroCard: View {
    let logro: Logro
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(logro.desbloqueado ? logro.tipo.color.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                Image(systemName: logro.desbloqueado ? logro.tipo.icon : "lock.fill")
                    .font(.title2)
                    .foregroundColor(logro.desbloqueado ? logro.tipo.color : .gray)
            }
            
            VStack(spacing: 4) {
                Text(logro.tipo.titulo)
                    .font(.headline)
                    .foregroundColor(logro.desbloqueado ? .primary : .gray)
                    .lineLimit(1).minimumScaleFactor(0.8)
                Text(logro.tipo.descripcion)
                    .font(.caption2).foregroundColor(.secondary)
                    .multilineTextAlignment(.center).lineLimit(3)
                    .frame(height: 35)
            }
            
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.gray.opacity(0.2))
                        Capsule()
                            .fill(logro.desbloqueado ? logro.tipo.color : Color.gray)
                            .frame(width: geo.size.width * CGFloat(logro.porcentaje))
                    }
                }
                .frame(height: 6)
                
                HStack {
                    Text(logro.desbloqueado ? "¡Completado!" : "En progreso")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(logro.desbloqueado ? logro.tipo.color : .secondary)
                    Spacer()
                    Text("\(logro.progresoActual)/\(logro.progresoTotal)")
                        .font(.system(size: 9)).foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(logro.desbloqueado ? 0.1 : 0), radius: 5, y: 2)
        .opacity(logro.desbloqueado ? 1.0 : 0.7)
        .saturation(logro.desbloqueado ? 1.0 : 0.0)
    }
}

struct FelicitacionCard: View {
    let logro: Logro
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 80)).foregroundColor(.yellow)
                .padding(.top, 10)
                .shadow(color: .orange.opacity(0.5), radius: 20)
            
            VStack(spacing: 8) {
                Text("¡Enhorabuena!").font(.title2).fontWeight(.black)
                Text("Has desbloqueado un nuevo logro").font(.subheadline).foregroundColor(.secondary)
            }
            Divider()
            VStack(spacing: 8) {
                Text(logro.tipo.titulo).font(.title3).fontWeight(.bold).foregroundColor(logro.tipo.color)
                Text(logro.tipo.descripcion).font(.body).multilineTextAlignment(.center).foregroundColor(.secondary)
            }
            Button(action: action) {
                Text("¡Genial!").fontWeight(.bold).frame(maxWidth: .infinity).padding()
                    .background(logro.tipo.color).foregroundColor(.white).cornerRadius(12)
            }
        }
        .padding(24)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(24)
        .shadow(radius: 20)
        .padding(40)
    }
}
