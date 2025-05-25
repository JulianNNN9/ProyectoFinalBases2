const oracledb = require('oracledb');
require('dotenv').config();

module.exports = {
  user: process.env.DB_USER || "EDUNOVA",
  password: process.env.DB_PASSWORD || "edunova",
  connectString: process.env.DB_CONNECT_STRING || "localhost:1521/xe",
  // También puedes usar este formato alternativo
  // connectString: "localhost:1521/XE",
  autoCommit: true
};
