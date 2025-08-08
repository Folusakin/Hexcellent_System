from __future__ import annotations

def calculate_bmi(weight_kg: float, height_cm: float) -> float:
    """Calculate the Body Mass Index (BMI).

    Args:
        weight_kg: Weight of the person in kilograms.
        height_cm: Height of the person in centimeters.

    Returns:
        The BMI as a floating point number.

    Raises:
        ValueError: If ``height_cm`` is not greater than zero.
    """
    if height_cm <= 0:
        raise ValueError("height_cm must be greater than zero")

    height_m = height_cm / 100.0
    return weight_kg / (height_m ** 2)
