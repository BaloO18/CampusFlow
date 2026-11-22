const crypto = require('crypto');
const path = require('path');
const jsonServer = require('json-server');

const port = Number(process.env.PORT) || 3000;
const server = jsonServer.create();
const router = jsonServer.router(path.join(__dirname, 'db.json'));
const jetons = new Map();

const sansMotDePasse = ({ motDePasse, ...utilisateur }) => utilisateur;

server.use(jsonServer.defaults());
server.use(jsonServer.bodyParser);

server.post('/login', (req, res) => {
  const { email = '', motDePasse = '' } = req.body ?? {};
  const utilisateur = router.db
    .get('utilisateurs')
    .find((u) => u.email === String(email).trim().toLowerCase())
    .value();
  if (!utilisateur || utilisateur.motDePasse !== motDePasse) {
    return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
  }
  const jeton = crypto.randomBytes(24).toString('hex');
  jetons.set(jeton, utilisateur.id);
  res.json({ jeton, utilisateur: sansMotDePasse(utilisateur) });
});

server.use((req, res, next) => {
  const [type, jeton] = (req.headers.authorization ?? '').split(' ');
  const id = type === 'Bearer' ? jetons.get(jeton) : undefined;
  if (!id) return res.status(401).json({ message: 'Jeton absent ou expiré' });
  req.utilisateurId = id;
  next();
});

server.get('/moi', (req, res) => {
  const utilisateur = router.db
    .get('utilisateurs')
    .find({ id: req.utilisateurId })
    .value();
  res.json(sansMotDePasse(utilisateur));
});

server.post('/logout', (req, res) => {
  const [, jeton] = req.headers.authorization.split(' ');
  jetons.delete(jeton);
  res.status(204).end();
});

router.render = (req, res) => {
  const donnees = res.locals.data;
  if (req.path.startsWith('/utilisateurs')) {
    return res.jsonp(
      Array.isArray(donnees)
        ? donnees.map(sansMotDePasse)
        : sansMotDePasse(donnees),
    );
  }
  res.jsonp(donnees);
};

server.use(router);

server.listen(port, '0.0.0.0', () => {
  console.log(`API CampusFlow sur http://localhost:${port}`);
});
