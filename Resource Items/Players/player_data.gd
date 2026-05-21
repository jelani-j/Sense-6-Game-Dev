extends Resource
class_name PlayerData
@export var name: String
@export var max_hp: int
@export var attack: int
@export var defense: int
@export var speed: float
@export var stamina: float
@export var texture: Texture2D
@export var attacks: Array[AttackData]
@export_enum("Inquisitive","Anxious","Nuerotic","Passionate","Ambitious","Relaxed") var personality_trait
