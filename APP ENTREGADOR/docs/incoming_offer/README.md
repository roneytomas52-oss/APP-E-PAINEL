# Incoming Offer — Pacote operacional (QA + Rollout)

## Estado da feature flag

- Chave: `INCOMING_OFFER_AGGRESSIVE_TAKEOVER`
- **Default final: `false` (OFF por padrão)**
- Habilita takeover agressivo apenas com opt-in explícito por build (`--dart-define`).

## Documentos

- Checklist de QA executável: `docs/incoming_offer/qa_checklist.md`
- Guia de coleta de logs Android: `docs/incoming_offer/log_collection_android.md`
- Guia de rollout progressivo: `docs/incoming_offer/rollout_progressivo.md`

## Atalhos de build

```bash
# OFF (padrão seguro)
flutter build apk --dart-define=INCOMING_OFFER_AGGRESSIVE_TAKEOVER=false

# ON (teste controlado)
flutter build apk --dart-define=INCOMING_OFFER_AGGRESSIVE_TAKEOVER=true
```
