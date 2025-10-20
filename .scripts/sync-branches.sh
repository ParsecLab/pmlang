#!/bin/bash
set -e

# Определяем текущую ветку основного репозитория
MAIN_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "🌀 Основной репозиторий на ветке: $MAIN_BRANCH"
echo "→ Переключаем все дочерние репозитории на ту же ветку..."

for module in $(git config --file .gitmodules --get-regexp path | awk '{ print $2 }'); do
  (
    cd "$module"
    echo "  • [$module]"
    git fetch origin

    # Проверяем, есть ли такая ветка в дочернем репозитории
    if git show-ref --verify --quiet refs/heads/$MAIN_BRANCH; then
      git checkout $MAIN_BRANCH
    else
      echo "    ⚠️  Ветки '$MAIN_BRANCH' нет — создаю от origin/$MAIN_BRANCH..."
      git checkout -b $MAIN_BRANCH origin/$MAIN_BRANCH || true
    fi

    git pull origin $MAIN_BRANCH || true
  )
done

echo "✅ Все дочерние репозитории синхронизированы с веткой '$MAIN_BRANCH'"
