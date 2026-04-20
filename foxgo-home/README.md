# Fox GO Home Independente

Esta versão é uma home totalmente independente com telas novas (menu, submenu, cards e fluxos próprios).

## O que tem

- Navegação por telas (`#home`, `#categorias`, `#lojas`, `#clientes`, `#parceiros`, `#config`).
- Cadastro de cliente e cadastro de loja em etapas com payload próprio do front.
- Tela de integração para configurar os endpoints do painel (entrada e saída de dados).
- Consumo de dados do painel para preencher cards de categorias e lojas.

## Configuração

Tudo é configurado pela tela **Integração** e salvo em `localStorage` (`foxgo_integration_v2`).

## Rodar local

```bash
python3 -m http.server 8080
```

Abrir: `http://localhost:8080/foxgo-home/`.
