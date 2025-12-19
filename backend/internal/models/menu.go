package models

type WeekMenu struct {
	Name string `json:"name"`
	Week uint   `json:"week"`
	DayMenuItems []DayMenuItem `json:"day_items"`
}

type DayMenuItem struct {
	DayOfWeek string `json:"day_of_week"`
	Likes     int    `json:"likes"`
	Dish      Dish   `json:"dish,omitempty"`
}
