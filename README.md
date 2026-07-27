# Ritual

Aplicativo pessoal de rotina K-Beauty, diário visual da pele, histórico e acompanhamento de tendências.

## Publicação

O projeto está configurado para:

- GitHub Pages: `https://naththth.github.io/Ritual/`
- Supabase: projeto `emmhitkswghthzvevtio`
- Banco local offline: IndexedDB
- Sincronização: tabela `skin_days`
- Fotos privadas: bucket `skin-photos`

## Arquivos

- `index.html`: aplicativo completo e integração Supabase.
- `manifest.webmanifest`: instalação como PWA.
- `sw.js`: cache offline somente dos arquivos do próprio site.
- `supabase-setup.sql`: tabela, bucket privado e políticas RLS.
- `icons/`: ícones do aplicativo.

## Antes de publicar

1. No Supabase, execute `supabase-setup.sql` no SQL Editor.
2. Em Authentication > URL Configuration, use como Site URL e Redirect URL:
   `https://naththth.github.io/Ritual/`
3. Em Authentication > Providers > Email, mantenha o login por e-mail habilitado.
4. Envie todos os arquivos deste pacote para a raiz do repositório `Ritual`.
5. Em GitHub > Settings > Pages, publique a branch `main` pela pasta `/ (root)`.

## Primeiro acesso

1. Abra o endereço do GitHub Pages.
2. Clique em **Criar conta**.
3. Confirme o e-mail, caso a confirmação esteja ativa no Supabase.
4. Volte ao app e entre com e-mail e senha.
5. O histórico local será enviado para a nuvem automaticamente.

## Segurança

A chave incluída no HTML é a chave pública/publishable do Supabase. A proteção dos dados depende das políticas RLS do arquivo SQL. Nunca inclua a senha do banco, secret key ou service_role no repositório.
