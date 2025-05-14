extends Control

@onready var player_stats_label = $VBoxContainer/PlayerStats
@onready var dungeon_progress_bar = $VBoxContainer/DungeonProgress
@onready var dungeon_info_label = $VBoxContainer/DungeonInfo
@onready var enemy_info_label = $VBoxContainer/EnemyInfo
@onready var inventory_label = $VBoxContainer/Inventory
@onready var start_dungeon_button = $VBoxContainer/StartDungeon

var game_manager: Node

func _ready():
	# Get reference to game manager
	game_manager = get_node("/root/Main")
	
	# Connect signals
	game_manager.connect("dungeon_started", Callable(self, "_on_dungeon_started"))
	game_manager.connect("dungeon_progress_updated", Callable(self, "_on_dungeon_progress_updated"))
	game_manager.connect("dungeon_completed", Callable(self, "_on_dungeon_completed"))
	game_manager.connect("enemy_encountered", Callable(self, "_on_enemy_encountered"))
	game_manager.connect("player_stats_updated", Callable(self, "_on_player_stats_updated"))
	
	# Connect button signal
	start_dungeon_button.connect("pressed", Callable(self, "_on_start_dungeon_pressed"))
	
	# Initial UI update
	_update_player_stats()
	_update_inventory()

func _update_player_stats():
	var stats = game_manager.player
	player_stats_label.text = "Health: %d/%d\nGold: %d\nLevel: %d" % [
		stats.health,
		stats.max_health,
		stats.gold,
		stats.level
	]

func _update_inventory():
	var inventory_text = "Inventory:\n"
	for item_id in game_manager.player.inventory:
		var item = load("res://data/items.gd").items[item_id]
		inventory_text += "- %s\n" % item.name
	
	# Add equipped items
	inventory_text += "\nEquipped:\n"
	if game_manager.player.equipped.weapon:
		var weapon = load("res://data/items.gd").items[game_manager.player.equipped.weapon]
		inventory_text += "Weapon: %s\n" % weapon.name
	if game_manager.player.equipped.gear:
		var gear = load("res://data/items.gd").items[game_manager.player.equipped.gear]
		inventory_text += "Gear: %s" % gear.name
	
	inventory_label.text = inventory_text

func _on_dungeon_started(dungeon):
	dungeon_info_label.text = "Current Dungeon: %s\n%s" % [dungeon.name, dungeon.description]
	start_dungeon_button.disabled = true

func _on_dungeon_progress_updated(progress):
	dungeon_progress_bar.value = progress * 100

func _on_dungeon_completed(rewards):
	dungeon_info_label.text = "Dungeon Completed!\nRewards:\nGold: %d\nExperience: %d" % [
		rewards.gold,
		rewards.experience
	]
	dungeon_progress_bar.value = 100
	start_dungeon_button.disabled = false
	enemy_info_label.text = "No enemy encountered"

func _on_enemy_encountered(enemy):
	enemy_info_label.text = "Encountered: %s\nHealth: %d\nDamage: %d" % [
		enemy.name,
		enemy.health,
		enemy.damage
	]

func _on_player_stats_updated():
	_update_player_stats()
	_update_inventory()

func _on_start_dungeon_pressed():
	game_manager.start_dungeon("rat_cave")  # Start with the rat cave dungeon 
