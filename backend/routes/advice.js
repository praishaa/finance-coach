const express = require("express");
const router = express.Router();
const Expense = require("../models/expense");

// POST: Add expense
router.post("/", async (req, res) => {
  try {
    const { amount, category } = req.body;

    if (!amount || !category) {
      return res.status(400).json({ message: "Missing fields" });
    }

    const expense = new Expense({ amount, category });
    await expense.save();

    res.status(201).json(expense);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET: Fetch all expenses
router.get("/", async (req, res) => {
  try {
    const expenses = await Expense.find();
    res.json(expenses);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
