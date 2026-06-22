class_name Counter

signal completed

var _counter: int
var _total: int


func _init(p_total: int):
    _total = p_total
    _counter = 0

func submit():
    _counter = _counter + 1
    print("SUBMITTED ! " + str(_counter))
    print("WANT " + str(_total))
    if _counter >= _total:
        print("EMIT !")
        completed.emit()
        _counter = 0
