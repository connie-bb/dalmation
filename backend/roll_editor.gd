extends Node
class_name RollEditor

# Variable
var request: RollRequest = RollRequest.new()

# Constant
signal changed( roll_request: RollRequest )
signal finalized( roll_request: RollRequest )

func clear():
	request.delete()
	request = RollRequest.new()
	changed.emit( request )

func add_die( type: Die.TYPES ):
	request.add_die( type )
	changed.emit( request )

func subtract_die( type: Die.TYPES ):
	request.subtract_die( type )
	changed.emit( request )

func set_count( type: Die.TYPES, count: int ):
	request.set_count( type, count )
	changed.emit( request )

func remove_die( type: Die.TYPES ):
	request.remove_die( type )
	changed.emit( request )

func set_modifier( modifier: int ):
	request.set_modifier( modifier )
	changed.emit( request )

func replay_roll( receipt: RollReceipt ):
	request.delete()
	request = RollRequest.from_roll_receipt( receipt )
	changed.emit( request )

func finalize():
	finalized.emit( request )
