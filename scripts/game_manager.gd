extends Node

# Player data
var player = {
	"health": 100,
	"max_health": 100,
	"gold": 0,
	"experience": 0,
	"level": 1,
	"inventory": [],
	"equipped": {
		"weapon": null,
		"gear": null
	}
}

# Current dungeon state
var current_dungeon = null
var dungeon_progress = 0.0
var current_enemy = null
var is_in_dungeon = false
var dungeon_log: Array[String] = []

# Data
var ItemsData = preload("res://data/items.gd")
var EnemiesData = preload("res://data/enemies.gd")
var DungeonsData = preload("res://data/dungeons.gd")

# Signals
signal dungeon_started(dungeon: Dictionary)
signal dungeon_progress_updated(progress: float)
signal dungeon_completed(rewards: Dictionary)
signal enemy_encountered(enemy: Dictionary)
signal enemy_defeated(enemy: Dictionary, loot: Dictionary)
signal player_stats_updated
signal log_updated(message: String)

func _init() -> void:
	print("GameManager initialized")

func add_log_entry(message: String) -> void:
	print("Adding log entry: ", message)  # Debug print
	var timestamp = Time.get_time_string_from_system()
	var log_entry = "[%s] %s" % [timestamp, message]
	dungeon_log.append(log_entry)
	log_updated.emit(log_entry)

func _ready() -> void:
	print("GameManager _ready called")  # Debug print
	# Initialize with basic equipment
	player.inventory.append("wooden_sword")
	player.inventory.append("leather_armor")
	player.inventory.append("bread")
	equip_item("wooden_sword")
	equip_item("leather_armor")

func start_dungeon(dungeon_id: String) -> void:
	print("Starting dungeon: ", dungeon_id)  # Debug print
	if not DungeonsData.dungeons.has(dungeon_id):
		print("ERROR: Dungeon not found: ", dungeon_id)  # Debug print
		return
		
	var dungeon = DungeonsData.dungeons[dungeon_id]
	print("Dungeon loaded: ", dungeon.name)  # Debug print
	current_dungeon = dungeon
	dungeon_progress = 0.0
	is_in_dungeon = true
	dungeon_log.clear()  # Clear previous dungeon logs
	add_log_entry("Entered %s - %s" % [dungeon.name, dungeon.description])
	dungeon_started.emit(dungeon)
	_process_dungeon()

func _process_dungeon() -> void:
	if not is_in_dungeon:
		print("Not in dungeon, skipping process")  # Debug print
		return
	
	if current_dungeon == null:
		print("ERROR: current_dungeon is null")  # Debug print
		return
		
	# Update progress
	dungeon_progress += 1.0 / (current_dungeon.completion_time * 60)  # Assuming 60 FPS
	
	# Emit progress update
	dungeon_progress_updated.emit(dungeon_progress)
	
	# Check for enemy encounters
	if current_enemy == null and randf() < 0.1:  # 10% chance per frame
		_encounter_enemy()
	
	# Check for dungeon completion
	if dungeon_progress >= 1.0:
		_complete_dungeon()
	else:
		# Continue processing the dungeon
		await get_tree().create_timer(1.0 / 60.0).timeout  # Simulate frame delay
		_process_dungeon()

func _encounter_enemy() -> void:
	var enemy_id = current_dungeon.enemies[randi() % current_dungeon.enemies.size()]
	current_enemy = EnemiesData.enemies[enemy_id]
	add_log_entry("Encountered a %s!" % current_enemy.name)
	enemy_encountered.emit(current_enemy)
	_start_combat()

func _start_combat() -> void:
	if current_enemy == null:
		return
	
	add_log_entry("Combat started with %s!" % current_enemy.name)
	
	while current_enemy.health > 0 and player.health > 0:
		# Player attacks the enemy
		var player_damage = randi_range(5, 10)  # Example damage range
		current_enemy.health -= player_damage
		add_log_entry("You dealt %d damage to %s!" % [player_damage, current_enemy.name])
		
		if current_enemy.health <= 0:
			add_log_entry("You defeated %s!" % current_enemy.name)
			defeat_enemy()
			return  # Exit combat after defeating the enemy
		
		# Enemy attacks the player
		var enemy_damage = randi_range(3, 8)  # Example damage range
		player.health -= enemy_damage
		add_log_entry("%s dealt %d damage to you!" % [current_enemy.name, enemy_damage])
		
		if player.health <= 0:
			add_log_entry("You were defeated by %s!" % current_enemy.name)
			_end_dungeon_failure()
			return  # Exit combat after the player is defeated

func _complete_dungeon() -> void:
	is_in_dungeon = false
	var rewards = {
		"gold": current_dungeon.base_reward,
		"experience": 50  # Base experience
	}
	add_log_entry("Dungeon completed! Earned %d gold and %d experience" % [rewards.gold, rewards.experience])
	dungeon_completed.emit(rewards)
	
	# Update player stats
	player.gold += rewards.gold
	player.experience += rewards.experience
	player_stats_updated.emit()

func equip_item(item_id: String) -> void:
	var item = ItemsData.items[item_id]
	if item.type == ItemsData.ItemType.WEAPON:
		player.equipped.weapon = item_id
		add_log_entry("Equipped %s as weapon" % item.name)
	elif item.type == ItemsData.ItemType.GEAR:
		player.equipped.gear = item_id
		add_log_entry("Equipped %s as gear" % item.name)
	player_stats_updated.emit()

func use_item(item_id: String) -> void:
	var item = ItemsData.items[item_id]
	if item.type == ItemsData.ItemType.FOOD:
		player.health = min(player.health + item.value, player.max_health)
		player.inventory.erase(item_id)
		add_log_entry("Used %s, restored %d health" % [item.name, item.value])
		player_stats_updated.emit()

func defeat_enemy() -> void:
	if current_enemy == null:
		return
	
	# Calculate loot based on loot table probabilities
	var dropped_item = null
	for item_id in current_enemy.loot_table:
		if randf() < current_enemy.loot_table[item_id]:
			dropped_item = item_id
			break
	
	var loot = {
		"gold": 5,  # Base gold reward
		"experience": current_enemy.experience,
		"items": dropped_item
	}
	
	# Update player stats
	player.gold += loot["gold"]
	player.experience += loot["experience"]
	
	# Create detailed log message
	var loot_message = "Defeated %s! Earned %d gold and %d experience" % [
		current_enemy.name,
		loot["gold"],
		loot["experience"]
	]
	if loot["items"]:
		var item = ItemsData.items[loot["items"]]
		loot_message += ", obtained %s" % item.name
		player.inventory.append(loot["items"])
	
	add_log_entry(loot_message)
	enemy_defeated.emit(current_enemy, loot)
	player_stats_updated.emit()
	
	# Reset current_enemy to allow new encounters
	current_enemy = null

func _end_dungeon_failure() -> void:
	is_in_dungeon = false
	add_log_entry("You failed to complete the dungeon. Better luck next time!")
	# Optionally, reset dungeon state or handle failure consequences

func _update_inventory() -> void:
	var inventory_text = ""
	for item_id in player.inventory:
		var item = ItemsData.items[item_id]
		inventory_text += item.name + "\n"
	$InventoryPanel/ItemList.text = inventory_text

func get_dungeon_log() -> Array[String]:
	return dungeon_log
