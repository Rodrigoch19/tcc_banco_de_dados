const fs = require('fs');

const firebaseTools =
  'C:/Users/Ideia/AppData/Roaming/npm/node_modules/firebase-tools/lib';
const auth = require(`${firebaseTools}/auth`);
const apiv2 = require(`${firebaseTools}/apiv2`);

async function main() {
  const projectId = 'teste-tcc-446d5';
  const account =
    auth.getProjectDefaultAccount(process.cwd()) ||
    auth.getGlobalDefaultAccount();
  if (!account) throw new Error('Execute firebase login antes de continuar.');

  auth.setActiveAccount({}, account);
  const accessToken = await apiv2.getAccessToken();
  const configUrl =
    `https://identitytoolkit.googleapis.com/admin/v2/projects/${projectId}/config` +
    '?updateMask=signIn.anonymous.enabled';
  const configResponse = await fetch(configUrl, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ signIn: { anonymous: { enabled: true } } }),
  });
  if (!configResponse.ok) {
    throw new Error(`Falha ao habilitar: ${await configResponse.text()}`);
  }

  const options = fs.readFileSync('lib/firebase_options.dart', 'utf8');
  const apiKey = options.match(/apiKey: '([^']+)'/)?.[1];
  if (!apiKey) throw new Error('API key do Firebase não encontrada.');

  const createResponse = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${apiKey}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ returnSecureToken: true }),
    },
  );
  const created = await createResponse.json();
  if (!createResponse.ok || !created.idToken) {
    throw new Error(`Teste anônimo falhou: ${JSON.stringify(created)}`);
  }

  const deleteResponse = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:delete?key=${apiKey}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ idToken: created.idToken }),
    },
  );
  if (!deleteResponse.ok) {
    throw new Error(`Falha ao remover usuário temporário: ${deleteResponse.status}`);
  }

  console.log(
    'Provedor anônimo habilitado e testado; usuário temporário removido.',
  );
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
