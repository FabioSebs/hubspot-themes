
THEME_NAME := location-theme
THEME_DIR := location-theme
HS ?= hs

.PHONY: theme-create theme-watch theme-upload

theme-create:
	$(HS) cms theme create $(THEME_NAME)

theme-watch:
	$(HS) cms watch $(THEME_DIR) $(THEME_NAME) --initial-upload

theme-upload:
	$(HS) cms upload $(THEME_DIR) $(THEME_NAME)

