extends Resource
class_name InventoryData


@export var slots: Array[InventorySlot]

func inventory_stack(object: ItemData):
	for slot in slots:
		if slot.item == object:
			slot.quantity += 1
			print("adding another item to current stack")
		else:
			print("add new slot here")

func use_item(object: ItemData, unit: BattleUnit):
	for slot in slots:
		if slot.item == object:
			if slot.quantity == 0:
				slots.erase(slot)
			else:
				slot.quantity -= 1
				unit.current_hp += object.health_restored
				print(unit.name, " healed by +", object.health_restored)
