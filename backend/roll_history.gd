extends Object
class_name RollHistory

# Variable
var entries: Array[ RollReceipt ]

# Constant
signal replay_requested( receipt: RollReceipt )
signal entry_added( receipt: RollReceipt )
signal entry_removed( receipt: RollReceipt )

func add_entry( roll: Roll ):
	var receipt = RollReceipt.from_roll( roll )
	entries.append( receipt )
	entry_added.emit( receipt )

func remove_entry( receipt: RollReceipt ):
	entries.erase( receipt )
	entry_removed.emit( receipt )
	receipt.delete()

func replay( receipt: RollReceipt ):
	replay_requested.emit( receipt )
