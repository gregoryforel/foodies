package main

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gregoryforel/recipe-platform/internal/domain"
	"github.com/gregoryforel/recipe-platform/internal/handler"
	"github.com/gregoryforel/recipe-platform/internal/middleware"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	logger := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))

	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://recipe:recipe@localhost:5432/recipe_platform?sslmode=disable"
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		logger.Error("failed to connect to database", "error", err)
		os.Exit(1)
	}
	defer pool.Close()

	if err := pool.Ping(ctx); err != nil {
		logger.Error("failed to ping database", "error", err)
		os.Exit(1)
	}
	logger.Info("connected to database")

	// Check if --compile-recipes flag is passed
	if len(os.Args) > 1 && os.Args[1] == "compile-recipes" {
		logger.Info("compiling all recipes...")
		if err := domain.CompileAllRecipes(ctx, pool); err != nil {
			logger.Error("failed to compile recipes", "error", err)
			os.Exit(1)
		}
		logger.Info("all recipes compiled successfully")
		return
	}

	h := handler.New(pool, logger)
	mux := http.NewServeMux()
	h.RegisterRoutes(mux)

	wrapped := middleware.Chain(
		mux,
		middleware.Recovery(logger),
		middleware.Logger(logger),
		middleware.UnitSystem,
		middleware.AuthStub,
	)

	srv := &http.Server{
		Addr:         ":" + port,
		Handler:      wrapped,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Graceful shutdown
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		logger.Info("shutting down server...")
		shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer shutdownCancel()
		srv.Shutdown(shutdownCtx)
	}()

	logger.Info(fmt.Sprintf("server starting on :%s", port))
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		logger.Error("server error", "error", err)
		os.Exit(1)
	}
}
