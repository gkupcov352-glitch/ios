# Сборка для симулятора (без IPA)

Этот вариант **не делает подписанный IPA** и не требует сертификатов. Результат — `Wraithgram.app`
для iOS Simulator, собранный из того же пропатченного дерева Wraithgram.

> На Windows собрать нельзя: нужны macOS, Xcode и Bazel. Здесь подготовлены исходники и workflow;
> саму сборку делает GitHub Actions (или ваш Mac).

## Вариант 1: GitHub Actions (рекомендуется)

1. Fork `Wraithgram/ios`, клонировать с субмодулями, применить патчи:

   ```powershell
   git clone --recurse-submodules https://github.com/<ваш-логин>/ios.git wg-mod
   cd wg-mod
   python patches\apply.py . --fresh-ui   # --fresh-ui опционален
   ```

2. Закоммитить и запушить изменения. Workflow добавляется патчем автоматически:
   `.github/workflows/build-simulator.yml`.

3. Settings → Secrets and variables → Actions → добавить `TELEGRAM_API_ID` и `TELEGRAM_API_HASH`
   (с https://my.telegram.org). Без них сборка пройдёт с публичным `api_id = 8`, но в логе будет
   предупреждение.

4. Actions → **Build for Simulator (no IPA)** → Run workflow:

   | Поле | Значение |
   |---|---|
   | `bundle_id` | своё, например `com.<вашлогин>.wraithgram.sim` |
   | `runner` | `xcode-27` (версия из `versions.json`) |

5. Скачать артефакт `Wraithgram-simulator-app` (ZIP внутри — `Wraithgram.app`). Это **не .ipa**:
   на iPhone он не ставится и не подписывается.

6. Распаковать ZIP и открыть `Wraithgram.app` в Xcode → Simulator (или перетащить в уже запущенный
   Simulator.app). Симулятор должен соответствовать архитектуре сборки `debug_sim_arm64`
   (Apple Silicon; для Intel-Мака соберите локально с другой конфигурацией).

Job занимает около часа, лимит — 6 часов. При падении скачать артефакт `build-log-simulator`.

## Вариант 2: локально на Mac

```sh
git clone --recurse-submodules https://github.com/<ваш-логин>/ios.git wg-mod
cd wg-mod
python3 patches/apply.py . --fresh-ui
cp build-system/wraithgram-configuration.example.json build-system/wraithgram-configuration.json
# при желании подставить свои api_id / api_hash / bundle_id в этот JSON
sudo xcode-select -s /Applications/Xcode.app
build-system/WGBuild.sh
```

Скрипт печатает `BUILD OK`; лог — `/tmp/wg-build.log`. Приложение будет в
`bazel-bin/Telegram/Telegram.ipa` — это **симуляторный контейнер**, не подписанный IPA для iPhone.
Распакуйте его и откройте `.app` в симуляторе:

```sh
unzip -q bazel-bin/Telegram/Telegram.ipa -d sim-unpack
open -a Simulator
# затем перетащите sim-unpack/Payload/Wraithgram.app в окно симулятора
```

## Что проверить в симуляторе

- Вход по номеру: Push с публичным `api_id` может не прийти (`APP_PUSH_CERT_MISSING`), сообщения
  приходят после открытия приложения. Свои `api_id`/`api_hash` решают проблему с push не всегда —
  нужен push-сертификат для этого `api_id`.
- «О приложении › Сторонние компоненты» — строка `Badge service: exteraGram`.
- «Оформление › Профиль и Настройки › Профиль» — бейджи exteraGram, кнопка обновления каталога.
- «Сообщения › Меню и жесты» (или «Swiftgram › Действия чата») — два новых переключателя:
  двойной тап в Избранное и `#id HH:mm:ss` в строке времени.
- Счётчик бейджей обновится только если `api.exteragram.app` доступен из сети симулятора.

## Частые проблемы

| Симптом | Причина / решение |
|---|---|
| `XCODE_27.2.app is not on this runner` | Выбрать runner с Xcode из `versions.json` |
| `ERROR: ... configuration.json is missing` | Скопировать example-конфиг (см. выше) |
| `No .app was found in bazel-bin/Telegram/Telegram.ipa` | Внутри IPA должен быть `Wraithgram.app`; если сборка упала, откройте `build-log-simulator` |
| Приложение не ставится на iPhone | Это симуляторная сборка; для телефона нужен `docs/BUILD.md` |
| Счётчик бейджей «—» | Сеть/MTProxy блокирует `api.exteragram.app`; проверка на устройстве/CI |
