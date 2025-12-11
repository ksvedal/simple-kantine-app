package main

import (
	"kantinao-api/internal/handlers"
	"kantinao-api/internal/platform"
	"kantinao-api/internal/services"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	rdb := platform.ConnectRedis()

	router := gin.Default()

	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	menuHandler := handlers.MenuHandler{Service: services.NewMenuService(rdb)}

	router.GET("/menus", menuHandler.GetAllMenus)
	router.GET("/menus/:id", menuHandler.GetMenu)
	router.POST("/menus", menuHandler.CreateMenu)
	router.PUT("/menus/:id", menuHandler.UpdateMenu)
	router.DELETE("/menus/:id", menuHandler.DeleteMenu)

	if err := router.Run(":7420"); err != nil {
		panic(err)
	}
}
