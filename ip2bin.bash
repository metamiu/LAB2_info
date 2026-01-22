#!/usr/bin/env bash
if [[ $# -lt 1 ]]; then
  echo "Использование: $0 <IPv4-адрес>"
  echo "Пример:"
  echo "$0 192.168.10.1"
  exit 1
fi

ip="$1"  # первый аргумент

# проверка формата: d.d.d.d (только цифры и точки)
if ! [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
  echo "Ошибка: '$ip' не похож на IPv4-адрес. Пример: 192.168.10.1"
  exit 1
fi

IFS='.' read -r -a octets <<< "$ip"

if (( ${#octets[@]} != 4 )); then
  echo "Ошибка: адрес должен состоять из 4 октетов, разделённых точками."
  exit 1
fi

for oct in "${octets[@]}"; do
  # только цифры
  if ! [[ $oct =~ ^[0-9]+$ ]]; then
    echo "Ошибка: октет '$oct' содержит недопустимые символы."
    exit 1
  fi

  val=$((10#$oct))
  if (( val < 0 || val > 255 )); then
    echo "Ошибка: октет '$oct' вне диапазона 0..255."
    exit 1
  fi
done

masks=(128 64 32 16 8 4 2 1)

result=""
for i in "${!octets[@]}"; do
  val=$((10#${octets[i]}))
  bin=""

  for mask in "${masks[@]}"; do
    if (( val & mask )); then
      bin+="1"
    else
      bin+="0"
    fi
  done

  if (( i < 3 )); then
    result+="${bin}."
  else
    result+="${bin}"
  fi
done

echo "$result"
