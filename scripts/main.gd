extends Control

var selected_dungeon_id: String = ""
@onready var game_manager = get_node("/root/GameManager")

# UI References
@onready var stats_label = %StatsLabel
@onready var equipment_label = %EquipmentLabel
@onready var inventory_label = %InventoryLabel
@onready var dungeon_list = %DungeonList
@onready var start_dungeon_button = %StartDungeonButton
@onready var dungeon_info_label = %DungeonInfoLabel
@onready var progress_bar = %ProgressBar
@onready var current_enemy_label = %CurrentEnemyLabel

func _ready() -> void:
	# Connect to GameManager signals
	game_manager.dungeon_started.connect(_on_dungeon_started)
	game_manager.dungeon_progress_updated.connect(_on_dungeon_progress_updated)
	game_manager.dungeon_completed.connect(_on_dungeon_completed)
	game_manager.enemy_encountered.connect(_on_enemy_encountered)
	game_manager.enemy_defeated.connect(_on_enemy_defeated)
	game_manager.player_stats_updated.connect(_update_character_info)
	
	# Initial UI update
	_update_character_info()
	_populate_dungeon_list()
	start_dungeon_button.disabled = true

func _update_character_info() -> void:
	# Update stats
	stats_label.text = "Health: %d/%d\nLevel: %d\nExperience: %d\nGold: %d" % [
		game_manager.player.health,
		game_manager.player.max_health,
		game_manager.player.level,
		game_manager.player.experience,
		game_manager.player.gold
	]
	
	# Update equipment
	var weapon = "None"
	var gear = "None"
	if game_manager.player.equipped.weapon:
		weapon = game_manager.ItemsData.items[game_manager.player.equipped.weapon].name
	if game_manager.player.equipped.gear:
		gear = game_manager.ItemsData.items[game_manager.player.equipped.gear].name
	equipment_label.text = "Weapon: %s\nGear: %s" % [weapon, gear]
	
	# Update inventory
	var inventory_text = ""
	for item_id in game_manager.player.inventory:
		var item = game_manager.ItemsData.items[item_id]
		inventory_text += "- %s\n" % item.name
	inventory_label.text = inventory_text if inventory_text else "Empty"

func _populate_dungeon_list() -> void:
	dungeon_list.clear()
	for dungeon_id in game_manager.DungeonsData.dungeons:
		var dungeon = game_manager.DungeonsData.dungeons[dungeon_id]
		dungeon_list.add_item("%s (Level %d)" % [dungeon.name, dungeon.difficulty])
		dungeon_list.set_item_metadata(dungeon_list.item_count - 1, dungeon_id)

func _on_dungeon_list_item_selected(index: int) -> void:
	selected_dungeon_id = dungeon_list.get_item_metadata(index)
	start_dungeon_button.disabled = false
	
	# Show dungeon info
	var dungeon = game_manager.DungeonsData.dungeons[selected_dungeon_id]
	dungeon_info_label.text = "%s\n%s\nDifficulty: %d\nReward: %d gold" % [
		dungeon.name,
		dungeon.description,
		dungeon.difficulty,
		dungeon.base_reward
	]

func _on_start_dungeon_button_pressed() -> void:
	if selected_dungeon_id.is_empty():
		return
		
	start_dungeon_button.disabled = true
	game_manager.start_dungeon(selected_dungeon_id)

func _on_dungeon_started(dungeon: Dictionary) -> void:
	progress_bar.value = 0
	dungeon_info_label.text = "In Progress: %s\n%s" % [dungeon.name, dungeon.description]

func _on_dungeon_progress_updated(progress: float) -> void:
	progress_bar.value = progress

func _on_enemy_encountered(enemy: Dictionary) -> void:
	current_enemy_label.text = "Fighting: %s\nHealth: %d\nDamage: %d" % [
		enemy.name,
		enemy.health,
		enemy.damage
	]
	
	# Auto-defeat enemy after a short delay
	await get_tree().create_timer(1.0).timeout
	game_manager.defeat_enemy()

func _on_enemy_defeated(_enemy: Dictionary, _loot: Dictionary) -> void:
	current_enemy_label.text = "No enemy encountered"

func _on_dungeon_completed(_rewards: Dictionary) -> void:
	start_dungeon_button.disabled = false
	dungeon_info_label.text = "No dungeon in progress"
	current_enemy_label.text = "No enemy encountered"
	progress_bar.value = 0 