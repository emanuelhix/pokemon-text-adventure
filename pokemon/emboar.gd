class_name Emboar
extends Pokemon

func heal(enemy_pokemon : Pokemon) -> int:
	return 10

func full_heal(enemy_pokemon : Pokemon) -> int:
	return 100 - int(self.health)

func ember(enemy_pokemon : Pokemon) -> int:
	var damage = randi()%32+1 
	damage *= -1
	return damage

func normal_attack(enemy_pokemon : Pokemon) -> int:
	var damage = randi()%18+1
	damage *= -1
	return damage

# Called when the node enters the scene tree for the first time.
func _ready():
	self.moves["ember"] = funcref(self, "ember")
	self.moves["tackle"] = funcref(self, "normal_attack")
	self.moves["roar"] = funcref(self, "normal_attack")
	self.moves["tail_whip"] = funcref(self, "normal_attack")
	self.moves["flame_thrower"] = funcref(self, "ember")
	self.moves["flair_blitz"] = funcref(self, "ember")
	self.moves["antidote"] = funcref(self, "heal")
	self.moves["heal_powder"] = funcref(self, "heal")
	self.moves["full_heal"] = funcref(self, "full_heal")
