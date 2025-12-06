# Stance.gd
class_name Stance extends Resource

var id: String
var description: String

func _init(p_id: String, p_description: String = ""):
    self.id = p_id
    self.description = p_description