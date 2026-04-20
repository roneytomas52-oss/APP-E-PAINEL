# Fox GO Home (deploy independente)

Homepage estática da Fox GO com experiência completa inspirada na estrutura de marketplace moderna e cadastro de loja em etapas.

## O que foi implementado

- Estrutura completa de homepage com menu, hero, categorias, destaques, como funciona, FAQ e rodapé.
- Cadastro de cliente integrado à rota original: `POST /api/v1/auth/sign-up`.
- Cadastro de loja em **wizard de 4 etapas**, com envio final para rota original: `POST /api/v1/auth/vendor/register`.
- Configuração de base da API pelo navegador (salva em `localStorage`, chave `foxgo_api_base`).

## Rotas originais consumidas

### API
- `GET /api/v1/module`
- `GET /api/v1/categories`
- `GET /api/v1/banners`
- `GET /api/v1/stores/recommended`
- `GET /api/v1/stores/latest`
- `POST /api/v1/auth/sign-up`
- `POST /api/v1/auth/vendor/register`

### Web
- `POST /vendor/apply`
- `GET /customer/auth/login`

## Rodar localmente

```bash
python3 -m http.server 8080
```

Acesse: `http://localhost:8080/foxgo-home/`.

## Integração de cadastro de loja

- O wizard coleta dados por etapa e envia tudo no final em `multipart/form-data`.
- O campo `translations` é gerado automaticamente com `name` e `address`.
- `logo` é obrigatório, pois a rota original exige imagem.
- Dependendo da configuração do backend, pode ser necessário enviar headers extras exigidos por middleware.
