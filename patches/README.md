# Патчи для Wraithgram

Структура:

```
patches/
  apply.py                                  # идемпотентный applicator + генератор unified diff
  new/
    Wraithgram/Features/ExteraBadge/          # модуль реальных бейджей exteraGram (BUILD + Swift)
    Wraithgram/Features/QuickActions/         # двойной тап в Избранное + ID/секунды сообщения
    Root/.github/workflows/build-simulator.yml# сборка для симулятора без IPA
  generated/
    wg-mod.patch                              # базовый unified diff
    wg-mod-with-fresh-ui.patch                # тот же патч + свежие дефолты оформления
    wg-extera-badge*.patch                    # старые имена, совместимость со старыми инструкциями
```

## Применение

```powershell
python patches\apply.py <корень-клона-Wraithgram> [--fresh-ui]
```

Можно задать имя выходного патча: `--patch-name wg-mod.patch` (по умолчанию зависит от
`--fresh-ui`). Скрипт копирует все файлы из `new/`, делает точечные замены в:

- `Wraithgram/Features/BUILD` — зависимости `WGExteraBadge` и `WGQuickActions`;
- `Wraithgram/Features/Sources/WGFeatures.swift` — `import` и `register()` обоих модулей;
- `Wraithgram/WGSettingsUI/Sources/Screens/WGSettingsDataScreens.swift` — атрибуция exteraGram;
- при `--fresh-ui`: `Wraithgram/Features/Appearance/Settings/Sources/WGAppearanceSettings.swift` —
  дефолты оформления.

Скрипт проверяет якоря до замены и ничего не меняет, если патч уже применён. Generated-патч
перезаписывается только когда были реальные изменения (идемпотентный повторный запуск безопасен).

## Проверка

После применения:

```powershell
git diff --stat
git diff -- Wraithgram/Features/Sources/WGFeatures.swift
python Wraithgram\Strings\check.py
```

Патч в `generated/` можно наложить на чистый форк через `git apply patches/generated/wg-mod.patch`
(но проще и безопаснее использовать `apply.py`, потому что он проверяет якоря).

## Важно

Патч рассчитан на Wraithgram `main` с версиями из `versions.json` (app 13.1.2, Xcode 27.2,
Bazel 9.2.0). Если upstream изменил якоря, `apply.py` сообщит об этом и не сломает файл.
Локальная компиляция на Windows невозможна: нужны macOS/Xcode/Bazel или GitHub Actions.
