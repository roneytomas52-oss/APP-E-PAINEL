# Rollout progressivo — Takeover agressivo de incoming offer

## Princípio de segurança

- **Default de produção: OFF**.
- Só habilitar com opt-in explícito por build.

## Como habilitar por build

- OFF (recomendado por padrão):

```bash
flutter build apk --dart-define=INCOMING_OFFER_AGGRESSIVE_TAKEOVER=false
```

- ON (lote controlado):

```bash
flutter build apk --dart-define=INCOMING_OFFER_AGGRESSIVE_TAKEOVER=true
```

> Observação: existe override de debug/local em runtime para testes técnicos, mas não substitui controle de rollout por build.

## Plano de avanço recomendado

- Fase 1: 5%
- Fase 2: 20%
- Fase 3: 50%
- Fase 4: 100%

Avançar apenas se a fase atual estiver estável no período definido pelo time (ex.: 24-48h).

## O que observar em cada fase

Monitorar mínimos operacionais:

- `fallback_triggered`
- `dedupe_discarded`
- `offer_opened`
- `offer_accept_tapped` / `offer_decline_tapped` / `offer_expired`
- falha de abertura da activity (sintoma: falta de `activity_opened` quando takeover deveria abrir)
- payload não elegível (`takeover_not_eligible` por módulo/tipo/payload)

## Sinais de rollback imediato

- aumento relevante de `fallback_triggered` sem explicação de payload.
- relatos de toque sem ação, dupla ação ou activity presa.
- crescimento de erros operacionais na aceitação/recusa.
- regressão funcional em lockscreen/background/app morto.

## Quando manter takeover OFF

- QA mínimo incompleto.
- alta taxa de payload não elegível.
- inconsistência recorrente entre notificação e ação final.
- ausência de logs úteis (`order_id`/`event_id`/`event_token`) para diagnóstico.

## Quando liberar avanço de fase

- checklist QA obrigatório concluído e aprovado para cenários críticos.
- sem blocker aberto na fase atual.
- métricas estáveis e comportamento esperado em device real.
- capacidade operacional de rollback validada.
