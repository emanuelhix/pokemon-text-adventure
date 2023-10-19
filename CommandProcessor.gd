extends Node


signal room_changed(new_room)
signal room_updated(current_room)

var current_room = null
var player = null
onready var turn_manager = get_parent().find_node("TurnManager")
var pokemon = []

func initialize(player, pokemon):
	self.player = player
	self.pokemon = pokemon

func process_command(input: String) -> Dictionary:
	if turn_manager.state != pokemon[0]:
		return {msg = ""}

	var words = input.split(" ", false)
	if words.size() == 0:
		return {msg = "Error: no words were parsed."}

	var first_word = words[0].to_lower()
	var second_word = ""
	if words.size() > 1:
		second_word = words[1].to_lower()

	match first_word:
		"moves":
			return moves()
		"use":
			return use(second_word)
		"run":
			return run()
		_:
			return {msg = Types.wrap_system_text("Unrecognized command - please try again.")}


func go(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Go where?")

	if current_room.exits.keys().has(second_word):
		var exit = current_room.exits[second_word]
		if exit.is_locked:
			return "The way " + Types.wrap_location_text(second_word) + " is currently " + Types.wrap_system_text("locked!")

		var change_response = change_room(exit.get_other_room(current_room))
		return PoolStringArray(["You go " + Types.wrap_location_text(second_word) + ".", change_response]).join("\n")
	else:
		return "This room has no " + Types.wrap_location_text(second_word) + " exit."

func take(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Take what?")

	for item in current_room.items:
		if second_word.to_lower() == item.item_name.to_lower():
			current_room.remove_item(item)
			player.take_item(item)
			emit_signal("room_updated", current_room)
			return "You take the " + Types.wrap_item_text(second_word) + "."

	return "There is no " + Types.wrap_item_text(second_word) + " here."


func drop(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Drop what?")

	for item in player.inventory:
		if second_word.to_lower() == item.item_name.to_lower():
			player.drop_item(item)
			current_room.add_item(item)
			emit_signal("room_updated", current_room)
			return "You drop the " + Types.wrap_item_text(item.item_name) + "."

	return "You don't have anything called " + Types.wrap_item_text(second_word) + "."


func inventory() -> String:
	return player.get_inventory_list()

func run() -> Dictionary:
	return {msg= "You failed to run away!"}

func use(second_word: String) -> Dictionary:
	if second_word == "":
		return {msg = Types.wrap_system_text("Use what?"), end_turn = false}
	
	if turn_manager.state.can_use(second_word):
		return {msg= pokemon[0].use_move_or_item(second_word, pokemon[1]), end_turn= true}

	return {msg = "You don't have " + Types.wrap_item_text(second_word) + ".", end_turn = false}


func talk(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Talk to who?")

	for npc in current_room.npcs:
		if npc.npc_name.to_lower() == second_word:
			var dialog = npc.post_quest_dialog if npc.has_received_quest_item else npc.initial_dialog
			return Types.wrap_npc_text(npc.npc_name + ": ") + Types.wrap_speech_text("\"" + dialog + "\"")

	return "There is no " + Types.wrap_npc_text(second_word) + " here."


func give(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Give what?")

	var has_item := false
	for item in player.inventory:
		if second_word.to_lower() == item.item_name.to_lower():
			has_item = true

	if not has_item:
		return "You don't have a " + Types.wrap_item_text(second_word) + "."

	for npc in current_room.npcs:
		if npc.quest_item != null and second_word.to_lower() == npc.quest_item.item_name.to_lower():
			npc.has_received_quest_item = true

			if npc.quest_reward != null:
				var reward = npc.quest_reward
				if "is_locked" in reward:
					reward.is_locked = false
				else:
					printerr("Warning - tried to have a quest reward type that is not implemented.")

			player.drop_item(second_word)
			return "You give the " + Types.wrap_item_text(second_word) + " to the " +  Types.wrap_npc_text(npc.npc_name) + "."

	return "Nobody here wants a" + Types.wrap_item_text(second_word) + "."


func help() -> String:
	return PoolStringArray([
		"You can use these commands: ",
		" go " + Types.wrap_location_text("[location]"),
		" take " + Types.wrap_item_text("[item]"),
		" drop " + Types.wrap_item_text("[item]"),
		" use " + Types.wrap_item_text("[item]"),
		" talk " + Types.wrap_npc_text("[npc]"),
		" give " + Types.wrap_item_text("[item]"),
		" inventory",
		" help"
	]).join("\n")

func moves() -> Dictionary:
	var moves = pokemon[0].moves.keys()
	return {msg = PoolStringArray(moves).join("\n")}

func change_room(new_room: GameRoom) -> String:
	current_room = new_room
	emit_signal("room_changed", new_room)
	return new_room.get_full_description()
