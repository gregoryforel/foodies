package handler

import (
	"testing"
)

func TestConvertQuantityForUS(t *testing.T) {
	tests := []struct {
		quantity float64
		unit     string
		expected float64
	}{
		{100, "g", 3.53},       // 100g ≈ 3.53 oz
		{1000, "g", 35.3},     // 1kg ≈ 35.3 oz
		{250, "ml", 8.45},     // 250ml ≈ 8.45 fl oz
		{10, "piece", 10},     // pieces stay as-is
	}
	for _, tt := range tests {
		got := convertQuantityForUS(tt.quantity, tt.unit)
		diff := got - tt.expected
		if diff < 0 {
			diff = -diff
		}
		if diff > 0.1 {
			t.Errorf("convertQuantityForUS(%v, %s) = %v, want ~%v", tt.quantity, tt.unit, got, tt.expected)
		}
	}
}

func TestConvertUnitNameForDisplay(t *testing.T) {
	tests := []struct {
		unit     string
		expected string
	}{
		{"g", "oz"},
		{"ml", "fl oz"},
		{"kg", "lb"},
		{"l", "cups"},
		{"piece", "piece"},
	}
	for _, tt := range tests {
		got := convertUnitNameForDisplay(tt.unit, 1)
		if got != tt.expected {
			t.Errorf("convertUnitNameForDisplay(%s) = %s, want %s", tt.unit, got, tt.expected)
		}
	}
}
