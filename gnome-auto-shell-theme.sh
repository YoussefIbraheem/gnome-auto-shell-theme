#!/usr/bin/env bash

# Schemas
INTERFACE_SCHEMA="org.gnome.desktop.interface"
SHELL_SCHEMA="org.gnome.shell.extensions.user-theme"

# Read current color scheme
COLOR_SCHEME=$(gsettings get $INTERFACE_SCHEMA color-scheme | tr -d "'")

# Read current shell theme
CURRENT_THEME=$(gsettings get $SHELL_SCHEMA name | tr -d "'")

# Where to look for themes
THEME_DIRS=("$HOME/.themes" "/usr/share/themes")

# Possible dark suffixes
DARK_SUFFIXES=(
  "-dark"
  "-Dark"
  "_dark"
  "_Dark"
)

# Find a dark variant
find_dark_variant() {
  local base="$1"
  for dir in "${THEME_DIRS[@]}"; do
    for suffix in "${DARK_SUFFIXES[@]}"; do
      if [[ -d "$dir/${base}${suffix}" ]]; then
        echo "${base}${suffix}"
        return 0
      fi
    done
  done
  return 1
}

# Strip dark suffix to get base theme
strip_dark_suffix() {
  echo "$1" | sed -E 's/([-_](dark|Dark))$//'
}

if [[ "$COLOR_SCHEME" == "prefer-dark" ]]; then
  # Dark mode enabled
  DARK_THEME=$(find_dark_variant "$CURRENT_THEME")

  if [[ -n "$DARK_THEME" ]]; then
    gsettings set $SHELL_SCHEMA name "$DARK_THEME"
  fi
else
  # Light mode enabled
  BASE_THEME=$(strip_dark_suffix "$CURRENT_THEME")
  gsettings set $SHELL_SCHEMA name "$BASE_THEME"
fi
