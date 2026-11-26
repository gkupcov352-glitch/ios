# Сборка: симулятор (без IPA) и IPA для iPhone

Сборка делается **в вашем fork** Wraithgram. Локально (Windows) патчи только подготавливаются;
готовых бинарников здесь нет.

## 0. Сборка без IPA

Если нужен только проверяемый билд без подписи и сайдлоада, используйте
**Build for Simulator (no IPA)** — инструкция в [docs/BUILD_SIMULATOR.md](BUILD_SIMULATOR.md).
Workflow из патча собирает `Wraithgram.app` и кладёт его в артефакт ZIP (не `.ipa`).
Ниже описан вариант с IPA для установки на iPhone.

## 1. Fork и патчи

В GitHub: Fork `Wraithgram/ios` → клонировать с субмодулями:

```powershell
git clone --recurse-submodules https://github.com/<ваш-логин>/ios.git wg-mod
cd wg-mod
```

Скопировать содержимое этой папки (`patches/`, `docs/`, `README.md`) в корень клона, затем:

```powershell
python patches\apply.py . --fresh-ui
```

`--fresh-ui` опционален (меняет дефолты оформления). Без него бейдж всё равно будет работать.
Готовые unified-патчи лежат в `patches/generated/`: базовый `wg-mod.patch` и вариант
`wg-mod-with-fresh-ui.patch` (старые имена `wg-extera-badge*.patch` сохраняются как копии). Скрипт:

- скопирует `Wraithgram/Features/ExteraBadge/**` и `Wraithgram/Features/QuickActions/**`;
- скопирует `.github/workflows/build-simulator.yml` (сборка без IPA);
- добавит обе зависимости в `Wraithgram/Features/BUILD`;
- добавит `import`/`register()` для обоих модулей в `WGFeatures.swift`;
- добавит атрибуцию exteraGram в «О приложении»;
- создаст unified-патч в `patches/generated/` для проверки.

Проверьте `git diff`, затем:

```powershell
git add Wraithgram patches docs README.md
git commit -m "Add WGExteraBadge (public exteraGram badge feed)"
git push
```

## 2. Секреты и запуск

В fork: **Settings → Secrets and variables → Actions → New repository secret**:

| Имя | Значение |
|---|---|
| `TELEGRAM_API_ID` | ваш `api_id` с https://my.telegram.org |
| `TELEGRAM_API_HASH` | ваш `api_hash` |

Если секретов нет, workflow соберётся с публичным `api_id = 8` Telegram и предупредит об этом.
Такой билд работает, но **push-уведомления могут не прийти** (`APP_PUSH_CERT_MISSING`).

Вкладка **Actions → Build IPA for re-signing → Run workflow**:

| Поле | Значение |
|---|---|
| `bundle_id` | уникальный, например `com.<вашлогин>.wraithgram` (НЕ `ph.telegra.Telegraph`) |
| `build_number` | `1`, затем увеличивать |
| `runner` | `xcode-27` (версия Xcode из `versions.json`) |

Job занимает ~1 ч 20 мин на стандартном раннере, лимит — 6 часов. Артефакт
`Wraithgram-for-resign-<build number>` хранится 3 дня. При ошибке скачать артефакт `build-log`.

## 3. Подпись и установка

1. Скачать и распаковать артефакт, получить `Wraithgram-for-resign.ipa`.
2. Подписать на iPhone одним из способов:
   - **ESign**: импортировать сертификат + `.p12` + `.mobileprovision`, добавить IPA,
     подписать с тем же `bundle_id`, что указан при сборке, установить.
   - **LCSign / AltStore**: подписать через свой Apple ID (7 дней) или платный сертификат.
3. Убедиться, что `bundle_id` в подписи совпадает с собранным, иначе установка не пройдёт.
4. Открыть приложение → ввести номер → проверить бейдж по инструкции
   [docs/BADGE_CONTRACT.md](BADGE_CONTRACT.md).

## 4. Частые проблемы

| Симптом | Причина / решение |
|---|---|
| `Xcode_27.2.app is not on this runner` | Не тот runner; выберите `xcode-27` |
| `APP_PUSH_CERT_MISSING` / нет пушей | Нет своих `api_id`/`api_hash` или нет push-сертификата |
| Счётчик бейджей «—» | `api.exteragram.app` недоступен, включён MTProxy/WEB-прокси или сеть блокирует запрос |
| Бейдж не появился у друга | Его ID нет в публичном `/profiles`; сервер не вернул запись |
| Сборка падает на тестах | Проверьте, что патч применён к чистой копии Wraithgram; запустите `python patches\apply.py <repo>` повторно — он идемпотентен |

## 5. Что не делать

- Не выдавайте сборку за официальный exteraGram/Telegram.
- Не добавляйте локальный «белый список саппортеров» — бейдж должен приходить от сервера.
- Не используйте чужие `api_id`/`api_hash`.
- Не включайте ghost-функции, если это нарушает правила вашего аккаунта.
