extends Resource
class_name InventorySlot

@export var item: ItemData
@export var quantity: int = 1



func inventory_sort(slots: ItemData):
	for slot in slots:
		if slot.item == item:
			slot.quantity += 1
