extends Node

var saved_time

## CHARACTER
var playable_classes: Dictionary = {
	"Knight": "A vaillant fighter for the kingdom.",
	"Mage": "A user of the aracne.",
	"NPC": "A non-playable character. What is this class doing here?",
}
var character_class: String = "Knight"
var character_strength:= 15
var character_agility:= 5
var character_wisdom:= 9
