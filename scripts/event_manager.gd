class_name EventManager
extends Control

var hostEvents : Array[FightEvent] = []
var otherEvents : Array[FightEvent] = []

var manager : FightingManager
var debug : bool = false
var pause : bool = false
signal unpause

func _init(pManager : FightingManager) -> void:
    manager = pManager

func _apply(event : FightEvent, counter : Counter):
    if event == null:
        counter.submit()
        return
    match event.type:
        FightEvent.Type.BEFORE_ATTACK:
            await event.animal.data.before_attack(event.target)
        FightEvent.Type.ATTACK:
            await event.animal.attack(event.target)
        FightEvent.Type.BEFORE_FIGHT:
            await event.animal.data.before_fight()
        FightEvent.Type.BEFORE_DAMAGED:
            event.parameter.amount = event.animal.data.before_damaged(event.source, event.amount)
        FightEvent.Type.DAMAGED:
            await event.animal.applyDamaged(event.amount)
        FightEvent.Type.BEFORE_DIE:
            event.animal.data.before_die()
        FightEvent.Type.DIE:
            await event.animal.die()
        _:
            assert("ERROR : unexpected type "+str(event.type))
    counter.submit()

func _sortByHealth(cur : FightingAnimal, other : FightingAnimal):
    return cur.data.health < other.data.health

func buildEventForAll(builder : Callable, hostTeam : Array[FightingAnimal] = manager.hostTeam.animals, otherTeam : Array[FightingAnimal] = manager.otherTeam.animals):
    var maxlen = max(hostTeam.size(), otherTeam.size())
    for i in range(maxlen - 1, -1, -1):
        if i < otherTeam.size():
            var event = builder.call(otherTeam[i])
            otherEvents.push_front(event)
        if i < hostTeam.size():
            var event = builder.call(hostTeam[i])
            hostEvents.push_front(event)
        if i < hostTeam.size() and i < otherTeam.size():
            makeDependent()

func addEventForAll(type : FightEvent.Type, hostTeam : Array[FightingAnimal] = manager.hostTeam.animals, otherTeam : Array[FightingAnimal] = manager.otherTeam.animals):
    buildEventForAll(func(animal): return FightEvent.new(type, animal), hostTeam, otherTeam)

func getFirstValidEvent(events : Array[FightEvent]):
    for e in events:
        if e.animal != null:
            return e
    return null

func process():
    addEventForAll(FightEvent.Type.BEFORE_FIGHT)
    var tree = manager.get_tree()
    if NetworkHandler.is_server and debug:
        await tree.create_timer(7).timeout

    while true:
        if pause:
            await unpause

        var emptyQueues : bool = hostEvents.is_empty() and otherEvents.is_empty()
        if emptyQueues:
            manager.processDeaths()
            emptyQueues = hostEvents.is_empty() and otherEvents.is_empty()
        if manager.isFinished() and emptyQueues:
            return
        if emptyQueues:
            pushBackMutualFront(FightEvent.Type.BEFORE_ATTACK)
            pushBackMutualFront(FightEvent.Type.ATTACK)
        var processing : Array[FightEvent] = []
        var otherEvent = getFirstValidEvent(otherEvents)
        var hostEvent = getFirstValidEvent(hostEvents)

        if NetworkHandler.is_server and debug:
            await tree.create_timer(1).timeout
            print("======== ( " + str(hostEvents.size()) +")")
            for i in range(hostEvents.size()):
                print("EVENT " + str(i) + " : " + str(hostEvents[i]))
            print("========")

        if otherEvent != null:
            if otherEvent.dependsOn != null and otherEvent.dependsOn != hostEvent:
                otherEvent = null
            else:
                otherEvents.pop_front()
                processing.append(otherEvent)
        if hostEvent != null:
            if hostEvent.dependsOn != null and hostEvent.dependsOn != otherEvent:
                hostEvent = null
            else:
                hostEvents.pop_front()
                processing.append(hostEvent)
        var counter = Counter.new(processing.size())
        for event in processing:
            _apply(event, counter)
        await counter.completed

func pushBackMutualFront(type : FightEvent.Type):
    var hostEvent = FightEvent.new(type, manager.hostTeam.front()).setTarget(manager.otherTeam.front())
    var otherEvent = FightEvent.new(type, manager.otherTeam.front()).setTarget(manager.hostTeam.front())
    hostEvents.push_back(hostEvent)
    otherEvents.push_back(otherEvent)

func makeDependent():
    otherEvents[0].setDepend(hostEvents[0])
    hostEvents[0].setDepend(otherEvents[0])
