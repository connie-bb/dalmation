extends Node
class_name RollTextParser

# Constant
# str( const int ) can't be used in a constant expression. What a load of @#!$.
const MAX_INT := 9223372036854775807
const MAX_INT_STR := "9,223,372,036,854,775,807"
const MAX_DICE := 30
const MAX_DICE_STR := "30"
const MAX_LENGTH := 128
const MAX_LENGTH_STR := "128"

# Extends object so that we can pass it by reference instead of value
class SpawnlistEntry extends Object:
	var count: int = 0
	var sides: Die.SIDES
	var top_n: int = 0		# Take the top n results
	var bottom_n: int = 0 	# Take the bottom n results
	var subtract: bool = false

# Variable
var spawnlist: Array[SpawnlistEntry] = []
var constants_sum: int = 0

# Constant
const INT_TO_SIDES: Dictionary[ int, Die.SIDES ] = {
	4: Die.SIDES.D4,
	6: Die.SIDES.D6,
	8: Die.SIDES.D8,
	10: Die.SIDES.D10,
	12: Die.SIDES.D12,
	20: Die.SIDES.D20,
	100: Die.SIDES.D_PERCENTILE_10S
}
enum ERROR {
	NONE, SYNTAX, MAX_LENGTH, INVALID_DIE, D100_ADV_NOT_SUPPORTED, PARSE,
	MAX_INT, MAX_DICE,
}
const ERROR_TO_STRING: Dictionary[ ERROR, String ] = {
	ERROR.NONE: "",
	ERROR.SYNTAX: "Syntax error. See Help [?] for more info.",
	ERROR.MAX_LENGTH: "Maximum of " + MAX_LENGTH_STR + " characters.",
	ERROR.INVALID_DIE: "Invalid die found. Supported dice are: d4, d6, d8, d10, d12, d20, d100.",
	ERROR.D100_ADV_NOT_SUPPORTED: "Advantage and disadvantage is not supported for percentile dice.",
	ERROR.PARSE: "The parser encountered an error (not your fault). Please report this bug.",
	ERROR.MAX_INT: "Maximum integer of " + MAX_INT_STR + " exceeded. What exactly is going on here?",
	ERROR.MAX_DICE: "A maximum of " + MAX_DICE_STR + " dice may be rolled at once.",
}

func reset():
	spawnlist = []
	constants_sum = 0

func parse( text: String ) -> ERROR:
	var error = ERROR.NONE
	var length: int = text.length()
	var begin: int = 0
	
	if length > MAX_LENGTH:
		return ERROR.MAX_LENGTH
	
	if text[ -1 ] == "-" or text[ -1 ] == "+":
		return ERROR.SYNTAX
	
	for end in range( 0, length ):
		if end == 0 and ( text[0] == "+" or text[0] == "-" ):
			if length == 1: return ERROR.SYNTAX
			continue
		if text[end] != "+" and text[end] != "-" and end != length - 1:
			# Expression delimiter or end-of-string not found.
			continue
		
		var expression_length: int = end - begin
		if end == length - 1:
			expression_length += 1
		var expression = text.substr( begin, expression_length )
		error = parse_expression( expression )
		if error != ERROR.NONE: return error
		begin = end

	var max_possible_score: int = 0
	var total_number_of_dice: int = 0
	max_possible_score += constants_sum
	
	for entry: SpawnlistEntry in spawnlist:
		max_possible_score += entry.count * INT_TO_SIDES.find_key( entry.sides )
		total_number_of_dice += entry.count
	if max_possible_score >= MAX_INT: return ERROR.MAX_INT
	if total_number_of_dice > MAX_DICE: return ERROR.MAX_DICE
	
	return error
		
func parse_expression( expression: String ) -> ERROR:
	var error: int = ERROR.NONE
	var entry: SpawnlistEntry = SpawnlistEntry.new()
	if expression.is_empty(): return ERROR.PARSE

	if expression.count( "-" ) > 1 or expression.count( "+" ) > 1:
		return ERROR.PARSE
	if expression[0] == "-":
		entry.subtract = true
	expression = expression.replace( "-", "" )
	expression = expression.replace( "+", "" )
	
	var search_digits: RegEx = RegEx.new()
	search_digits.compile( "[0-9]" )
	var search_digits_results = search_digits.search_all( expression )
	if search_digits_results.size() == 0:
		return ERROR.SYNTAX
	
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
	spawnlist.append( entry )
	return ERROR.NONE

func parse_multi_roll( expression: String, entry: SpawnlistEntry ) -> ERROR:
	print( "multiroll: " + expression )
	var split_expression: PackedStringArray = expression.split( "d", false )
	if split_expression.size() != 2:
		return ERROR.SYNTAX
	if !split_expression[0].is_valid_int():
		return ERROR.SYNTAX

	entry.count = split_expression[0].to_int()
	if entry.count > MAX_DICE: return ERROR.MAX_DICE
	
	print( "split expr: " + str( split_expression ) )
	return parse_sides( split_expression[1], entry )
	
func parse_roll( expression: String, entry: SpawnlistEntry ) -> ERROR:
	print( "roll: " + expression )
	entry.count = 1
	expression = expression.substr( 1 )
	return parse_sides( expression, entry )

func parse_constant( expression: String, entry: SpawnlistEntry ) -> ERROR:
	print( "constant: " + expression )
	if !expression.is_valid_int():
		return ERROR.SYNTAX
	var constant = expression.to_int()
	if abs( constant ) >= MAX_INT: return ERROR.MAX_INT
	if entry.subtract: constant *= -1
	constants_sum += constant
	return ERROR.NONE
	
func parse_sides( sides_string: String, entry: SpawnlistEntry ) -> ERROR:
	print( "parse sides: " + sides_string )
	if !sides_string.is_valid_int(): return ERROR.SYNTAX
	var sides_int := sides_string.to_int()
	
	if !INT_TO_SIDES.has( sides_int ):
		return ERROR.INVALID_DIE
	var sides: Die.SIDES = INT_TO_SIDES[ sides_int ]
	entry.sides = sides
	return ERROR.NONE

func debug_text_spawnlist():
	const COL_WIDTH: int = 10
	var headers: String = ""
	headers += "Count".rpad( COL_WIDTH, " " )
	headers += "Sides".rpad( COL_WIDTH * 2, " " )
	headers += "Top n".rpad( COL_WIDTH, " " )
	headers += "Bottom n".rpad( COL_WIDTH, " " )
	headers += "Subtract".rpad( COL_WIDTH, " " )
	print( headers )
	
	for entry: SpawnlistEntry in spawnlist:
		var row: String = ""
		row += str( entry.count ).rpad( COL_WIDTH, " " )
		row += str( Die.SIDES.find_key( entry.sides ) ).rpad( COL_WIDTH * 2, " " )
		row += str( entry.top_n ).rpad( COL_WIDTH, " " )
		row += str( entry.bottom_n ).rpad( COL_WIDTH, " " )
		row += str( entry.subtract ).rpad( COL_WIDTH, " " )
		print( row )
		
