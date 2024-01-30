#!/bin/bash
# Un script bash pour afficher un feu d'artifice avec le nom "EVOLUCARE"
# Source : [1](https://linuxtrack.net/viewtopic.php?id=546)
# Les couleurs possibles
colors=(red green blue purple cyan yellow brown)
# La fonction pour afficher une couleur
function colorstr () {
  local row=$1
  local col=$2
  local color=$3
  local v
  case "$color" in
    red) v=31;;
    green) v=34;;
    blue) v=32;;
    purple) v=35;;
    cyan) v=36;;
    yellow) v=33;;
    brown) v=33;;
    white) v=37;;
    *) v=;;
  esac
  shift 3
  tput cup $row $col
  echo -n -e "\e[$v""m"
  set -f
  echo -n $*
  set +f
}

# La fonction pour afficher un feu d'artifice
function fireworks () {
  local row=$(tput lines)
  local col=$(( (RANDOM % (cols / 2)) + (cols / 4) ))
  local height=$((RANDOM % rows - 2))
  local slant
  local h
  local color1=${colors[$((RANDOM % ${#colors[*]}))]}
  local color2=${colors[$((RANDOM % ${#colors[*]}))]}
  local color3=${colors[$((RANDOM % ${#colors[*]}))]}
  while [[ $color1 == $color2 || $color1 == $color3 || $color2 == $color3 ]]
  do
    color2=${colors[$((RANDOM % ${#colors[*]}))]}
    color3=${colors[$((RANDOM % ${#colors[*]}))]}
  done

  case $((RANDOM % 4)) in
    0) slant=-2;;
    1) slant=-1;;
    2) slant=1;;
    3) slant=2;;
  esac

  if [[ $height -gt 5 ]]; then
    h=$height
    while [[ $h -gt 0 ]]
    do
      colorstr $row $col $color1 '.'
      let row--
      if [[ $((col + slant)) -ge $((cols - 3)) || $((col + slant)) -le 2 ]]; then break; fi
      let col+=slant
      let h--
      sleep 0.1
    done

    if [[ $((col + slant)) -lt $((cols - 3)) && $((col + slant)) -gt 2 ]]; then
      h=$((height / 5))
      while [[ $h -gt 0 ]]
      do
        colorstr $row $col $color2 '.'
        let row++
        if [[ $((col + slant)) -ge $((cols - 3)) || $((col + slant)) -le 2 ]]; then break; fi
        let col+=slant
        let h--
        sleep 0.1
      done
    fi

    colorstr $((row)) $((col - 1)) $color3 '***'
    colorstr $((row - 1)) $((col)) $color3 '*'
    colorstr $((row + 1)) $((col)) $color3 '*'
  fi
}

# La fonction pour afficher le nom "EVOLUCARE"
function evolucare () {
  local row=$((rows / 2))
  local col=$((cols / 2 - 4))
  local color=white
  colorstr $row $col $color 'EVOLUCARE'
}

# Le nombre de feux d'artifice à afficher
n=10

# Le nettoyage de l'écran
clear

# La boucle principale
for i in $(seq 1 $n)
do
  fireworks
  sleep 1
done

# L'affichage du nom "EVOLUCARE"
evolucare
sleep 3

# Le nettoyage de l'écran
clear
