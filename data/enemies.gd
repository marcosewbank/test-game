extends Node

class Enemy extends RefCounted:
	var id: String
	var name: String
	var health: int
	var damage: int
	var experience: int
	var loot_table: Dictionary
	
	func _init(p_id: String, p_name: String, p_health: int, p_damage: int, p_experience: int, p_loot_table: Dictionary) -> void:
		id = p_id
		name = p_name
		health = p_health
		damage = p_damage
		experience = p_experience
		loot_table = p_loot_table

# Example enemy
static var enemies: Dictionary = {
	"rat": Enemy.new(
		"rat",
		"Giant Rat",
		20,
		5,
		10,
		{
			"bread": 0.5,  # 50% chance to drop bread
			"wooden_sword": 0.1  # 10% chance to drop wooden sword
		}
	)
} 