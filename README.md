# Ritual — publicação no GitHub Pages e Supabase

## 1. Publicar no GitHub Pages

1. Entre no GitHub e crie um repositório chamado `ritual`.
2. Deixe o repositório público se estiver usando o plano GitHub Free.
3. Na raiz do repositório, envie todos os arquivos desta pasta, preservando a pasta `icons`.
4. Confirme que o arquivo principal se chama exatamente `index.html`.
5. Abra **Settings > Pages**.
6. Em **Build and deployment**, selecione **Deploy from a branch**.
7. Em **Branch**, selecione `main`, pasta `/(root)` e clique em **Save**.
8. Aguarde a publicação. O endereço normalmente será:
   `https://SEU-USUARIO.github.io/ritual/`

Para atualizar futuramente, substitua o `index.html` no repositório e faça um novo commit.

## 2. Criar o projeto no Supabase

1. Crie um projeto no Supabase.
2. Abra **SQL Editor > New query**.
3. Cole todo o conteúdo de `supabase-setup.sql` e execute.
4. O script cria:
   - tabela `public.skin_days`;
   - políticas RLS para cada usuário acessar apenas os próprios registros;
   - bucket privado `skin-photos`;
   - políticas para fotos dentro da pasta do próprio usuário.

## 3. Configurar autenticação

1. Abra **Authentication > Providers > Email** e mantenha o login por e-mail habilitado.
2. Em **Authentication > URL Configuration**:
   - **Site URL:** `https://SEU-USUARIO.github.io/ritual/`
   - **Redirect URLs:** adicione exatamente o mesmo endereço.
3. Para um aplicativo pessoal, crie sua conta e depois desative novos cadastros públicos.

## 4. Obter as chaves corretas

No Supabase, copie:

- **Project URL**
- **Publishable key** ou **anon key**

Nunca coloque a `service_role` no HTML ou no GitHub.

## 5. O que ainda precisa ser integrado no HTML

O HTML atual continua funcionando offline com IndexedDB. Para sincronizar com Supabase, o código deverá:

1. carregar `@supabase/supabase-js`;
2. criar o cliente com Project URL + Publishable key;
3. mostrar login/cadastro;
4. salvar cada dia com `upsert` em `skin_days`;
5. carregar o registro pela combinação `user_id + log_date`;
6. enviar fotos para `skin-photos/USER_ID/AAAA-MM-DD/`;
7. usar URLs assinadas ou `download()` para exibir fotos privadas;
8. manter o IndexedDB como fallback offline.

## 6. Estrutura do registro

A tabela usa uma coluna `payload jsonb`, portanto o aplicativo pode salvar o objeto diário completo sem criar dezenas de colunas. Exemplo:

```json
{
  "checkin": {},
  "stepStates": {},
  "photos": {},
  "notes": "",
  "after": {},
  "sensitive": false
}
```

## 7. Segurança

- O site do GitHub Pages pode ser público, mas os dados não devem ser públicos.
- A Publishable key pode ficar no navegador somente porque o acesso é limitado por RLS.
- O bucket de fotos deve permanecer privado.
- Nunca envie backups JSON, fotos ou a chave `service_role` para o repositório.
