extends Resource
class_name InventoryData


@export var slots: Array[InventorySlot]
var item_found = false

func inventory_stack(object: ItemData):
	for slot in slots:
		if slot.item == object:
			slot.quantity += 1
			print("adding another item to current stack")
			item_found = true
	if item_found == false:
		var new_slot = InventorySlot.new()
		new_slot.quantity = 1
		new_slot.item = object
		Global.Inventory.slots.append(new_slot)

func use_item(object: ItemData, unit: BattleUnit):
	for slot in slots:
		if slot.item == object:
			if slot.quantity == 0:
				slots.erase(slot)
			else:
				slot.quantity -= 1
				unit.current_hp += object.health_restored
				print(unit.name, " healed by +", object.health_restored)
