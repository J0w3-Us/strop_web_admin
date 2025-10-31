const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// In-memory store
let users = [{ id: '1', email: 'test@local', password: '1234', name: 'Demo User' }];
let projects = [{ id: '1', code: 'PRJ1', name: 'Demo Project' }];

app.post('/auth/login', (req, res) => {
    const { email, password } = req.body;
    const u = users.find(x => x.email === email && x.password === password);
    if (u) return res.json({ ok: true, user: { id: u.id, email: u.email, name: u.name } });
    return res.status(401).json({ ok: false, error: 'Invalid credentials' });
});

app.get('/projects', (req, res) => {
    res.json(projects);
});

app.post('/projects', (req, res) => {
    const p = req.body;
    p.id = (projects.length + 1).toString();
    projects.push(p);
    res.json(p);
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log('Backend listening on', port));
