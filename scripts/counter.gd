class_name Counter

signal completed

var _counter: int
var _total: int


func _init(p_total: int):
    _total = p_total
    _counter = 0

func submit():
    _counter = _counter + 1
    if _counter >= _total:
        var tree = Engine.get_main_loop()
        await tree.create_timer(0.01).timeout
        completed.emit()
        _counter = 0
