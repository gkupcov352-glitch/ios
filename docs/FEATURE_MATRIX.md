# Матрица возможностей

## База: Wraithgram/ios

В репозитории Wraithgram уже реализованы и собираются модули:

| Модуль | Что даёт |
|---|---|
| `WGGhostMode` | скрытие статуса набора/просмотра, задержки отправки, исключения |
| `WGAntiDelete` | история удалённых/изменённых сообщений |
| `WGSecurity` | пароль на чаты, секретная папка, защита от forwarding |
| `WGInterface`, `WGAppearance` | оформление чатов, бабблов, шрифтов, тем, анимаций |
| `WGVoice`, `WGCameraMasks`, `WGCallsMedia` | голос, маски, звонки, загрузки/субтитры |
| `WGVless`, `WGNetworkSpoof` | сетевые настройки |
| `WGProfileExport`, `WGSessionBackup` | экспорт профиля/чатов, бэкап аккаунтов |
| `WGRegDate`, `WGExtras` | дата регистрации, набор «Swiftgram-parity» фич |

Это закрывает запрос «приватность + история + кастомизация» без портирования стороннего кода.

## Новое: WGExteraBadge

| Возможность | Реализация |
|---|---|
| Реальный коннект к exteraGram | `WGExteraBadgeAPI`: anonymous `GET https://api.exteragram.app/api/v1/profiles` |
| Статус саппортера | из поля `status == "SUPPORTER"` сервера; текст бейджа — из `badge.text` |
| Статус разработчика | из `status == "DEVELOPER"` |
| Кэш | `WGSetting<WGExteraBadgeSnapshot>` с флагом `.noExport`, ETag, интервал 600 с |
| Профиль | info-строка «Саппортер/Разработчик exteraGram» + мини-бейдж у имени |
| Список чатов | мини-бейдж рядом с заголовком пользовательского чата |
| Настройки | «Оформление › Профиль и Настройки › Профиль»: включение, места показа, «Обновить список бейджей» |
| Приватность | в URL не уходит ID; никаких токенов/DeviceCheck; `WGNetwork` — только HTTPS и SOCKS5-проки |
| Атрибуция | «О приложении › Сторонние компоненты»: «Badge service: exteraGram» + ссылка на GitHub |

## Новое: WGQuickActions (идеи из Reza)

Реализовано с нуля через публичные `WGHooks`; код Reza/Ghostgram не копировался, сабмодули не правятся.

| Возможность | Реализация |
|---|---|
| Двойной тап → повтор в Избранное | `WGMessageGestureHooks.tap` (order 50, после встроенного «двойной тап — изменить»), отправка через `WGForwardSend` |
| ID и секунды в строке времени | `WGMessageDecorationHooks.decorations` (order 950): `#<id> <HH:mm:ss>` добавляется к существующему статусу, не затирая «удалено/изменено» |
| Включение | Два переключателя в разделе действий чата; по умолчанию выключены |
| Источник идеи | Reza / Regram-ios (`docs/features.md`): double-tap actions и отображение message ID / секунд |

## Сборка без IPA

| Что | Где |
|---|---|
| Симуляторный workflow | `.github/workflows/build-simulator.yml` (добавляется патчем) |
| Результат | `Wraithgram.app` в ZIP-артефакте `Wraithgram-simulator-app`, не `.ipa` |
| Локально на Mac | `build-system/WGBuild.sh`, конфигурация из example-файла |
| Подробности | [docs/BUILD_SIMULATOR.md](BUILD_SIMULATOR.md) |

## Что НЕ входит в этот набор

| Источник | Почему не портировано напрямую |
|---|---|
| exteraGram Android (Java/Kotlin) | Другая платформа; используется только как контракт API и идеи |
| VoidGram iOS (`.plugin`, JS-плагины, MessageShot, музыка/лирика) | Другая база (`Telegram-iOS fb0e62ba…`); патчи не применяются к Wraithgram. См. `vg-src/VoidGram-main/patches` как референс |
| AyuGram | Android/Desktop; референс по фичам, не код для iOS |
| Локальная выдача бейджа | Запрещено задачей: бейдж должен приходить от сервера exteraGram |

## Что искали ещё

| Источник | Что дало | Почему не портировали целиком |
|---|---|---|
| Reza / Regram-ios | Много фич: bookmarks, recent chats, local notes, ReSieve, LLM, DC-диагностика, double-tap actions, ID/секунды | Другая ветка 13.2, много правок upstream; взяты только две компактные идеи через WGHooks |
| Ghostgram | Privacy/history, та же линия 13.0, `GGHooks` | Большая часть уже есть в Wraithgram; прямое копирование модулей не нужно |
| Swiftgram | Идеи для меню/жестов/перевода | Wraithgram уже содержит «Swiftgram-parity» слой и свои реализации |
| xntaylerx-lab (visual quote), BetterTG, TGExtra | Прототипы UI / другой клиент | Требуют чужие базы и глубокие правки bubble-кода; фаза 2 |

## Фаза 2 (по желанию)

Если захотите плагины/музыку/MessageShot — это отдельный проект: либо порт выбранных патчей
VoidGram на Wraithgram с адаптацией хуков, либо сборка на базе VoidGram. Из Reza/Ghostgram пока
взяты только две компактные идеи (см. `WGQuickActions` выше); LLM, ReSieve, bookmarks UI,
DC-диагностика и полный ghost-режим требуют другой базы или правок upstream и не включаются,
чтобы не сломать стабильный Wraithgram-билд.
