#!/bin/bash

echo "Setting up symlinks..."

link_zsh() {
  ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
}

link_starship() {
  mkdir -p ~/.config
  ln -sf ~/dotfiles/starship/starship.toml ~/.config/starship.toml
}

link_tmux() {
  ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
}

link_wallust() {
  ln -sf ~/dotfiles/wallust ~/.config/wallust
}

link_rofi() {
  ln -sf ~/dotfiles/rofi ~/.config/rofi
}

link_waybar() {
  ln -sf ~/dotfiles/waybar ~/.config/waybar
}

link_nvim() {
  ln -sf ~/dotfiles/nvim ~/.config/nvim
}

link_alacritty() {
  ln -sf ~/dotfiles/alacritty ~/.config/alacritty
}

link_sway() {
  ln -sf ~/dotfiles/sway ~/.config/sway
}

# If no args are passed, link everything
if [ "$#" -eq 0 ]; then
  echo "No components specified. Linking everything..."
  components=(zsh starship tmux wallust rofi waybar nvim alacritty sway)
else
  components=("$@")
fi

for component in "${components[@]}"; do
  func="link_$component"
  if declare -f "$func" > /dev/null; then
    echo "Linking $component..."
    $func
  else
    echo "Warning: No function defined for '$component'"
  fi
done

echo "✅ All selected dotfiles linked."
