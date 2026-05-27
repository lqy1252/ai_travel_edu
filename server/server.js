const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth');
const locationRoutes = require('./routes/locations');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/locations', locationRoutes);

app.get('/', (req, res) => {
  res.json({ message: '西南大学校园游览智能讲解APP API', version: '1.0.0' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`服务器运行在 http://localhost:${PORT}`);
});
