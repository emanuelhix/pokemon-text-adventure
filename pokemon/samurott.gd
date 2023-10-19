class_name Samurott
extends Pokemon

func heal(enemy_pokemon : Pokemon) -> int:
	return 10

func ember(enemy_pokemon : Pokemon) -> int:
	var damage = randi()%32+1 
	damage *= -1
	return damage

func normal_attack(enemy_pokemon : Pokemon) -> int:
	var damage = randi()%15+1
	damage *= -1
	return damage

# Called when the node enters the scene tree for the first time.
func _ready():
	self.moves["water_gun"] = funcref(self, "ember")
	self.moves["slash"] = funcref(self, "normal_attack")
	self.moves["razor_shell"] = funcref(self, "normal_attack")
	self.moves["tackle"] = funcref(self, "normal_attack")
	self.moves["aqua_jet"] = funcref(self, "ember")
	self.moves["hydro_pump"] = funcref(self, "ember")
	self.moves["antidote"] = funcref(self, "heal")
	self.moves["heal_powder"] = funcref(self, "heal")
