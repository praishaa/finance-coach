const express = require("express");
const router = express.Router();
const Expense = require("../models/expense");
const mongoose = require("mongoose");
const auth = require("../middleware/auth");

/* ---------------- ADD EXPENSE ---------------- */
// POST /expenses
router.post("/", auth, async (req, res) => {
  try {
    const { amount, category, date } = req.body;

    const expense = new Expense({
      amount,
      category,
      userId: req.userId,
      createdAt: date ? new Date(date) : new Date(),
    });

    await expense.save();
    res.json({ message: "Expense added successfully" });
  } catch (err) {
    console.error("ADD EXPENSE ERROR:", err.message);
    res.status(500).json({ error: "Failed to add expense" });
  }
});

/* ---------------- GET ALL EXPENSES ---------------- */
// GET /expenses
router.get("/", auth, async (req, res) => {
  try {
    const expenses = await Expense.find({ userId: req.userId }).sort({
      createdAt: -1,
    });
    res.json(expenses);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch expenses" });
  }
});

/* ---------------- MONTH SUMMARY ---------------- */
// GET /expenses/summary?month=1&year=2026
router.get("/summary", auth, async (req, res) => {
  try {
    const month = parseInt(req.query.month);
    const year = parseInt(req.query.year);

    if (!month || !year) {
      return res.status(400).json({ error: "Month and year required" });
    }

    const start = new Date(year, month - 1, 1, 0, 0, 0);
    const end = new Date(year, month, 0, 23, 59, 59);

    const match = {
      userId: new mongoose.Types.ObjectId(req.userId),
      createdAt: { $gte: start, $lte: end },
    };

    const totalResult = await Expense.aggregate([
      { $match: match },
      { $group: { _id: null, totalSpent: { $sum: "$amount" } } },
    ]);

    const categoryResult = await Expense.aggregate([
      { $match: match },
      {
        $group: {
          _id: "$category",
          total: { $sum: "$amount" },
        },
      },
    ]);

    const categoryTotals = {};
    categoryResult.forEach((c) => {
      categoryTotals[c._id] = c.total;
    });

    res.json({
      totalSpent: totalResult[0]?.totalSpent || 0,
      categoryTotals,
    });
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch summary" });
  }
});

/* ---------------- DAY SUMMARY ---------------- */
// GET /expenses/summary/day?date=2026-01-04
router.get("/summary/day", auth, async (req, res) => {
  try {
    const date = new Date(req.query.date);

    const start = new Date(date);
    start.setHours(0, 0, 0, 0);

    const end = new Date(date);
    end.setHours(23, 59, 59, 999);

    const match = {
      userId: new mongoose.Types.ObjectId(req.userId),
      createdAt: { $gte: start, $lte: end },
    };

    const totalResult = await Expense.aggregate([
      { $match: match },
      { $group: { _id: null, totalSpent: { $sum: "$amount" } } },
    ]);

    const categoryResult = await Expense.aggregate([
      { $match: match },
      {
        $group: {
          _id: "$category",
          total: { $sum: "$amount" },
        },
      },
    ]);

    const categoryTotals = {};
    categoryResult.forEach((c) => {
      categoryTotals[c._id] = c.total;
    });

    res.json({
      totalSpent: totalResult[0]?.totalSpent || 0,
      categoryTotals,
    });
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch day summary" });
  }
});

/* ---------------- MONTHLY HISTORY ---------------- */
// GET /expenses/monthly-summary
router.get("/monthly-summary", auth, async (req, res) => {
  try {
    const summary = await Expense.aggregate([
      {
        $match: {
          userId: new mongoose.Types.ObjectId(req.userId),
        },
      },
      {
        $group: {
          _id: {
            year: { $year: "$createdAt" },
            month: { $month: "$createdAt" },
          },
          total: { $sum: "$amount" },
        },
      },
      { $sort: { "_id.year": 1, "_id.month": 1 } },
      {
        $project: {
          _id: 0,
          year: "$_id.year",
          month: "$_id.month",
          total: 1,
        },
      },
    ]);

    res.json(summary);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch monthly summary" });
  }
});

/* ---------------- NEXT MONTH PREDICTION ---------------- */
// GET /expenses/predict-next-month
router.get("/predict-next-month", auth, async (req, res) => {
  try {
    const history = await Expense.aggregate([
      {
        $match: {
          userId: new mongoose.Types.ObjectId(req.userId),
        },
      },
      {
        $group: {
          _id: {
            year: { $year: "$createdAt" },
            month: { $month: "$createdAt" },
          },
          total: { $sum: "$amount" },
        },
      },
      { $sort: { "_id.year": 1, "_id.month": 1 } },
    ]);

    if (history.length === 0) {
      return res.json({ predicted: 0 });
    }

    const recent = history.slice(-3);
    const avg = recent.reduce((sum, m) => sum + m.total, 0) / recent.length;

    res.json({ predicted: Math.round(avg) });
  } catch (err) {
    res.status(500).json({ error: "Prediction failed" });
  }
});
// DEBUG ONLY — REMOVE AFTER
router.get("/debug/user-expenses", auth, async (req, res) => {
  const expenses = await Expense.find({ userId: req.userId });
  res.json({
    userIdFromToken: req.userId,
    count: expenses.length,
    expenses,
  });
});

module.exports = router;
