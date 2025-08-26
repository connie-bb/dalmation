extends Node3D
class_name DiceGroup

var count: int = 0
var die_type: Die.TYPES
var top_n: int = 0		# Take the top n results
var bottom_n: int = 0 	# Take the bottom n results
var subtract: bool = false
