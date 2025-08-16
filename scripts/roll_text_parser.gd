extends Node
class_name RollTextParser

# Extends object so that we can pass it by reference instead of value
class TextSpawnlistEntry extends Object:
	var count: int = 0
	var sides: int = 0
	var top_n: int = 0		# Take the top n results
	var bottom_n: int = 0 	# Take the bottom n results
	var subtract: bool = false

# Variable
var text_spawnlist: Array[TextSpawnlistEntry] = []
var constants_sum: int = 0

# Constant
const VALID_SIDES: Array[int] = [
	4, 6, 8, 10, 12, 20, 100
]
enum ERROR { NONE, SYNTAX, MAX_LENGTH, INVALID_DIE }

func parse( text: String ) -> ERROR:
	text_spawnlist = []
	var error = ERROR.NONE
	var length: int = text.length()
	var begin: int = 0
	for end in range( 0, length ):
		if text[end] != "+" and text[end] != "-" and end != length - 1:
			continue
		if end == length - 1:
			end += 1
		var expression = text.substr( begin, end - begin )
		error = parse_expression( expression )
		if error != ERROR.NONE: return error
		begin = end
	return error
		
func parse_expression( expression: String ) -> ERROR:
	var error: int = ERROR.NONE
	var entry: TextSpawnlistEntry = TextSpawnlistEntry.new()
	
	if expression.count( "-" ) > 1 or expression.count( "+" ) > 1:
		return ERROR.SYNTAX
	if expression[0] == "-":
		entry.subtract = true
	expression = expression.replace( "-", "" )
	expression = expression.replace( "+", "" )
	
	var d_count: int = expression.count( "d" )
	if d_count > 1:
		return ERROR.SYNTAX
	elif d_count == 0:
		# If this is a constant, then even when no error, we don't append
		# anything to the spawnlist.
		return parse_constant( expression, entry )
	elif d_count == 1 and expression[0] == "d":
		error = parse_roll( expression, entry )
	elif d_count == 1 and expression[0] != "d":
		error = parse_multi_roll( expression, entry )
	
	if error != ERROR.NONE: return error as ERROR
	text_spawnlist.append( entry )
	return ERROR.NONE

func parse_multi_roll( expression: String, entry: TextSpawnlistEntry ) -> ERROR:
	print( "multiroll: " + expression )
	var split_expression: PackedStringArray = expression.split( "d", false )
	if split_expression.size() != 2:
		return ERROR.SYNTAX
	if !split_expression[0].is_valid_int():
		return ERROR.SYNTAX
	entry.count = split_expression[0].to_int()
	print( "split expr: " + str( split_expression ) )
	return parse_sides( split_expression[1], entry )
	
func parse_roll( expression: String, entry: TextSpawnlistEntry ) -> ERROR:
	print( "roll: " + expression )
	expression = expression.substr( 1 )
	return parse_sides( expression, entry )

func parse_constant( expression: String, entry: TextSpawnlistEntry ) -> ERROR:
	print( "constant: " + expression )
	if !expression.is_valid_int():
		return ERROR.SYNTAX
	var constant = expression.to_int()
	if entry.subtract: constant *= -1
	constants_sum += constant
	return ERROR.NONE
	
func parse_sides( sides: String, entry: TextSpawnlistEntry ) -> ERROR:
	print( "parse sides: " + sides )
	if !sides.is_valid_int(): return ERROR.SYNTAX
	var sides_int := sides.to_int()
	if !VALID_SIDES.has( sides_int ): return ERROR.INVALID_DIE
	print( "sides as int: " + str( sides_int ) ) 
	entry.sides = sides_int
	return ERROR.NONE

func debug_text_spawnlist():
	const COL_WIDTH: int = 10
	var headers: String = ""
	headers += "Count".rpad( COL_WIDTH, " " )
	headers += "Sides".rpad( COL_WIDTH, " " )
	headers += "Top n".rpad( COL_WIDTH, " " )
	headers += "Bottom n".rpad( COL_WIDTH, " " )
	headers += "Subtract".rpad( COL_WIDTH, " " )
	print( headers )
	
	for entry: TextSpawnlistEntry in text_spawnlist:
		var row: String = ""
		row += str( entry.count ).rpad( COL_WIDTH, " " )
		row += str( entry.sides ).rpad( COL_WIDTH, " " )
		row += str( entry.top_n ).rpad( COL_WIDTH, " " )
		row += str( entry.bottom_n ).rpad( COL_WIDTH, " " )
		row += str( entry.subtract ).rpad( COL_WIDTH, " " )
		print( row )
		
