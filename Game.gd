extends Control


onready var game_info = $Background/MarginContainer/Columns/Rows/GameInfo
onready var command_processor = $CommandProcessor
onready var room_manager = $RoomManager
onready var player = $Player
onready var turn_manager = $TurnManager
onready var pokemons = turn_manager.get_children()
onready var plr_pokemon = pokemons[0]
onready var hp_lbl_1 = $Background/MarginContainer/Columns/SidePanel/MarginContainer/Rows/ListArea/ExitLabel
onready var hp_lbl_2 = $Background/MarginContainer/Columns/SidePanel/MarginContainer/Rows/ListArea/NpcLabel

func _ready() -> void: 
	turn_manager.connect("transitioned", self, "handle_turn_started")
	pokemons[0].connect("health_updated", self, "handle_health_updated")
	pokemons[1].connect("health_updated", self, "handle_health_updated")
	
	var side_panel = $Background/MarginContainer/Columns/SidePanel
	command_processor.initialize(player, pokemons)
	
	#var starting_room_response = command_processor.initialize(room_manager.get_child(0), player)
	game_info.create_response(Types.wrap_speech_text("A wild " + pokemons[1].name + " appeared!"))
	game_info.create_response("What will " + pokemons[0].name + " do?")

func handle_turn_started(pokemon_name: String) -> void:
	var pokemon = turn_manager.find_node(pokemon_name)
	if pokemon == plr_pokemon:
		game_info.create_response("What will " + plr_pokemon.name + " do?")
		return
	if pokemon.health <= 0:
		return
	var rand_action = pokemon.get_random_action()
	game_info.create_response(pokemon.use_move_or_item(rand_action, plr_pokemon))
	turn_manager.transition_to(plr_pokemon.name)

func handle_health_updated(doer, pokemon, health, by_value):
	# LOL IM RUNNING OUT OF TIME!11
	hp_lbl_1.text = plr_pokemon.name + "'s HP: " + str(plr_pokemon.health)
	hp_lbl_2.text = pokemons[1].name + "'s HP: " + str(pokemons[1].health)
	if doer == plr_pokemon:
		return
	#var health_status = " gained " if sign(by_value) == 1 else " lost "
	#game_info.create_response(pokemon.name + str(health_status) + str(by_value) + " HP!")

func _on_Input_text_entered(new_text: String) -> void:
	if new_text.empty():
		return

	var response = command_processor.process_command(new_text)
	game_info.create_response_with_input(response.msg, new_text)
	if response.has("end_turn") and response.end_turn:
		if plr_pokemon.health <= 0:
			game_info.create_response(Types.wrap_system_text("We lose? :()"))
			return
		elif pokemons[1].health <= 0:
			game_info.create_response(Types.wrap_system_text("We win!"))
			return
		game_info.create_response(Types.wrap_system_text("Waiting for opponent move..."))
		yield(get_tree().create_timer(2), "timeout")
		turn_manager.transition_to(pokemons[1].name)
