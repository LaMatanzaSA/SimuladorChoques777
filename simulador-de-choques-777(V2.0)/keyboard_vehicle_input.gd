class_name KeyboardVehicleInput
extends VehicleInput
## Control por teclado (acciones ui_left / ui_right).

func obtener_direccion() -> float:
	return Input.get_axis("ui_left", "ui_right")
