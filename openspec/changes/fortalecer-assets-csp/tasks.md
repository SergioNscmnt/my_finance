## 1. Decisão

- [ ] 1.1 Inventariar assets carregados por CDN no layout.
- [ ] 1.2 Decidir entre vendorização/pinning local ou CDN com CSP explícita.

## 2. Implementação

- [ ] 2.1 Ajustar layout, importmap ou pipeline de assets conforme a decisão.
- [ ] 2.2 Configurar `content_security_policy.rb` com diretivas necessárias.
- [ ] 2.3 Documentar versões/origens dos assets.

## 3. Verificação

- [ ] 3.1 Validar charts, Tom Select, Flatpickr, tema e modais.
- [ ] 3.2 Verificar que a CSP não gera violações para a UI principal.
