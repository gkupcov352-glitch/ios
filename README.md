# Wraithgram + exteraGram badge + Reza-фишки — патчи для iOS-сборки

Набор патчей для **Wraithgram/ios** (база — Telegram iOS 13.1.2). Цель: собрать билд с уже
имеющимися фичами Wraithgram (приватность, история сообщений, кастомизация), добавить **реальный**
бейдж саппортера exteraGram через публичный API (не локальную подделку) и пару компактных фишек
из других iOS-модов. Есть два варианта сборки: для симулятора (**без IPA**) и IPA для iPhone.

> Это **не exteraGram** и не официальный Telegram.Это форк Wraithgram с дополнительным модулем,
> который читает публичный список бейджей exteraGram. Имя/логотип exteraGram не используются как
> имя/иконка приложения; в «О приложении» есть атрибуция и ссылка на репозиторий.

## Что внутри

| Категория | Что делают патчи |
|---|---|
| База | Wraithgram: GhostMode, AntiDelete, Security, Interface/Appearance, SessionBackup, Vless и др. |
| exteraGram | Новый модуль `WGExteraBadge`: `GET https://api.exteragram.app/api/v1/profiles`, ETag-кэш на 10 минут, статусы `SUPPORTER`/`DEVELOPER` |
| UI | Бейдж в профиле (infо-строка + небольшой бейдж у имени) и в списке чатов; включается в «Оформление › Профиль и Настройки › Профиль» |
| Reza-фишки | `WGQuickActions`: двойной тап → повтор в Избранное и `#id HH:mm:ss` в строке времени (идеи из Reza, код свой, через WGHooks) |
| Свежий вид | Опциональный `--fresh-ui`: радиусы бабблов 18 pt и размер стикеров 110% по умолчанию |
| Атрибуция | Строка в «О приложении» со ссылкой на `https://github.com/exteraSquad/exteraGram` |
| Сборка без IPA | Workflow **Build for Simulator (no IPA)**: артефакт — `Telegram.app` в ZIP, не `.ipa` |
| Сборка для iPhone | Workflow Wraithgram **Build IPA for re-signing**, затем подпись IPA на iPhone |

Подробности: [docs/FEATURE_MATRIX.md](docs/FEATURE_MATRIX.md),
[docs/BADGE_CONTRACT.md](docs/BADGE_CONTRACT.md), [docs/BUILD.md](docs/BUILD.md),
[docs/BUILD_SIMULATOR.md](docs/BUILD_SIMULATOR.md).

## Быстрый старт

1. Fork репозитория `Wraithgram/ios` и клонировать его к себе.
2. В корне форка выполнить:

   ```powershell
   python patches\apply.py <путь-к-клону-Wraithgram> --fresh-ui
   ```

   Скрипт скопирует модули и workflow, сделает точечные правки; он идемпотентен и создаст
   `patches/generated/wg-mod.patch` (или `wg-mod-with-fresh-ui.patch` с `--fresh-ui`).
3. Закоммитить изменения. Дальше — один из двух вариантов:
   - **Без IPA:** Actions → **Build for Simulator (no IPA)** → скачать `Wraithgram-simulator-app`
     (ZIP с `Telegram.app`) и открыть в симуляторе. Подробности —
     [docs/BUILD_SIMULATOR.md](docs/BUILD_SIMULATOR.md).
   - **Для iPhone:** Actions → **Build IPA for re-signing** → скачать
     `Wraithgram-for-resign-<build number>`, подписать через ESign/LCSign/AltStore и установить.
     Подробности — [docs/BUILD.md](docs/BUILD.md).

Готового `.ipa` здесь нет: его собирает ваш fork в GitHub Actions. На Windows только подготовка
патчей; реальная компиляция требует macOS/Xcode/Bazel.

## Важное

- Бейдж появляется **только если exteraGram-сервер возвращает ваш ID** в публичном `/profiles`.
  Никакие «свои» статусы локально не выставляются.
- Для входа нужны свои `api_id`/`api_hash` (секреты `TELEGRAM_API_ID`, `TELEGRAM_API_HASH`).
  Push с чужим `api_id` может не прийти (`APP_PUSH_CERT_MISSING`).
- Функции «призрака» (скрытие чтения/набора/статуса) могут нарушать правила Telegram — используйте
  их на свой страх и риск.
- Проверить контракт API из текущей среды не удалось (`ECONNRESET` к `api.exteragram.app`); файлы
  основаны на исходниках exteraGram и требуют проверки на устройстве.

## Лицензии и атрибуция

Wraithgram — source-only форк Telegram iOS. exteraGram — GPLv3 с дополнительными условиями
`ADDITIONAL_TERMS.md`: требуется атрибуция и ссылка на проект, нельзя выдавать мод за exteraGram.
Патч добавляет такую атрибуцию в раздел «О приложении». Идеи для `WGQuickActions` взяты из
[Reza/Regram-ios](https://github.com/RegramDev/Regram-ios); код написан заново через публичные
хуки Wraithgram, исходники Reza в сборку не входят.
