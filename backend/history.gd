extends Object
class_name History

# Variable
var entries: Array[ Roll ]

# Constant
signal replay_requested( roll: Roll )
signal entry_added( roll: Roll )
signal entry_removed( roll: Roll )

func add_entry( roll: Roll ):
	entries.append( roll )
	entry_added.emit( roll )

func remove_entry( roll: Roll ):
	entries.erase( roll )
	entry_removed.emit( roll )
	roll.delete()

func replay( roll: Roll ):
	replay_requested.emit( roll )
