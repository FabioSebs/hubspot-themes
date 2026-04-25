
LOCATION_THEME_DIR := location-theme
SERVICE_THEME_DIR := service-theme
SERVICE_LOCATION_THEME_DIR := service-location-theme

HS ?= hs

.PHONY: theme-create-location theme-watch-location theme-upload-location theme-create-service theme-watch-service theme-upload-service theme-create-service-location theme-watch-service-location theme-upload-service-location

theme-create-location:
	$(HS) cms theme create $(LOCATION_THEME_DIR)

theme-watch-location:
	$(HS) cms watch $(LOCATION_THEME_DIR) $(LOCATION_THEME_DIR) --initial-upload

theme-upload-location:
	$(HS) cms upload $(LOCATION_THEME_DIR) $(LOCATION_THEME_DIR)

theme-create-service:
	$(HS) cms theme create $(SERVICE_THEME_DIR)

theme-watch-service:
	$(HS) cms watch $(SERVICE_THEME_DIR) $(SERVICE_THEME_DIR) --initial-upload

theme-upload-service:
	$(HS) cms upload $(SERVICE_THEME_DIR) $(SERVICE_THEME_DIR)

theme-create-service-location:
	$(HS) cms theme create $(SERVICE_LOCATION_THEME_DIR)

theme-watch-service-location:
	$(HS) cms watch $(SERVICE_LOCATION_THEME_DIR) $(SERVICE_LOCATION_THEME_DIR) --initial-upload

theme-upload-service-location:
	$(HS) cms upload $(SERVICE_LOCATION_THEME_DIR) $(SERVICE_LOCATION_THEME_DIR)