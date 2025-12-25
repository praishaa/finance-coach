const express = require("express");
const router = express.Router();
const { getAdvice } = require("../controllers/adviceController");

router.post("/", getAdvice);

module.exports = router;
