extends Node

enum ItemType {
	WEAPON,
	GEAR,
	FOOD
}

class Item extends RefCounted:
	var id: String
	var name: String
	var type: ItemType
	var description: String
	var value: int
	
	func _init(p_id: String, p_name: String, p_type: ItemType, p_description: String, p_value: int) -> void:
		id = p_id
		name = p_name
		type = p_type
		description = p_description
		value = p_value

# Example items
static var items: Dictionary = {
	"wooden_sword": Item.new(
		"wooden_sword",
		"Wooden Sword",
		ItemType.WEAPON,
		"A basic wooden sword",
		10
	),
	"leather_armor": Item.new(
		"leather_armor",
		"Leather Armor",
		ItemType.GEAR,
		"Basic leather protection",
		15
	),
	"bread": Item.new(
		"bread",
		"Bread",
		ItemType.FOOD,
		"Restores some health",
		5
	)
} 
