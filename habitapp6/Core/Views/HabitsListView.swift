
import SwiftUI

struct HabitsListView: View {
    @ObservedObject var dataStore: HabitDataStore
    @ObservedObject private var pluginManager = PluginManager.shared
    @ObservedObject private var logrosManager = LogrosManager.shared
    @StateObject private var viewModel: HabitsViewModel

    @State private var showingCreateView = false
    @State private var showingSuggestions = false
    @State private var selectedHabitForReminder: Habit?
    
    // Estados de filtrado
    @State private var selectedCategoriaFilter: Categoria? = nil
    @State private var showByCategoria: Bool = false
    @State private var showingSettings = false
    @State private var showingFelicitacion = false
    @State private var logroDesbloqueado: Logro?

    init(dataStore: HabitDataStore) {
        self.dataStore = dataStore
        _viewModel = StateObject(wrappedValue: HabitsViewModel(dataStore: dataStore))
    }

    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 0) {
                    if pluginManager.isCategoriasEnabled && !dataStore.habits.isEmpty {
                        VStack(spacing: 8) {
                            CategoriaFilterView(selectedFilter: $selectedCategoriaFilter)
                            HStack {
                                Spacer()
                                Button {
                                    showByCategoria.toggle()
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: showByCategoria ? "list.bullet" : "folder")
                                        Text(showByCategoria ? "Ver lista" : "Ver por categoría")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.accentColor)
                                }
                                .padding(.trailing)
                            }
                        }
                        .padding(.top, 8)
                    }

                    if showByCategoria && pluginManager.isCategoriasEnabled {
                        HabitsByCategoriaView(dataStore: dataStore, pluginManager: pluginManager)
                    } else {
                        List {
                            if filteredHabits.isEmpty {
                                if dataStore.habits.isEmpty {
                                    emptyStateView
                                } else {
                                    noResultsView
                                }
                            } else {
                                ForEach(filteredHabits) { habit in
                                    NavigationLink(destination: HabitDetailView(dataStore: dataStore, habit: habit)) {
                                        HabitRowView(
                                            dataStore: dataStore,
                                            habit: habit,
                                            pluginManager: pluginManager,
                                            onToggleActive: {
                                                viewModel.toggleHabitActive(habit)
                                            },
                                            onReminderTap: {
                                                selectedHabitForReminder = habit
                                            }
                                        )
                                    }
                                }
                                .onDelete(perform: deleteHabits)
                            }
                        }
                    }
                }
                .navigationTitle("Mis Hábitos")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        HStack(spacing: 16) {
                            #if DEVELOP || PREMIUM
                            Button { showingSuggestions = true } label: { Image(systemName: "lightbulb").symbolVariant(.fill).foregroundColor(.yellow) }
                            #endif
                            Button { showingCreateView = true } label: { Image(systemName: "plus") }
                        }
                    }
                }
                .sheet(isPresented: $showingCreateView) {
                    CreateHabitView(dataStore: dataStore)
                }
                .sheet(item: $selectedHabitForReminder) { habit in
                    if pluginManager.isRecordatoriosEnabled {
                        RecordatorioConfigView(dataStore: dataStore, habit: habit)
                    }
                }
                .sheet(isPresented: $showingSuggestions) {
                    SuggestionListView(habitHandler: dataStore)
                }
            }
            .zIndex(0)

            if showingFelicitacion, let logro = logroDesbloqueado {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { cerrarFelicitacion() }
                    .zIndex(1)

                FelicitacionCardPopUp(logro: logro) {
                    cerrarFelicitacion()
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(2)
            }
        }
        .onReceive(logrosManager.$logrosRecienDesbloqueados) { nuevos in
            if let primero = nuevos.first {
                self.logroDesbloqueado = primero
                withAnimation(.spring()) {
                    self.showingFelicitacion = true
                }
            }
        }
    }

    private func cerrarFelicitacion() {
        withAnimation {
            showingFelicitacion = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            logrosManager.limpiarRecienDesbloqueados()
            logroDesbloqueado = nil
        }
    }

    private var filteredHabits: [Habit] {
        guard pluginManager.isCategoriasEnabled, let filter = selectedCategoriaFilter else {
            return dataStore.habits
        }
        return dataStore.habits.filter { $0.categoriaEnum == filter }
    }

    // MARK: - Views Auxiliares

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No hay hábitos").font(.headline)
            Text("Toca el botón + para crear tu primer hábito")
                .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 40).listRowBackground(Color.clear)
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("Sin resultados")
                .font(.headline)
            Text("No hay hábitos en esta categoría")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Mostrar todos") {
                selectedCategoriaFilter = nil
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 40).listRowBackground(Color.clear)
    }

    func deleteHabits(at offsets: IndexSet) {
        let habitsToDelete = offsets.map { filteredHabits[$0] }
        for habit in habitsToDelete {
            Task {
                await pluginManager.willDeleteHabit(habit)
                
                // Lógica de borrado directa en dataStore
                if let index = dataStore.habits.firstIndex(where: { $0.id == habit.id }) {
                    dataStore.habits.remove(at: index)
                }
                dataStore.instances.removeAll { $0.habitID == habit.id }
                await dataStore.saveData()
                
                await pluginManager.didDeleteHabit(habitId: habit.id)
            }
        }
    }
}

struct FelicitacionCardPopUp: View {
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


struct HabitRowView: View {
    @ObservedObject var dataStore: HabitDataStore
    let habit: Habit
    @ObservedObject var pluginManager: PluginManager
    let onToggleActive: () -> Void
    let onReminderTap: () -> Void
    @State private var rachaActual: Int = 0

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(habit.nombre)
                        .font(.headline)
                        .foregroundColor(habit.activo ? .primary : .secondary)

                    if pluginManager.isCategoriasEnabled && habit.tieneCategoria {
                        CategoriaBadgeView(categoria: habit.categoriaEnum)
                    }

                    if pluginManager.isRachasEnabled {
                        RachaBadgeView(rachaActual: rachaActual, frecuencia: habit.frecuencia)
                    }

                    if pluginManager.isRecordatoriosEnabled {
                        RecordatorioBadgeView(habit: habit)
                    }
                }

                HStack(spacing: 8) {
                    Label(
                        habit.frecuencia.rawValue.capitalized,
                        systemImage: habit.frecuencia == .diario ? "sun.max" : "calendar.badge.clock"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    if !habit.activo {
                        Text("• Pausado").font(.caption).foregroundColor(.orange)
                    }
                }
            }

            Spacer()

            if pluginManager.isRecordatoriosEnabled {
                RecordatorioQuickButton(habit: habit, action: onReminderTap)
            }

            Toggle("", isOn: Binding(
                get: { habit.activo },
                set: { _ in onToggleActive() }
            ))
            .labelsHidden()
            .tint(.green)
        }
        .padding(.vertical, 4)
        .onAppear {
            if pluginManager.isRachasEnabled {
                rachaActual = RachaCalculator.shared.calcularRachaActual(para: habit, instancias: dataStore.instances)
            }
        }
        .onChange(of: dataStore.instances.count) { _ in
            if pluginManager.isRachasEnabled {
                rachaActual = RachaCalculator.shared.calcularRachaActual(para: habit, instancias: dataStore.instances)
            }
        }
    }
}


extension Habit: Hashable {
    public static func == (lhs: Habit, rhs: Habit) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
