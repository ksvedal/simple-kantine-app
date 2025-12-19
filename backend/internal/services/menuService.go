package services

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"kantinao-api/internal/models"

	"github.com/redis/go-redis/v9"
)

type MenuService interface {
	CreateWeeklyMenu(menu *models.WeekMenu) (*models.WeekMenu, error)
	GetAllMenus() ([]*models.WeekMenu, error)
	GetMenuByWeek(week string) (*models.WeekMenu, error)
	UpdateMenuByWeek(week string, updates map[string]interface{}) (*models.WeekMenu, error)
	DeleteMenuByWeek(week string) error
}

type menuService struct {
	rdb *redis.Client
	ctx context.Context
}

func NewMenuService(rdb *redis.Client) MenuService {
	return &menuService{
		rdb: rdb,
		ctx: context.Background(),
	}
}

func (s *menuService) CreateWeeklyMenu(menu *models.WeekMenu) (*models.WeekMenu, error) {
	weekKey := fmt.Sprintf("menu:week:%d", menu.Week)

	jsonData, err := json.Marshal(menu)
	if err != nil {
		return nil, err
	}

	if err := s.rdb.Set(s.ctx, weekKey, jsonData, 0).Err(); err != nil {
		return nil, fmt.Errorf("failed to store menu by week: %w", err)
	}

	return menu, nil
}

func (s *menuService) GetAllMenus() ([]*models.WeekMenu, error) {
	var menus []*models.WeekMenu

	iter := s.rdb.Scan(s.ctx, 0, "menu:*", 50).Iterator()
	for iter.Next(s.ctx) {
		key := iter.Val()

		val, err := s.rdb.Get(s.ctx, key).Result()
		if err != nil {
			return nil, fmt.Errorf("failed to read menu (%s): %w", key, err)
		}

		var menu models.WeekMenu
		if err := json.Unmarshal([]byte(val), &menu); err != nil {
			return nil, fmt.Errorf("failed to decode menu (%s): %w", key, err)
		}

		menus = append(menus, &menu)
	}

	if err := iter.Err(); err != nil {
		return nil, fmt.Errorf("redis scan error: %w", err)
	}

	return menus, nil
}

func (s *menuService) GetMenuByWeek(week string) (*models.WeekMenu, error) {
	key := fmt.Sprintf("menu:week:%s", week)

	val, err := s.rdb.Get(s.ctx, key).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return nil, fmt.Errorf("menu for week %s not found", week)
		}
		return nil, fmt.Errorf("redis error: %w", err)
	}

	var menu models.WeekMenu
	if err := json.Unmarshal([]byte(val), &menu); err != nil {
		return nil, fmt.Errorf("invalid menu format: %w", err)
	}

	return &menu, nil
}

func (s *menuService) UpdateMenuByWeek(week string, updates map[string]interface{}) (*models.WeekMenu, error) {
	menu, err := s.GetMenuByWeek(week)
	if err != nil {
		return nil, err
	}

	for k, v := range updates {
		switch k {
		case "name":
			if newName, ok := v.(string); ok {
				menu.Name = newName
			}
		case "week":
			if newWeek, ok := v.(uint); ok {
				menu.Week = newWeek
			}
		case "day_items":
			if items, ok := v.([]interface{}); ok {
				var dayItems []models.DayMenuItem
				for _, item := range items {
					itemMap, ok := item.(map[string]interface{})
					if !ok {
						continue
					}

					var dayItem models.DayMenuItem

					if day, ok := itemMap["day_of_week"].(string); ok {
						dayItem.DayOfWeek = day
					}
					if likes, ok := itemMap["likes"].(float64); ok {
						dayItem.Likes = int(likes)
					}

					if dishMap, ok := itemMap["dish"].(map[string]interface{}); ok {
						var dish models.Dish
						if name, ok := dishMap["name"].(string); ok {
							dish.Name = name
						}
						if desc, ok := dishMap["description"].(string); ok {
							dish.Description = desc
						}
						if price, ok := dishMap["price"].(float64); ok {
							dish.Price = price
						}
						if allergens, ok := dishMap["allergens"].(string); ok {
							dish.Allergens = allergens
						}
						if spice, ok := dishMap["spice_level"].(string); ok {
							dish.SpiceLevel = spice
						}

						dayItem.Dish = dish
					}

					dayItems = append(dayItems, dayItem)
				}

				menu.DayMenuItems = dayItems
			}
		}
	}

	jsonData, err := json.Marshal(menu)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal updated menu: %w", err)
	}

	key := fmt.Sprintf("menu:week:%s", week)
	if err := s.rdb.Set(s.ctx, key, jsonData, 0).Err(); err != nil {
		return nil, fmt.Errorf("failed to save updated menu: %w", err)
	}

	return menu, nil
}

func (s *menuService) DeleteMenuByWeek(week string) error {
	key := fmt.Sprintf("menu:week:%s", week)

	deleted, err := s.rdb.Del(s.ctx, key).Result()
	if err != nil {
		return fmt.Errorf("failed to delete menu for week %s: %w", week, err)
	}

	if deleted == 0 {
		return fmt.Errorf("menu for week %s not found", week)
	}

	return nil
}
