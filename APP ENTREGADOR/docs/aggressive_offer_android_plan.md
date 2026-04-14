# Plano técnico executável — Modo Agressivo de Nova Oferta (Android)

> Escopo: **somente planejamento técnico** baseado no código atual, sem implementação final.

## 1) Resumo executivo

- O estado oficial de pedido já está concentrado no `OrderController` (`latestOrderList`, `currentOrderList`, `acceptOrder`, `ignoreOrder`, `getLatestOrders`, `getRunningOrders`) e deve permanecer como fonte de verdade no Flutter.
- Hoje a entrada de eventos de oferta está duplicada entre `DashboardScreen` (listener `FirebaseMessaging.onMessage`) e `NotificationHelper` (outro listener `FirebaseMessaging.onMessage` + background handler), com risco de popup/áudio/refresh duplicados.
- A estratégia proposta é criar um **dispatcher único de nova oferta** no Flutter e usar Android nativo apenas para experiência agressiva (full-screen + ações rápidas), sem mover a regra de negócio para nativo.
- Para Android, introduzir `IncomingOfferService`, `IncomingOfferActivity`, canal urgente e ações nativas `Aceitar`/`Recusar`, conectadas por bridge de canal Flutter ↔ Android.
- A confirmação de estado continua exclusivamente por API existente via `OrderController`.

## 2) Arquitetura final proposta

### 2.1 Componentes e responsabilidade

1. `IncomingOfferService` (Android)
   - Recebe intent de oferta nova (gerada pelo bridge quando app está background/morto ou quando desejar UX agressiva).
   - Cria/usa canal urgente (`IMPORTANCE_HIGH` + categoria call/alarm).
   - Publica notificação heads-up/full-screen com `PendingIntent` para `IncomingOfferActivity` e ações nativas.
   - Não confirma aceite/recusa em API; apenas dispara evento para Flutter e mantém timeout local.

2. `IncomingOfferActivity` (Android)
   - Tela agressiva estilo “chamada”: timer, CTA de `Aceitar`/`Recusar`.
   - Exibição apenas; sem regra de negócio.
   - Ao tocar ação: envia evento para Flutter bridge (`accept_tapped`/`decline_tapped`) com `offer_id` e finaliza.

3. Canal urgente de notificação (Android)
   - Novo channel específico (ex.: `incoming_offer_urgent`).
   - Isola som/comportamento do canal geral já usado em `NotificationHelper` (`6ammart`).

4. Actions nativas (`Aceitar`, `Recusar`)
   - `BroadcastReceiver` dedicado para cada ação ou receiver único com action string.
   - Apenas serializa evento para bridge (não chama API direta).

5. Bridge Flutter ↔ Android
   - `MethodChannel` para comandos Flutter→Android (exibir/cancelar oferta agressiva).
   - `EventChannel` para Android→Flutter (eventos de ações e lifecycle da oferta).

6. Dispatcher único de nova oferta (Flutter)
   - Novo componente central (ex.: `IncomingOfferDispatcher`) registra um único listener FCM para tipos `new_order`/`order_request`/`assign`.
   - Decide rota por estado de app (foreground/background/morto) e por tipo de payload.
   - Encaminha atualização de estado para `OrderController`.

7. Sincronização com Home card, popup e listas oficiais
   - Sempre após evento de oferta: `OrderController.getLatestOrders()`, `getRunningOrders()`, `getOrderCount()`.
   - UI (`HomeScreen`, `OrderRequestScreen`, badge do dashboard) continua lendo apenas listas oficiais.
   - Popup atual (`NewRequestDialogWidget`) só aparece no caminho foreground + sem Activity agressiva aberta.

### 2.2 Fluxo de disparo (alto nível)

- FCM chega → Dispatcher único classifica evento.
- Se foreground: opcional popup Flutter ou abrir Activity agressiva por bridge (feature-flag).
- Se background/morto: Android exibe experiência agressiva via service/notification/activity.
- Usuário aceita/recusa na UI nativa → evento volta ao Flutter via EventChannel.
- Flutter chama `OrderController.acceptOrder(...)` ou `ignoreOrder(...)` (com busca segura de índice por `orderId`).
- Após retorno API, Flutter sincroniza listas e navegação.

### 2.3 Estado: origem, confirmação e exibição

- **Origem de estado:** backend + payload FCM.
- **Confirmação de estado:** APIs já usadas em `OrderController` (`acceptOrder`, `updateOrderStatus`, `getLatestOrders`, `getRunningOrders`).
- **Exibição de estado:** `HomeScreen`, `OrderRequestScreen`, `OrderScreen`, dialogs e Activity nativa.
- **Regra anti-duplicidade:** nenhuma lógica de transição de pedido no Android nativo; nativo apenas emite intenção de ação.

## 3) Fases de implementação

### Fase 1 — Preparação de infraestrutura de eventos (sem UI agressiva)
- Arquivos alvo: `lib/helper/notification_helper.dart`, novo `lib/features/delivery_module/order/services/incoming_offer_dispatcher.dart`, `lib/main.dart`, `lib/features/dashboard/screens/dashboard_screen.dart`.
- Objetivo: remover duplicidade de listener para nova oferta e criar dispatcher único.
- Risco: quebrar rotas de notificação não relacionadas.
- Critério de pronto: apenas um ponto processa `new_order/order_request/assign`; sem popup duplicado.

### Fase 2 — Bridge Flutter ↔ Android (sem Activity final)
- Arquivos alvo: `android/app/src/main/kotlin/.../MainActivity.kt`, novo arquivo Kotlin `IncomingOfferBridge.kt`, novo wrapper Dart `incoming_offer_platform_channel.dart`.
- Objetivo: estabelecer `MethodChannel` + `EventChannel` com contrato versionado (`schema_version`).
- Risco: perda de eventos no app cold-start.
- Critério de pronto: teste manual confirma envio e recebimento de eventos mockados nos 3 estados (foreground/background/morto).

### Fase 3 — Canal urgente + Service + actions nativas
- Arquivos alvo: novos `IncomingOfferService.kt`, `IncomingOfferActionReceiver.kt`, manifest.
- Objetivo: notificação agressiva com ações `Aceitar`/`Recusar` e timeout local.
- Risco: comportamento diferente por OEM/Android 13+ (permissão POST_NOTIFICATIONS).
- Critério de pronto: notificação aparece com prioridade alta e ações funcionam sem abrir app completo.

### Fase 4 — IncomingOfferActivity full-screen
- Arquivos alvo: novo `IncomingOfferActivity.kt`, layout XML(s), styles/themes, manifest.
- Objetivo: UX estilo Uber em lockscreen/background.
- Risco: compatibilidade com lockscreen e políticas de background launch.
- Critério de pronto: activity abre por fullScreenIntent quando permitido e fecha em expiração/ação.

### Fase 5 — Integração com `OrderController` e limpeza de duplicidade
- Arquivos alvo: `OrderController`, `DashboardScreen`, `NotificationHelper`, `NewRequestDialogWidget`, possivelmente `order_request_screen.dart`.
- Objetivo: ações nativas passarem pelo mesmo fluxo de aceite/recusa do app.
- Risco: race de índice (`latestOrderList` mudou entre chegada e ação).
- Critério de pronto: aceite/recusa por UI nativa e Flutter convergem no mesmo estado final.

### Fase 6 — Compatibilidade por módulos + fallback robusto + feature flag
- Arquivos alvo: dispatcher, parser de payload, `SplashController/config` (feature flag).
- Objetivo: habilitar agressivo só para tipos suportados.
- Risco: atingir ride flow legado sem querer.
- Critério de pronto: matriz de tipos validada; ride não regressivo.

### Fase 7 — Endurecimento e observabilidade
- Arquivos alvo: logs estruturados Dart/Kotlin, métricas de eventos.
- Objetivo: rastrear deduplicação, latência e falhas.
- Risco: ruído de log e custo de manutenção.
- Critério de pronto: trilha completa `offer_received -> shown -> action -> api_result -> sync_done`.

## 4) Arquivos Android a criar/alterar

### 4.1 Novos (propostos)
- `android/app/src/main/kotlin/com/sixamtech/sixam_mart_delivery_app/incoming_offer/IncomingOfferService.kt`
- `android/app/src/main/kotlin/com/sixamtech/sixam_mart_delivery_app/incoming_offer/IncomingOfferActivity.kt`
- `android/app/src/main/kotlin/com/sixamtech/sixam_mart_delivery_app/incoming_offer/IncomingOfferActionReceiver.kt`
- `android/app/src/main/kotlin/com/sixamtech/sixam_mart_delivery_app/incoming_offer/IncomingOfferBridge.kt`
- `android/app/src/main/res/layout/activity_incoming_offer.xml`
- `android/app/src/main/res/values/incoming_offer_strings.xml`

### 4.2 Alterados
- `android/app/src/main/AndroidManifest.xml`
  - declarar `service`, `receiver`, `activity` agressiva e permissões de notificação/lockscreen quando aplicável.
- `android/app/src/main/kotlin/.../MainActivity.kt`
  - registrar bridge e encaminhar intent de abertura/ação.
- `android/app/src/main/res/values/styles.xml`
  - tema full-screen/turn-screen-on para `IncomingOfferActivity`.

### 4.3 Entradas de Manifest
- `<service android:name=".incoming_offer.IncomingOfferService" .../>`
- `<receiver android:name=".incoming_offer.IncomingOfferActionReceiver" .../>`
- `<activity android:name=".incoming_offer.IncomingOfferActivity" .../>`
- `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` (Android 13+)
- manter `MainActivity` como launcher e rota de fallback.

### 4.4 Observações de incerteza real
- `AndroidManifest.xml` referencia `com.sixamtech.sixam_mart_delivery_app.BackgroundService`, mas classe não foi encontrada no source atual de `android/app/src/main`.
- `DashboardScreen` invoca `MethodChannel('com.sixamtech/app_retain')`, porém `MainActivity.kt` atual está vazio (sem handler), indicando débito técnico prévio.

## 5) Arquivos Flutter a alterar

### 5.1 Core de notificação e entrada
- `lib/helper/notification_helper.dart`
  - retirar responsabilidade de processar `new_order/order_request/assign` fora do dispatcher.
  - manter processamento de mensagens gerais/chat/ride que não pertencem à nova oferta delivery.
- `lib/features/dashboard/screens/dashboard_screen.dart`
  - remover listener de `FirebaseMessaging.onMessage` para novas ofertas.
  - manter apenas responsabilidades de navegação/tabs/exit.
- `lib/main.dart`
  - inicialização do dispatcher único e bridge.

### 5.2 Novo dispatcher e bridge
- Novo: `lib/features/delivery_module/order/services/incoming_offer_dispatcher.dart`
- Novo: `lib/features/delivery_module/order/services/incoming_offer_event_bus.dart`
- Novo: `lib/features/delivery_module/order/services/incoming_offer_platform_channel.dart`

### 5.3 Controller(s) e UI afetada
- `lib/features/delivery_module/order/controllers/order_controller.dart`
  - incluir método auxiliar seguro para resolver índice por `orderId` antes de `acceptOrder`/`ignoreOrder`.
  - manter APIs e listas oficiais como fonte única.
- `lib/features/dashboard/widgets/new_request_dialog_widget.dart`
  - condicionar exibição para não competir com activity agressiva.
- `lib/features/delivery_module/order/screens/order_request_screen.dart`
- `lib/features/home/widgets/active_order_widget.dart`
  - sem regra nova; apenas validar atualização após sync.

### 5.4 Pontos explícitos para remover duplicidade
- Listener de novas ofertas em `DashboardScreen`.
- Blocos de `NotificationHelper` que hoje também fazem refresh e notificação para os mesmos tipos.
- Repetição de áudio entre `NewRequestDialogWidget` e background service atual.

## 6) Contrato Android ↔ Flutter

### 6.1 Channels
- Method channel: `com.sixamtech.delivery/incoming_offer/method`
- Event channel: `com.sixamtech.delivery/incoming_offer/events`
- Payload sempre JSON map com `schema_version: 1`.

### 6.2 Eventos Android → Flutter

1. `offer_opened`
```json
{
  "schema_version": 1,
  "event": "offer_opened",
  "offer_id": "12345",
  "order_id": 12345,
  "source": "notification|activity|app_reopen",
  "received_at_ms": 1710000000000,
  "expires_at_ms": 1710000030000,
  "module_type": "food",
  "order_type": "delivery"
}
```

2. `offer_accept_tapped`
- inclui `action_origin` (`notification_action`|`activity_button`) e `event_seq` monotônico.

3. `offer_decline_tapped`
- mesmo formato, com `decline_reason` opcional (`quick_decline`, `timeout_auto`, etc.).

4. `offer_expired`
- emitido por timer nativo quando estoura `expires_at_ms`.

5. `app_reopened_with_offer`
- emitido quando app abre por intent pendente da oferta.

### 6.3 Comandos Flutter → Android (MethodChannel)
- `showIncomingOffer(Map payload)`
- `cancelIncomingOffer(Map {offer_id})`
- `syncOfferState(Map {offer_id, state})`

### 6.4 Regras por estado do app
- Foreground: Flutter decide entre popup atual e activity agressiva (feature flag).
- Background: Android exibe notificação/Activity e notifica Flutter por EventChannel ao interagir.
- Morto: intent persistida; ao abrir app emitir `app_reopened_with_offer` e Flutter reconcilia via API.

## 7) Unificação da entrada de nova oferta

### 7.1 Novo ponto único
- `IncomingOfferDispatcher.handleRemoteMessage(RemoteMessage)` como **única** porta para `new_order`, `order_request`, `assign` (delivery).

### 7.2 O que sai de `DashboardScreen`
- Todo bloco `FirebaseMessaging.onMessage.listen` dedicado a tipos de oferta.
- `Get.dialog(NewRequestDialogWidget...)` disparado diretamente do listener.

### 7.3 O que sai de `NotificationHelper`
- Refresh de `OrderController` para tipos de oferta quando esses tipos já forem tratados pelo dispatcher.
- Tocar som/notificação duplicada para os mesmos eventos.

### 7.4 O que continua
- Conversa/chat, block/unblock, rotas gerais, ride actions que não pertencem ao delivery offer agressivo.

### 7.5 Mecanismos anti-duplicidade
- `offerId + eventSeq` com cache TTL (ex.: 60s) no dispatcher.
- `dialog_guard`: não abrir `NewRequestDialogWidget` se `IncomingOfferActivity` ativa.
- `audio_guard`: singleton de áudio por `offer_id`.
- `refresh_guard`: debounce de `getLatestOrders/getRunningOrders/getOrderCount` por janela curta (ex.: 300–700 ms).

## 8) Compatibilidade com módulos

### 8.1 Entram no modo agressivo (fase inicial)
- `type in {new_order, order_request, assign}` do fluxo **delivery**.
- `order_type` padrão e `parcel_order` (com layout adaptado).

### 8.2 Não entram inicialmente
- Ride (`action` como `driver_new_ride_request`, etc.).
- Mensagens gerais/chat/financeiro.
- Tipos sem `order_id` válido.

### 8.3 Variação de layout por `module_type` / `order_type`
- `parcel_order`: destacar coleta/entrega e ocultar contagem detalhada de itens.
- `prescription`: badge específica e prioridade visual para instruções.
- `food/grocery/ecommerce`: bloco resumido de loja, distância e valor.

### 8.4 Campos mínimos para Android abrir agressivo
- `offer_id` (ou derivado de `order_id + timestamp`)
- `order_id`
- `type`
- `expires_at_ms`
- `module_type` (fallback `unknown`)
- `order_type`
- `title`/`body` curto

### 8.5 Campos complementares carregados depois no Flutter
- detalhes completos de itens via `getOrderDetails(orderId, ...)`
- estados atualizados via `getLatestOrders()` e `getRunningOrders()`
- dados de perfil/contagem via `getOrderCount()`

## 9) Fallbacks

- App aberto: dispatcher processa, sincroniza listas e mostra UI única (popup **ou** activity agressiva).
- App background: service/notificação agressiva; ação volta por EventChannel.
- App morto: notificação abre app/Activity; reconciliação por API ao iniciar.
- Tela bloqueada: fullScreenIntent quando permitido; senão heads-up persistente.
- Sem permissão de notificação: fallback para abrir app em foreground no próximo unlock + banner interno.
- Serviço interrompido: receiver relança notificação de fallback sem áudio contínuo.
- Payload incompleto: não abre agressivo; registra erro e faz refresh silencioso de listas.
- Usuário offline: mostrar ação indisponível e enfileirar tentativa curta; reconciliar ao reconectar.
- Oferta já aceita por outro: API de `acceptOrder` falha -> remover card local + snackbar + refresh.
- Oferta expirada: evento `offer_expired`, encerrar áudio/UI e refresh de `latestOrderList`.

## 10) Plano de testes

### 10.1 Manuais (por estado do app)
1. Foreground: nova oferta abre uma única UI, um único áudio, uma atualização de lista.
2. Background: notificação agressiva com botões responde corretamente.
3. Morto: tocar ação abre app e reconcilia estado.
4. Lock screen: validar comportamento em Android 12/13/14.

### 10.2 Funcionais por fluxo
- Aceitar pela Activity.
- Recusar por ação de notificação.
- Expirar sem ação.
- Abrir pelo tap da notificação e navegar para pedido correto.

### 10.3 Regressão
- Fluxos existentes de chat/message/block/unblock.
- Ride module: sem alteração de comportamento.
- Atualização de Home card (`currentOrderList`) e aba de requests (`latestOrderList`).

### 10.4 Por tipo de pedido
- `order_request`, `assign`, `new_order`.
- `parcel_order`, `prescription`, pedido padrão.

### 10.5 Sincronização Android ↔ Flutter
- Verificar sequência de eventos e idempotência (`event_seq`).
- Validar reconciliação após kill process.

### 10.6 Anti-duplicidade
- Confirmar ausência de duas dialogs, dois áudios e dois refreshs para o mesmo `offer_id`.

## 11) Riscos e mitigação

1. Duplicidade de listeners
   - Mitigação: centralizar listeners no dispatcher e remover branches concorrentes.
2. Race conditions de lista/índice
   - Mitigação: resolver por `orderId`; não confiar em índice antigo.
3. Ações nativas fora de ordem
   - Mitigação: `event_seq` + descarte de eventos antigos.
4. App morto sem engine pronta
   - Mitigação: persistir evento pendente no Android (SharedPreferences) e drenar no boot Flutter.
5. Estado divergente Android/Flutter
   - Mitigação: Android não confirma negócio; Flutter sempre reconcilia via API oficial.
6. Conflito com código ride legado
   - Mitigação: gate explícito por `type/action` + feature flag delivery-only.
7. Referências Android incompletas no projeto atual
   - Mitigação: corrigir dívidas (classe `BackgroundService` ausente, `MethodChannel app_retain` sem handler) antes de ampliar escopo.

## 12) Recomendação final

- Executar primeiro a Fase 1 (dispatcher único + deduplicação), porque reduz risco sistêmico antes de mexer em Android nativo.
- Em seguida Fase 2 (bridge), com contrato estável e telemetria mínima.
- Só depois ativar UI agressiva nativa (Fases 3 e 4), protegida por feature flag por módulo/tipo.
- Critério de sucesso: sem regressão de ride/chat e sem duplicidade de popup/áudio/refresh para o mesmo pedido.
