extends Resource
class_name AttackData

@export var name: String
@export var damage: int
@export var cost: int
@export_enum("Blunt", "Slicing", "Piercing", "Ballistic", "Emission", "Soul") var attack_type
@export_enum("Poison", "Fire", "Stun", "Electrified", "Bleeding", "Soul Shatterd") var status
@export_enum("Martial-Art","Weapon-art") var attack_category: String
@export var critical_chance: float
@export var status_chance: float
@export var aoe: bool
@export var speed: float 
@export var defense_penetration: int
