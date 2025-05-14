extends Node

class Dungeon extends RefCounted:
	var id: String
	var name: String
	var description: String
	var difficulty: int
	var enemies: Array[String]
	var completion_time: float  # in seconds
	var base_reward: int
	
	func _init(p_id: String, p_name: String, p_description: String, p_difficulty: int, p_enemies: Array[String], p_completion_time: float, p_base_reward: int) -> void:
		id = p_id
		name = p_name
		description = p_description
		difficulty = p_difficulty
		enemies = p_enemies
		completion_time = p_completion_time
		base_reward = p_base_reward

# Example dungeon
static var dungeons: Dictionary = {
	"rat_cave": Dungeon.new(
		"rat_cave",
		"Rat Cave",
		"A dark cave infested with giant rats",
		1,
		["rat", "rat", "rat"],  # Three rats in this dungeon
		60.0,  # 60 seconds to complete
		50  # Base gold reward
	)
} 