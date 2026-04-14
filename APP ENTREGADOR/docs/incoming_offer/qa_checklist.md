# QA Checklist — Incoming Offer Takeover Agressivo (Android)

> Objetivo: executar validação controlada do takeover agressivo com evidência, logs e decisão de aprovação por cenário.

## Pré-condições

- Build Android instalada no aparelho de teste.
- Conta de entregador apta a receber oferta.
- Acesso ao backend/simulador para disparo de FCM de oferta.
- Flag revisada antes do teste:
  - **OFF (padrão seguro)**: `--dart-define=INCOMING_OFFER_AGGRESSIVE_TAKEOVER=false`
  - **ON (teste controlado)**: `--dart-define=INCOMING_OFFER_AGGRESSIVE_TAKEOVER=true`
- Logcat ativo (ver `docs/incoming_offer/log_collection_android.md`).

## Template de execução por cenário

Copiar e preencher este bloco para cada execução.

```markdown
### Cenário: <nome>
- Build/branch:
- Device / Android:
- Data/hora:
- Pré-condição específica:
- Passos executados:
  1.
  2.
  3.
- Resultado esperado:
- Resultado observado:
- Evidência (print/vídeo/link):
- Log observado (trecho + timestamp):
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:
```

## Checklist mínimo (obrigatório)

### 1) App aberto + nova oferta
- Passos: app foreground, disparar `new_order` ou `order_request` elegível.
- Esperado: takeover abre (se flag ON), evento `offer_opened`, sem dupla UI.
- Evidência:
- Log observado:
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:

### 2) App em background + nova oferta
- Esperado: heads-up/full-screen conforme device; ação abre fluxo corretamente.
- Evidência:
- Log observado:
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:

### 3) App morto + nova oferta
- Esperado: abertura consistente via notificação/action; sem crash.
- Evidência:
- Log observado:
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:

### 4) Lockscreen + nova oferta
- Esperado: comportamento de lockscreen compatível; abrir/agir sem travar.
- Evidência:
- Log observado:
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:

### 5) OPEN -> ACCEPT
- Esperado: `offer_opened` seguido de `offer_accept_tapped`; activity fecha; reconciliação Flutter.
- Evidência:
- Log observado:
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:

### 6) OPEN -> DECLINE
- Esperado: `offer_opened` seguido de `offer_decline_tapped`; activity fecha.
- Evidência:
- Log observado:
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:

### 7) EXPIRE sem ação
- Esperado: `offer_expired`; cleanup de notificação/activity.
- Evidência:
- Log observado:
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:

### 8) Toque duplo aceitar
- Esperado: 1 ação efetiva; duplicata descartada (`dedupe_discarded` quando aplicável).
- Evidência:
- Log observado:
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:

### 9) Toque duplo recusar
- Esperado: 1 ação efetiva; sem duplo processamento.
- Evidência:
- Log observado:
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:

### 10) FCM duplicado
- Esperado: sem takeover duplicado para mesma oferta ativa; sem ação duplicada.
- Evidência:
- Log observado:
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:

### 11) Duas ofertas em sequência
- Esperado: troca/refresh coerente, sem estado preso e sem perder ação.
- Evidência:
- Log observado:
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:

### 12) Payload incompleto
- Esperado: `fallback_triggered`/`takeover_not_eligible`; app segue estável.
- Evidência:
- Log observado:
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:

### 13) Módulo elegível
- Esperado: `takeover_eligible` quando `module_type` ∈ {food, grocery, parcel, pharmacy} e tipo suportado.
- Evidência:
- Log observado:
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:

### 14) Módulo não elegível
- Esperado: `takeover_not_eligible` (module not eligible) e fallback Flutter.
- Evidência:
- Log observado:
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:

### 15) Takeover desligado pela flag
- Esperado: takeover nativo não dispara; log indica `feature flag disabled`.
- Evidência:
- Log observado:
- Status: [ ] Aprovado  [ ] Reprovado
- Observações:

## Critério de saída do ciclo QA

- 100% dos 15 cenários executados com evidência e log anexados.
- 0 crash/blocker.
- Reprovação só permitida com bug aberto + plano de correção.
