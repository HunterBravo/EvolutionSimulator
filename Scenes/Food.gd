extends Area3D

signal eat(food : Object,eater : Object)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
var isFood = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	print("hot body?")
	print(body.name)
	if body.name == "SearchAI":
		eat.emit(self,body)
