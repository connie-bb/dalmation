extends Node

var tooltip: Tooltip

func show_tooltip( text: String ):
	if tooltip == null: return
	tooltip.show_tooltip( text )

func hide_tooltip():
	if tooltip == null: return
	tooltip.hide_tooltip()
