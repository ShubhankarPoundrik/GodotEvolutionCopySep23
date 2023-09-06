extends RichTextLabel


func _ready():
	set_text("Initial animals: "+str(GlobalVariables.initial_animal_spawn_number)+", Animals added: "+str(get_parent().get_parent().animals_added))
