# Checklist para publicar o **User app and web (Web App)** no host

Fonte de referência: documentação oficial 6amMart (seção **User Application & Web Configuration → Web App**).

## 1) Pré-requisito obrigatório
Antes do Web App, a documentação exige concluir o setup do **User App** (mesmo codebase).

## 2) Customização de identidade (branding)
No diretório `User app and web/web/`:

- Substituir `logo.png` pelo logo da marca.
- Substituir `favicon.png` pelo ícone da marca.
- Ajustar o `<title>` em `web/index.html`.
- Ajustar `name` e `short_name` em `web/manifest.json`.

## 3) Build para produção
Dentro de `User app and web/`, gerar build web:

```bash
flutter build web
```

Saída esperada: `User app and web/build/web/`.

## 4) Publicação no host
Fazer upload de **todos** os arquivos de `build/web/` para o domínio/subdomínio final,
incluindo arquivos ocultos (ex.: `.htaccess`).

## 5) Regra de domínio (importante)
A doc do 6amMart orienta **não** usar o mesmo domínio para Admin e Web simultaneamente.
Exemplo recomendado:

- Admin: `https://admin.seudominio.com`
- Web: `https://seudominio.com`

E no app, usar como Base URL o domínio do Admin.

---

## Auditoria rápida do estado atual deste repositório

### O que já está presente
- Arquivos de web branding existem em `User app and web/web/`: `logo.png` e `favicon.png`.
- Existe `User app and web/web/.htaccess` com regra de rewrite para SPA.

### Pontos para ajustar antes de subir para produção
- `User app and web/web/index.html` já está com `<title>Fox GO</title>`.
- `User app and web/web/manifest.json` já está com `name` e `short_name` como `Fox GO`.
- `User app and web/web/index.html` já usa `canonical` para `https://www.foxgodelivery.com.br/`.
- `User app and web/web/index.html` contém chave pública do Google Maps; confirmar se a key está restrita por domínio correto no Google Cloud.

## Comando sugerido de deploy (resumo)
```bash
cd "User app and web"
flutter pub get
flutter build web
# subir conteúdo de build/web/ para o host (incluindo arquivos ocultos)
```
