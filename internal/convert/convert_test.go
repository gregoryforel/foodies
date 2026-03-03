package convert

import (
	"math"
	"testing"
)

func TestCelsiusToFahrenheit(t *testing.T) {
	tests := []struct {
		celsius    float64
		fahrenheit float64
	}{
		{0, 32},
		{100, 212},
		{-40, -40},
		{180, 356},
		{220, 428},
	}
	for _, tt := range tests {
		got := CelsiusToFahrenheit(tt.celsius)
		if math.Abs(got-tt.fahrenheit) > 0.01 {
			t.Errorf("CelsiusToFahrenheit(%v) = %v, want %v", tt.celsius, got, tt.fahrenheit)
		}
	}
}

func TestFahrenheitToCelsius(t *testing.T) {
	tests := []struct {
		fahrenheit float64
		celsius    float64
	}{
		{32, 0},
		{212, 100},
		{-40, -40},
		{425, 218.33},
	}
	for _, tt := range tests {
		got := FahrenheitToCelsius(tt.fahrenheit)
		if math.Abs(got-tt.celsius) > 0.01 {
			t.Errorf("FahrenheitToCelsius(%v) = %v, want %v", tt.fahrenheit, got, tt.celsius)
		}
	}
}

func TestGramsToCups(t *testing.T) {
	// Flour: density 0.593 g/ml, 1 cup = 236.588 ml
	// 140g flour ≈ 1 cup (140 / 0.593 = 236.1 ml ≈ 1 cup)
	flourDensity := 0.593
	got := GramsToCups(140, flourDensity)
	if math.Abs(got-1.0) > 0.05 {
		t.Errorf("GramsToCups(140, flour) = %v, want ~1.0", got)
	}

	// Sugar: density 0.845 g/ml
	// 200g sugar = 200/0.845 = 236.7 ml ≈ 1 cup
	sugarDensity := 0.845
	got = GramsToCups(200, sugarDensity)
	if math.Abs(got-1.0) > 0.05 {
		t.Errorf("GramsToCups(200, sugar) = %v, want ~1.0", got)
	}
}

func TestCupsToGrams(t *testing.T) {
	// 1 cup flour = 236.588 ml * 0.593 g/ml ≈ 140g
	flourDensity := 0.593
	got := CupsToGrams(1.0, flourDensity)
	if math.Abs(got-140.30) > 1.0 {
		t.Errorf("CupsToGrams(1.0, flour) = %v, want ~140", got)
	}
}

func TestToMetricBase(t *testing.T) {
	// oz to grams: 1 oz = 28.3495 g
	ozUnit := Unit{Name: "oz", Dimension: "mass", ToBaseFactor: 28.3495, ToBaseOffset: 0}
	val, dim := ToMetricBase(1.0, ozUnit)
	if dim != "mass" {
		t.Errorf("expected dimension 'mass', got %s", dim)
	}
	if math.Abs(val-28.3495) > 0.01 {
		t.Errorf("ToMetricBase(1 oz) = %v, want 28.3495", val)
	}

	// °F to °C: 212°F = 100°C
	fUnit := Unit{Name: "°F", Dimension: "temperature", ToBaseFactor: 1.8, ToBaseOffset: 32}
	val, dim = ToMetricBase(212, fUnit)
	if dim != "temperature" {
		t.Errorf("expected dimension 'temperature', got %s", dim)
	}
	if math.Abs(val-100) > 0.01 {
		t.Errorf("ToMetricBase(212°F) = %v, want 100", val)
	}
}

func TestFromMetricBase(t *testing.T) {
	// grams to oz: 100g = 3.527 oz
	ozUnit := Unit{Name: "oz", Dimension: "mass", ToBaseFactor: 28.3495, ToBaseOffset: 0}
	got := FromMetricBase(100, ozUnit)
	if math.Abs(got-3.527) > 0.01 {
		t.Errorf("FromMetricBase(100g) = %v oz, want 3.527", got)
	}

	// °C to °F: 100°C = 212°F
	fUnit := Unit{Name: "°F", Dimension: "temperature", ToBaseFactor: 1.8, ToBaseOffset: 32}
	got = FromMetricBase(100, fUnit)
	if math.Abs(got-212) > 0.01 {
		t.Errorf("FromMetricBase(100°C) = %v°F, want 212", got)
	}
}

func TestRoundForDisplay(t *testing.T) {
	tests := []struct {
		input    float64
		expected float64
	}{
		{0.123, 0.12},
		{1.567, 1.57},
		{15.67, 15.7},
		{156.7, 157},
	}
	for _, tt := range tests {
		got := RoundForDisplay(tt.input)
		if got != tt.expected {
			t.Errorf("RoundForDisplay(%v) = %v, want %v", tt.input, got, tt.expected)
		}
	}
}
