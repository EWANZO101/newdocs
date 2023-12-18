const express = require('express');
const bodyParser = require('body-parser');
const app = express();

// Example user credentials (replace this with a database)
const users = [
  { username: 'user', password: 'password' }
];

app.use(bodyParser.json());

app.post('/login', (req, res) => {
  const { username, password } = req.body;
  
  // Check credentials (replace this with database queries)
  const user = users.find(u => u.username === username && u.password === password);

  if (user) {
    // Successful login
    res.status(200).send('Login successful');
  } else {
    // Login failed
    res.status(401).send('Login failed');
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
