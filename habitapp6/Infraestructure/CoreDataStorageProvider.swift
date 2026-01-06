import Foundation
import CoreData


@objc(HabitEntity)
class HabitEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var nombre: String
    @NSManaged var frecuencia: String
    @NSManaged var fechaCreacion: Date
    @NSManaged var activo: Bool
}

@objc(HabitInstanceEntity)
class HabitInstanceEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var habitID: UUID
    @NSManaged var fecha: Date
    @NSManaged var completado: Bool
}

class CoreDataStorageProvider: StorageProvider {
    static var shared: StorageProvider = CoreDataStorageProvider()
    
    private let container: NSPersistentContainer
    
    init() {
        // Crear modelo programáticamente
        let model = NSManagedObjectModel()
        
        // Entity: Habit
        let habitEntity = NSEntityDescription()
        habitEntity.name = "HabitEntity"
        habitEntity.managedObjectClassName = NSStringFromClass(HabitEntity.self)
        
        let habitIdAttr = NSAttributeDescription()
        habitIdAttr.name = "id"
        habitIdAttr.attributeType = .UUIDAttributeType
        
        let habitNombreAttr = NSAttributeDescription()
        habitNombreAttr.name = "nombre"
        habitNombreAttr.attributeType = .stringAttributeType
        
        let habitFrecuenciaAttr = NSAttributeDescription()
        habitFrecuenciaAttr.name = "frecuencia"
        habitFrecuenciaAttr.attributeType = .stringAttributeType
        
        let habitFechaAttr = NSAttributeDescription()
        habitFechaAttr.name = "fechaCreacion"
        habitFechaAttr.attributeType = .dateAttributeType
        
        let habitActivoAttr = NSAttributeDescription()
        habitActivoAttr.name = "activo"
        habitActivoAttr.attributeType = .booleanAttributeType
        
        habitEntity.properties = [habitIdAttr, habitNombreAttr, habitFrecuenciaAttr, habitFechaAttr, habitActivoAttr]
        
        // Entity: HabitInstance
        let instanceEntity = NSEntityDescription()
        instanceEntity.name = "HabitInstanceEntity"
        instanceEntity.managedObjectClassName = NSStringFromClass(HabitInstanceEntity.self)
        
        let instanceIdAttr = NSAttributeDescription()
        instanceIdAttr.name = "id"
        instanceIdAttr.attributeType = .UUIDAttributeType
        
        let instanceHabitIDAttr = NSAttributeDescription()
        instanceHabitIDAttr.name = "habitID"
        instanceHabitIDAttr.attributeType = .UUIDAttributeType
        
        let instanceFechaAttr = NSAttributeDescription()
        instanceFechaAttr.name = "fecha"
        instanceFechaAttr.attributeType = .dateAttributeType
        
        let instanceCompletadoAttr = NSAttributeDescription()
        instanceCompletadoAttr.name = "completado"
        instanceCompletadoAttr.attributeType = .booleanAttributeType
        
        instanceEntity.properties = [instanceIdAttr, instanceHabitIDAttr, instanceFechaAttr, instanceCompletadoAttr]
        
        model.entities = [habitEntity, instanceEntity]
        
        // Inicializar container con el modelo
        container = NSPersistentContainer(name: "HabitTracker", managedObjectModel: model)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("CoreData error: \(error)")
            }
        }
    }
    
    func loadHabits() async throws -> [Habit] {
        let context = container.viewContext
        let request = NSFetchRequest<HabitEntity>(entityName: "HabitEntity")
        
        let entities = try context.fetch(request)
        return entities.map { entity in
            Habit(
                nombre: entity.nombre,
                frecuencia: Frecuencia(rawValue: entity.frecuencia) ?? .diario,
                fechaCreacion: entity.fechaCreacion,
                activo: entity.activo
            )
        }
    }
    
    func saveHabits(_ habits: [Habit]) async throws {
        let context = container.viewContext
        
        // Eliminar existentes
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HabitEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        
        // Guardar nuevos
        for habit in habits {
            let entity = HabitEntity(context: context)
            entity.id = habit.id
            entity.nombre = habit.nombre
            entity.frecuencia = habit.frecuencia.rawValue
            entity.fechaCreacion = habit.fechaCreacion
            entity.activo = habit.activo
        }
        
        try context.save()
    }
    
    func loadInstances() async throws -> [HabitInstance] {
        let context = container.viewContext
        let request = NSFetchRequest<HabitInstanceEntity>(entityName: "HabitInstanceEntity")
        
        let entities = try context.fetch(request)
        return entities.map { entity in
            HabitInstance(habitID: entity.habitID, fecha: entity.fecha, completado: entity.completado)
        }
    }
    
    func saveInstances(_ instances: [HabitInstance]) async throws {
        let context = container.viewContext
        
        // Eliminar existentes
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HabitInstanceEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        
        // Guardar nuevos
        for instance in instances {
            let entity = HabitInstanceEntity(context: context)
            entity.id = instance.id
            entity.habitID = instance.habitID
            entity.fecha = instance.fecha
            entity.completado = instance.completado
        }
        
        try context.save()
    }
}
