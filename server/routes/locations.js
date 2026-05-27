const express = require('express');
const db = require('../db');

const router = express.Router();

// 获取所有讲解点
router.get('/', (req, res) => {
  const locations = db.prepare('SELECT * FROM locations ORDER BY id').all();
  res.json(locations);
});

// 获取单个讲解点
router.get('/:id', (req, res) => {
  const location = db.prepare('SELECT * FROM locations WHERE id = ?').get(req.params.id);
  if (!location) {
    return res.status(404).json({ error: '讲解点不存在' });
  }
  res.json(location);
});

module.exports = router;
