extends Node2D


var prompt_farmer = FileAccess.open("./Scenes/Main/prompts/farmer.txt", FileAccess.READ).get_as_text()

func _ready():
	$Joseph.start(Vector2(1200, 80), "Joseph", prompt_farmer)
	$Will.start(Vector2(80, 640), "Will", "")
	


func _process(delta):
	$Joseph.list_players = [
		{
			"name": "Will",
			"position": $Will.position
		}
	]
	
	$Will.list_players = [
		{
			"name": "Joseph",
			"position": $Joseph.position
		}
	]
