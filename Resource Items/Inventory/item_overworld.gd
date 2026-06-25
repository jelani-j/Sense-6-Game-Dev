extends Node2D

var data
@onready var item_sprite  = $Sprite2D

func setup(item: ItemData):
	data = item
	item_sprite.texture = data.icon

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print("item pickup here!")
	Global.Inventory.inventory_stack(data)
	queue_free()
