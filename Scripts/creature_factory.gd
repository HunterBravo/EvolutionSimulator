extends Node3D

@onready var creature_scene = load("res://Scenes/search_ai.tscn")
#used to instance a new creature into the world
func _ready():
	pass
	#var a = (reproduction_gene_swap("11111111","00000000"))
	#print(a)
	#print(binary_to_denary(a))
	#pass

func create_creature(body1 : CharacterBody3D,body2 : CharacterBody3D):
	var creature = creature_scene.instantiate()
	
	var newSpeed = reproduction_gene_swap(body1.speed,body2.speed)
	var newStrength =reproduction_gene_swap(body1.strength,body2.strength)
	var newHealth = reproduction_gene_swap(body1.health,body2.health)
	var newHunger = reproduction_gene_swap(body1.max_hunger,body2.max_hunger)
	
	creature.speed = newSpeed
	creature.strength = newStrength
	creature.health= newHealth
	creature.max_hunger = newHunger
	print("#####TEST#####")
	var placeholder = "Health is %s"
	print(placeholder % creature.health)
	var hungerRate = ((binary_to_denary(newSpeed) + binary_to_denary(newStrength) + binary_to_denary(newHealth)) / 3) / 100
	creature.position = body1.position + Vector3(1,0,1)
	add_child(creature)

func reproduction_gene_swap(genesA :String ,genesB : String) -> String:
	var n_point = randi_range(1,8)
	print("n_point is")
	print(n_point)
	var newString = ""
	for i in range(0,n_point):
		newString = newString + genesA[i]
	for i in range(n_point, genesB.length()):
		newString = newString + genesB[i]
		
	return newString
	
var stored_binary : Array = [128,64,32,16,8,4,2,1]




#CONVERT TO UTIL FUNCTION LATER

#converts genetics to a usable value
#PROCCESS - FOR EACH NON 0, TAKE ITS CORROSPONDING BINARY POSITION AND ADDS IT TO TOTAL
#BINARY PASSED MUST BE 8 BIT / 1 BYTE
func binary_to_denary(binary : String) -> int:
	var total = 0
	var binary_split = binary.split()
	for i in range(0, binary_split.size()):
		if binary_split[i] != '0':
			total = total + stored_binary[i]
	return total
