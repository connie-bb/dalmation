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

const INT_TO_DIE_TYPE: Dictionary[ int, Die.TYPES ] = {
	4: Die.TYPES.D4,
	6: Die.TYPES.D6,
	8: Die.TYPES.D8,
	10: Die.TYPES.D10,
	12: Die.TYPES.D12,
	20: Die.TYPES.D20,
	100: Die.TYPES.D_PERCENTILE_10S
}

const DIE_TYPE_MAX_SCORE: Dictionary [ Die.TYPES, int ] = {
	Die.TYPES.D4: 4,
	Die.TYPES.D6: 6,
	Die.TYPES.D8: 8,
	Die.TYPES.D10: 10,
	Die.TYPES.D12: 12,
	Die.TYPES.D20: 20,
	Die.TYPES.D_PERCENTILE_10S: 90,
	Die.TYPES.D_PERCENTILE_1S: 9,
}

enum ERROR {
	NONE, SYNTAX, MAX_LENGTH, INVALID_DIE, D100_ADV_NOT_SUPPORTED, PARSE,
	MAX_INT, MAX_DICE, BAD_ADV, ZERO_COUNT,
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
	ERROR.BAD_ADV: "Advantage or disadvantage must be between 1 and the number of dice, inclusively.",
	ERROR.ZERO_COUNT: "Cannot roll 0 dice of a given type."
}

# Variable
var spawnlist: Array[ DiceGroup ] = []
var constants_sum: int = 0
var dice_group_resource: Resource = preload( "res://scripts/dice_group.tscn" )

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
	
	for dice_group: DiceGroup in spawnlist:
		max_possible_score += DIE_TYPE_MAX_SCORE[ dice_group.die_type ]
		total_number_of_dice += dice_group.count
	if max_possible_score >= MAX_INT: return ERROR.MAX_INT
	if total_number_of_dice > MAX_DICE: return ERROR.MAX_DICE
	
	return error
		
func parse_expression( expression: String ) -> ERROR:
	var error: ERROR = ERROR.NONE
	var dice_group: DiceGroup = dice_group_resource.instantiate()
	if expression.is_empty(): return ERROR.PARSE

	if expression.count( "-" ) > 1 or expression.count( "+" ) > 1:
		return ERROR.PARSE
	if expression[0] == "-":
		dice_group.subtract = true
	expression = expression.replace( "-", "" )
	expression = expression.replace( "+", "" )
	
	var search_digits: RegEx = RegEx.new()
	search_digits.compile( "[0-9]" )
	var search_digits_results = search_digits.search_all( expression )
	if search_digits_results.size() == 0:
		return ERROR.SYNTAX
		
	var a_count: int = expression.count( "a" )
	var b_count: int = expression.count( "b" )
	var d_count: int = expression.count( "d" )
	
	if ( a_count > 0 or b_count > 0 ) and d_count == 0: return ERROR.SYNTAX
	if a_count > 0 or b_count > 0:
		error = parse_advantage( expression, dice_group )
		if error != ERROR.NONE: return error
	if a_count > 0:
		expression = expression.get_slice( "a", 0 )
	elif b_count > 0:
		expression = expression.get_slice( "b", 0 )
	
	if d_count > 1:
		return ERROR.SYNTAX
	elif d_count == 0:
		# If this is a constant, then even when no error, we don't append
		# anything to the spawnlist.
		return parse_constant( expression, dice_group )
	elif d_count == 1 and expression[0] == "d":
		error = parse_roll( expression, dice_group )
	elif d_count == 1 and expression[0] != "d":
		error = parse_multi_roll( expression, dice_group )
	
	if dice_group.advantage > dice_group.count \
	or dice_group.disadvantage > dice_group.count:
		return ERROR.BAD_ADV
	
	if error != ERROR.NONE: return error as ERROR
	spawnlist.append( dice_group )
	return ERROR.NONE

func parse_multi_roll( expression: String, dice_group: DiceGroup ) -> ERROR:
	var split_expression: PackedStringArray = expression.split( "d", false )
	if split_expression.size() != 2:
		return ERROR.SYNTAX
	if !split_expression[0].is_valid_int():
		return ERROR.SYNTAX

	dice_group.count = split_expression[0].to_int()
	if dice_group.count == 0: return ERROR.ZERO_COUNT
	if dice_group.count > MAX_DICE: return ERROR.MAX_DICE
	
	return parse_sides( split_expression[1], dice_group )
	
func parse_roll( expression: String, dice_group: DiceGroup ) -> ERROR:
	dice_group.count = 1
	expression = expression.substr( 1 )
	return parse_sides( expression, dice_group )

func parse_constant( expression: String, dice_group: DiceGroup ) -> ERROR:
	if !expression.is_valid_int():
		return ERROR.SYNTAX
	var constant = expression.to_int()
	if abs( constant ) >= MAX_INT: return ERROR.MAX_INT
	if dice_group.subtract: constant *= -1
	constants_sum += constant
	return ERROR.NONE
	
func parse_sides( sides_string: String, dice_group: DiceGroup ) -> ERROR:
	if !sides_string.is_valid_int(): return ERROR.SYNTAX
	var sides_int := sides_string.to_int()
	
	if !INT_TO_DIE_TYPE.has( sides_int ):
		return ERROR.INVALID_DIE
	var die_type: Die.TYPES = INT_TO_DIE_TYPE[ sides_int ]
	dice_group.die_type = die_type
	return ERROR.NONE
	
func parse_advantage( expression: String, dice_group: DiceGroup ) -> ERROR:
	# It parses disadvantage too. (-u-)b
	var a_count: int = expression.count( "a" )
	var b_count: int = expression.count( "b" )
	if a_count > 0 and b_count > 0: return ERROR.SYNTAX
	if a_count > 1 or b_count > 1: return ERROR.SYNTAX
	
	var is_advantage: bool = a_count > 0
	if is_advantage:
		expression = expression.get_slice( "a", 1 )
	else:
		expression = expression.get_slice( "b", 1 )
	
	var how_many_to_keep: int
	if expression.is_empty():
		how_many_to_keep = 1
	elif expression.is_valid_int():
		how_many_to_keep = expression.to_int()
	else:
		return ERROR.SYNTAX
		
	if how_many_to_keep == 0: return ERROR.BAD_ADV

	if is_advantage:
		dice_group.advantage = how_many_to_keep
	else:
		dice_group.disadvantage = how_many_to_keep
	
	return ERROR.NONE

func debug_text_spawnlist():
	const COL_WIDTH: int = 10
	Debug.log( "== Spawnlist ==" )
	
	var headers: String = ""
	headers += "Count".rpad( COL_WIDTH, " " )
	headers += "Die Type".rpad( COL_WIDTH, " " )
	headers += "Adv".rpad( COL_WIDTH, " " )
	headers += "Disadv".rpad( COL_WIDTH, " " )
	headers += "Subtract".rpad( COL_WIDTH, " " )
	Debug.log( headers )
	
	for dice_group: DiceGroup in spawnlist:
		var row: String = ""
		row += str( dice_group.count ).rpad( COL_WIDTH, " " )
		row += str(
			Die.TYPES.find_key( dice_group.die_type ).right( 3 )
		).rpad( COL_WIDTH, " " )
		row += str( dice_group.advantage ).rpad( COL_WIDTH, " " )
		row += str( dice_group.disadvantage ).rpad( COL_WIDTH, " " )
		row += str( dice_group.subtract ).rpad( COL_WIDTH, " " )
		Debug.log( row )

	if spawnlist.is_empty():
		var row: String = ""
		row += "-".rpad( COL_WIDTH, " " ).repeat( 5 )
		Debug.log( row )
	
	Debug.log( "" )
		
