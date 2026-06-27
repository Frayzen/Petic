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
			event.parameter.amount = await event.animal.data.before_damaged(event.source, event.amount)
		FightEvent.Type.DAMAGED:
			await event.animal.applyDamaged(event.amount)
		FightEvent.Type.BEFORE_DIE:
			await event.animal.data.before_die()
		FightEvent.Type.DIE:
			await event.animal.die()
		_:
			assert("ERROR : unexpected type "+str(event.type))
	counter.submit()

func _sortByHealth(cur : FightingAnimal, other : FightingAnimal):
	return cur.data.health < other.data.health

func addEventForAll(hostTeam : Array[FightingAnimal], otherTeam : Array[FightingAnimal], type : FightEvent.Type):
	var maxlen = max(hostTeam.size(), otherTeam.size())
	for i in range(maxlen - 1, -1, -1):
		if i < otherTeam.size() and i < hostTeam.size():
			addMutual(hostTeam[i], otherTeam[i], type)
		elif i < otherTeam.size():
			otherEvents.push_front(FightEvent.new(type, otherTeam[i]))
		else:
			hostEvents.push_front(FightEvent.new(type, hostTeam[i]))

func process():
	addEventForAll(manager.hostTeam.animals, manager.otherTeam.animals, FightEvent.Type.BEFORE_FIGHT)
	var tree = manager.get_tree()
	if NetworkHandler.is_server and debug:
		await tree.create_timer(7).timeout

	while true:
		if pause:
			await unpause

		var hostDeads = manager.hostTeam.getDeadAnimals()
		var otherDeads = manager.otherTeam.getDeadAnimals()
		addEventForAll(hostDeads, otherDeads, FightEvent.Type.DIE)
		addEventForAll(hostDeads, otherDeads, FightEvent.Type.BEFORE_DIE)

		var emptyQueues : bool = hostEvents.is_empty() and otherEvents.is_empty()

		if manager.isFinished() and emptyQueues:
			return

		if emptyQueues:
			addMutualFront(FightEvent.Type.ATTACK)
			addMutualFront(FightEvent.Type.BEFORE_ATTACK)
		var processing : Array[FightEvent] = []
		var otherEvent = otherEvents.front() if not otherEvents.is_empty() else null
		var hostEvent = hostEvents.front() if not hostEvents.is_empty() else null

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

func addMutualFront(type : FightEvent.Type):
	addMutual(manager.hostTeam.front(), manager.otherTeam.front(), type)

func addMutual(hostAnimal : FightingAnimal, otherAnimal : FightingAnimal, type : FightEvent.Type):
	var hostEvent = FightEvent.new(type, hostAnimal).setTarget(otherAnimal)
	var otherEvent = FightEvent.new(type, otherAnimal).setTarget(hostAnimal)

	otherEvent.setDepend(hostEvent)
	hostEvent.setDepend(otherEvent)

	hostEvents.push_front(hostEvent)
	otherEvents.push_front(otherEvent)
