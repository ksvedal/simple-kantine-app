package handlers

import (
	"kantinao-api/internal/models"
	"kantinao-api/internal/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

type MenuHandler struct {
	Service services.MenuService
}

func (h *MenuHandler) CreateMenu(c *gin.Context) {
	var newMenu models.WeekMenu

	if err := c.ShouldBindJSON(&newMenu); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	createdMenu, err := h.Service.CreateWeeklyMenu(&newMenu)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, createdMenu)
}

func (h *MenuHandler) GetAllMenus(c *gin.Context) {
	menus, err := h.Service.GetAllMenus()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, menus)
}

func (h *MenuHandler) GetMenu(c *gin.Context) {
	week := c.Param("week")

	menu, err := h.Service.GetMenuByWeek(week)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, menu)
}

func (h *MenuHandler) UpdateMenu(c *gin.Context) {
	week := c.Param("week")

	var updates map[string]interface{}
	if err := c.ShouldBindJSON(&updates); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	updatedMenu, err := h.Service.UpdateMenuByWeek(week, updates)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, updatedMenu)
}

func (h *MenuHandler) DeleteMenu(c *gin.Context) {
	week := c.Param("week")

	if err := h.Service.DeleteMenuByWeek(week); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "menu deleted successfully"})
}
