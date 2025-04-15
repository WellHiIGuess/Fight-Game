class_name CoolDownText
extends Label

func display_cool_down(cool_down: float):
	if cool_down <= 0:
		text = ""
	else:
		text = str(int(cool_down * 10))
