class_name AsyncUtils
extends RefCounted

# Helper class to track multiple signals
class _SignalWaiter:
    var _remaining: int
    signal all_completed

    func _init(signals: Array):
        _remaining = signals.size()
        if _remaining == 0:
            all_completed.emit()
            return
        
        for sig in signals:
            sig.connect(_on_signal_emitted, CONNECT_ONE_SHOT)
    
    func _on_signal_emitted():
        _remaining -= 1
        if _remaining == 0:
            all_completed.emit()

static func await_all(signals: Array) -> void:
    if signals.is_empty():
        return
    var waiter = _SignalWaiter.new(signals)
    await waiter.all_completed
