import pytest
from health_metrics import calculate_bmi

def test_calculate_bmi_value():
    bmi = calculate_bmi(70, 175)  # weight in kg, height in cm
    assert round(bmi, 2) == 22.86

def test_calculate_bmi_zero_height():
    with pytest.raises(ValueError):
        calculate_bmi(70, 0)
