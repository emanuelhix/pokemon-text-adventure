class_name Pokemon
extends State

var health : float = 100
var moves : Dictionary = {}

signal health_updated(doer, pokemon, new_health, by_value)
signal move_used()

func can_use(move_or_item: String) -> bool:
	return moves.has(move_or_item)

func get_random_action():
	var moves = self.moves.keys()
	return moves[randi()%moves.size()-1]

func use_move_or_item(request: String, other_pokemon):
	var health_update = moves.get(request).call_func(other_pokemon)
	
	if health_update < 0:
		other_pokemon.health += health_update
		other_pokemon.health = clamp(other_pokemon.health, 0, 100)
		var is_effective = health_update > 30;
		emit_signal("health_updated", self, other_pokemon, other_pokemon.health, health_update)
		return PoolStringArray([
		Types.wrap_npc_text(self.name) + " used " + Types.wrap_npc_text(request) + ".",
		Types.wrap_item_text(other_pokemon.name) + " lost " + str(health_update) + " HP!",
		"It was very effective!" if is_effective else "",
	]).join("\n")
	else:
		self.health += health_update
		self.health = clamp(self.health, 0, 100)
		emit_signal("health_updated", self, self, health, health_update)
		return PoolStringArray([
		Types.wrap_npc_text(self.name) + " used " + Types.wrap_location_text(request) + ".",
		Types.wrap_npc_text(self.name) + " gained " + str(health_update) + " HP!",
		]).join("\n")
	

func update_health(by_value : float):
	health += by_value;
	emit_signal("health_updated", self, health, by_value)
