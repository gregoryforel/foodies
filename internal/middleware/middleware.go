package middleware

import (
	"context"
	"log/slog"
	"net/http"
	"runtime/debug"
	"time"
)

type contextKey string

const (
	UnitSystemKey contextKey = "unit_system"
	UserIDKey     contextKey = "user_id"
)

// Logger logs each request with method, path, status, and duration.
func Logger(logger *slog.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()
			rw := &responseWriter{ResponseWriter: w, status: http.StatusOK}
			next.ServeHTTP(rw, r)
			logger.Info("request",
				"method", r.Method,
				"path", r.URL.Path,
				"status", rw.status,
				"duration", time.Since(start).String(),
			)
		})
	}
}

// Recovery catches panics and returns 500.
func Recovery(logger *slog.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			defer func() {
				if err := recover(); err != nil {
					logger.Error("panic recovered",
						"error", err,
						"stack", string(debug.Stack()),
					)
					http.Error(w, "Internal Server Error", http.StatusInternalServerError)
				}
			}()
			next.ServeHTTP(w, r)
		})
	}
}

// UnitSystem reads unit preference from cookie or defaults to metric.
func UnitSystem(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		system := "metric"
		if c, err := r.Cookie("unit_system"); err == nil {
			if c.Value == "us" || c.Value == "metric" {
				system = c.Value
			}
		}
		ctx := context.WithValue(r.Context(), UnitSystemKey, system)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// AuthStub reads optional X-Demo-User header and sets user context.
func AuthStub(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		userID := r.Header.Get("X-Demo-User")
		if userID != "" {
			ctx := context.WithValue(r.Context(), UserIDKey, userID)
			next.ServeHTTP(w, r.WithContext(ctx))
			return
		}
		next.ServeHTTP(w, r)
	})
}

// Chain applies middleware in order.
func Chain(h http.Handler, middlewares ...func(http.Handler) http.Handler) http.Handler {
	for i := len(middlewares) - 1; i >= 0; i-- {
		h = middlewares[i](h)
	}
	return h
}

// GetUnitSystem retrieves the unit system from context.
func GetUnitSystem(ctx context.Context) string {
	if v, ok := ctx.Value(UnitSystemKey).(string); ok {
		return v
	}
	return "metric"
}

// GetUserID retrieves the user ID from context.
func GetUserID(ctx context.Context) string {
	if v, ok := ctx.Value(UserIDKey).(string); ok {
		return v
	}
	return ""
}

type responseWriter struct {
	http.ResponseWriter
	status int
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.status = code
	rw.ResponseWriter.WriteHeader(code)
}
