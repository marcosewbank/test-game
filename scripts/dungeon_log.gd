extends Panel

@onready var log_text: RichTextLabel = $VBoxContainer/LogText
@onready var game_manager = get_node("/root/GameManager")

func _ready() -> void:
	# Connect to the log_updated signal
	game_manager.log_updated.connect(_on_log_updated)
	
	# Load existing logs if any
	var existing_logs = game_manager.get_dungeon_log()
	for log in existing_logs:
		_on_log_updated(log)

func _on_log_updated(message: String) -> void:
	log_text.append_text(message + "\n") 