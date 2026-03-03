package convert

import (
	"fmt"
	"math"
)

// Unit represents a measurement unit with conversion factors.
type Unit struct {
	ID           string
	Name         string
	NamePlural   string
	System       string // "metric", "us", "universal"
	Dimension    string // "mass", "volume", "temperature", "length", "count"
	ToBaseFactor float64
	ToBaseOffset float64
}

// IngredientDensity holds density data for volume<->mass conversion.
type IngredientDensity struct {
	IngredientID string
	DensityGML   float64 // grams per milliliter
	Notes        string
}

// ConversionResult holds the result of a display conversion.
type ConversionResult struct {
	Quantity float64
	UnitName string
	UnitID   string
}

// ToMetricBase converts a value from any unit to its metric base.
// Mass base: grams. Volume base: ml. Temperature base: °C.
func ToMetricBase(value float64, unit Unit) (float64, string) {
	if unit.Dimension == "temperature" {
		// For temperature: value_base = (value - offset) / factor
		// °F to °C: (°F - 32) / 1.8
		// °C to °C: (°C - 0) / 1 = °C
		baseValue := (value - unit.ToBaseOffset) / unit.ToBaseFactor
		return baseValue, unit.Dimension
	}
	return value * unit.ToBaseFactor, unit.Dimension
}

// FromMetricBase converts from metric base unit to target unit.
func FromMetricBase(baseValue float64, unit Unit) float64 {
	if unit.Dimension == "temperature" {
		// °C to °F: (°C * 1.8) + 32
		return baseValue*unit.ToBaseFactor + unit.ToBaseOffset
	}
	return baseValue / unit.ToBaseFactor
}

// ConvertForDisplay converts a quantity for display in the target unit system.
// For same-dimension conversions, uses simple ratios.
// For cross-dimension (mass<->volume), uses ingredient density.
func ConvertForDisplay(quantity float64, fromUnit Unit, targetSystem string, density *IngredientDensity, availableUnits []Unit) (*ConversionResult, error) {
	// If already in the target system, return as-is
	if fromUnit.System == targetSystem || fromUnit.System == "universal" {
		return &ConversionResult{
			Quantity: quantity,
			UnitName: fromUnit.Name,
			UnitID:   fromUnit.ID,
		}, nil
	}

	// Convert to metric base first
	baseValue, dimension := ToMetricBase(quantity, fromUnit)

	// Find appropriate target unit in the target system
	targetUnit, err := findBestUnit(baseValue, dimension, targetSystem, availableUnits)
	if err != nil {
		// Try cross-dimension if density is available
		if density != nil && (dimension == "mass" || dimension == "volume") {
			return convertCrossDimension(baseValue, dimension, targetSystem, density, availableUnits)
		}
		return nil, fmt.Errorf("no suitable %s unit found in %s system", dimension, targetSystem)
	}

	result := FromMetricBase(baseValue, *targetUnit)
	return &ConversionResult{
		Quantity: RoundForDisplay(result),
		UnitName: targetUnit.Name,
		UnitID:   targetUnit.ID,
	}, nil
}

// convertCrossDimension handles mass<->volume conversion using density.
func convertCrossDimension(baseValue float64, fromDimension, targetSystem string, density *IngredientDensity, availableUnits []Unit) (*ConversionResult, error) {
	var targetDimension string
	var convertedBase float64

	if fromDimension == "mass" {
		// grams to ml: ml = g / density
		targetDimension = "volume"
		convertedBase = baseValue / density.DensityGML
	} else {
		// ml to grams: g = ml * density
		targetDimension = "mass"
		convertedBase = baseValue * density.DensityGML
	}

	targetUnit, err := findBestUnit(convertedBase, targetDimension, targetSystem, availableUnits)
	if err != nil {
		return nil, fmt.Errorf("no suitable %s unit found in %s system for cross-dimension conversion", targetDimension, targetSystem)
	}

	result := FromMetricBase(convertedBase, *targetUnit)
	return &ConversionResult{
		Quantity: RoundForDisplay(result),
		UnitName: targetUnit.Name,
		UnitID:   targetUnit.ID,
	}, nil
}

// findBestUnit selects the most appropriate unit for display.
func findBestUnit(baseValue float64, dimension, system string, units []Unit) (*Unit, error) {
	var best *Unit
	bestScore := math.MaxFloat64

	for i := range units {
		u := &units[i]
		if u.System != system || u.Dimension != dimension {
			continue
		}
		// Score by how "human-friendly" the result would be
		converted := FromMetricBase(baseValue, *u)
		// Prefer values between 0.25 and 1000
		score := math.Abs(math.Log10(math.Max(math.Abs(converted), 0.001)))
		if best == nil || score < bestScore {
			best = u
			bestScore = score
		}
	}
	if best == nil {
		return nil, fmt.Errorf("no unit found for dimension %s in system %s", dimension, system)
	}
	return best, nil
}

// RoundForDisplay rounds a value to a sensible number of decimal places.
func RoundForDisplay(v float64) float64 {
	if math.Abs(v) >= 100 {
		return math.Round(v)
	}
	if math.Abs(v) >= 10 {
		return math.Round(v*10) / 10
	}
	return math.Round(v*100) / 100
}

// CelsiusToFahrenheit converts °C to °F.
func CelsiusToFahrenheit(c float64) float64 {
	return c*1.8 + 32
}

// FahrenheitToCelsius converts °F to °C.
func FahrenheitToCelsius(f float64) float64 {
	return (f - 32) / 1.8
}

// GramsToCups converts grams to US cups using ingredient density.
func GramsToCups(grams float64, densityGPerML float64) float64 {
	ml := grams / densityGPerML
	cups := ml / 236.588
	return RoundForDisplay(cups)
}

// CupsToGrams converts US cups to grams using ingredient density.
func CupsToGrams(cups float64, densityGPerML float64) float64 {
	ml := cups * 236.588
	grams := ml * densityGPerML
	return RoundForDisplay(grams)
}
