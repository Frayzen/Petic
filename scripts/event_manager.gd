class_name EventManager
extends Control

var hostEvents : Array[FightEvent] = []
var otherEvents : Array[FightEvent] = []

var manager : FightingManager

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
		_:
			assert("ERROR : unexpected type "+str(event.type))
	counter.submit()

func process():
	while true:
		var counterDeath = Counter.new(2)
		manager.hostTeam.checkDeath(counterDeath)
		manager.otherTeam.checkDeath(counterDeath)
		await counterDeath.completed

		if manager.isFinished():
			return

		var emptyQueues : bool = hostEvents.is_empty() and otherEvents.is_empty()
		if emptyQueues:
			addMutual(FightEvent.Type.BEFORE_ATTACK)
			addMutual(FightEvent.Type.ATTACK)

		var otherEvent = otherEvents.front()
		var hostEvent = hostEvents.front()
		if otherEvent.dependsOn != null and otherEvent.dependsOn != hostEvent:
			otherEvent = null
		else:
			otherEvents.pop_front()
		if hostEvent.dependsOn != null and hostEvent.dependsOn != otherEvent:
			hostEvent = null
		else:
			hostEvents.pop_front()
		var counter = Counter.new(2)
		_apply(hostEvent, counter)
		_apply(otherEvent, counter)
		await counter.completed


func addMutual(type : FightEvent.Type):
	var hostAnimal = manager.hostTeam.front()
	var otherAnimal = manager.otherTeam.front()
	var hostEvent = FightEvent.new(type, hostAnimal).setTarget(otherAnimal)
	var otherEvent = FightEvent.new(type, otherAnimal).setTarget(hostAnimal)

	otherEvent.setDepend(hostEvent)
	hostEvent.setDepend(otherEvent)

	hostEvents.push_back(hostEvent)
	otherEvents.push_back(otherEvent)
