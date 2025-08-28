extends Node

enum TAG { DEBUG, INFO, WARN, ERROR, }

func log( text: String, tag: TAG = TAG.DEBUG ):
	var prefix = "[%s]\t\t" % TAG.find_key( tag )
	for line in text.split( "\n" ):
		print( prefix + line )
