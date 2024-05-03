extends Area3D

signal eat(food : Object,eater : Object)
var is_being_eaten = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
var isFood = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if is_being_eaten != true:
		if body.is_in_group("Creature"):
			is_being_eaten = true
			$AudioStreamPlayer3D.play()
			await get_tree().create_timer(0.83).timeout
			eat.emit(self,body)
		
		
