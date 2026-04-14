# Guia rápido — Coleta de logs do takeover no Android

## Tag padrão

- Tag única usada por Flutter e Android nativo: `IncomingOfferTakeover`.

## Comandos logcat

- Capturar somente a tag do takeover:

```bash
adb logcat -v time -s IncomingOfferTakeover
```

- Salvar em arquivo para anexar no bug:

```bash
adb logcat -v time -s IncomingOfferTakeover > incoming_offer_takeover.log
```

- Filtro extra por palavra-chave (fallback/dedupe/activity):

```bash
adb logcat -v time -s IncomingOfferTakeover | grep -E "fallback_triggered|dedupe_discarded|activity_opened|activity_closed"
```

## Como filtrar por takeover

- Procure por `stage=` no payload de log.
- Stages operacionais principais:
  - `offer_received`
  - `offer_opened`
  - `offer_accept_tapped`
  - `offer_decline_tapped`
  - `offer_expired`
  - `fallback_triggered`
  - `dedupe_discarded`
  - `activity_opened`
  - `activity_closed`
  - `takeover_eligible` / `takeover_not_eligible`

## Como identificar `order_id`, `event_id`, `event_token`

- Cada linha de log inclui pares `chave=valor`.
- Campos a extrair e anexar no relatório QA:
  - `order_id=<...>`: identifica a oferta/pedido.
  - `event_id=<...>`: identifica o evento emitido pela bridge.
  - `event_token=<...>`: token de ação usado para dedupe.

## Como saber se caiu em fallback

- Buscar `stage=fallback_triggered`.
- Casos comuns:
  - payload inválido para abrir activity.
  - takeover bloqueado por controle de exibição.
  - fluxo elegível negado por módulo/tipo/flag.

## Como saber se foi dedupe

- Buscar `stage=dedupe_discarded`.
- Indica ação repetida (ex.: duplo toque ACCEPT/DECLINE com mesmo `event_token`).

## Como saber se a activity abriu/fechou

- Abertura:
  - `stage=activity_opened` com `source=android_notification` ou `source=android_activity`.
- Fechamento:
  - `stage=activity_closed` com `source=android_activity`.

## Pacote mínimo de evidência para enviar ao time

- Build/branch + device + versão Android.
- Timestamp do teste.
- Trecho de log contendo ao menos:
  - um `offer_opened` (ou `fallback_triggered`),
  - resultado final (`offer_accept_tapped` / `offer_decline_tapped` / `offer_expired`),
  - `order_id`, `event_id` e `event_token`.
