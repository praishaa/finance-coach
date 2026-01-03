const express = require("express");
const router = express.Router();
const Expense = require("../models/expense");
const mongoose = require("mongoose"); // ADD THIS
const auth = require("../middleware/auth"); // Fix the path

// POST /expenses - REQUIRES AUTH
router.post("/", auth, async (req, res) => {
  try {
    const { amount, category, date } = req.body;

    const expense = new Expense({
      amount,
      category,
      userId: req.userId,
      createdAt: date ? new Date(date) : new Date(), // 🔥 THIS IS THE REQUIRED BACKEND THING
    });

    await expense.save();
    res.json({ message: "expense added" });
  } catch (err) {
    console.error("ADD EXPENSE ERROR:", err.message);
    res.status(500).json({ error: "Failed to add expense" });
  }
});

// GET /expenses - REQUIRES AUTH
router.get("/", auth, async (req, res) => {
  const expenses = await Expense.find({ userId: req.userId }).sort({
    createdAt: -1,
  });
  res.json(expenses);
});

// DELETE THE FIRST /summary ROUTE - KEEP ONLY THIS ONE

// Monthly summary - ADD AUTH
router.get("/summary", auth, async (req, res) => {
  try {
    const month = parseInt(req.query.month);
    const year = parseInt(req.query.year);

    if (!month || !year) {
      return res.status(400).json({ error: "Month and year required" });
    }

    // 🔥 START OF MONTH
    const start = new Date(year, month - 1, 1);
    start.setHours(0, 0, 0, 0);

    // 🔥 END OF MONTH
    const end = new Date(year, month, 0);
    end.setHours(23, 59, 59, 999);

    const matchStage = {
      userId: new mongoose.Types.ObjectId(req.userId),
      createdAt: { $gte: start, $lte: end },
    };

    // TOTAL SPENT (MONTH)
    const totalResult = await Expense.aggregate([
      { $match: matchStage },
      {
        $group: {
          _id: null,
          totalSpent: { $sum: "$amount" },
        },
      },
    ]);

    // CATEGORY TOTALS (MONTH)
    const categoryResult = await Expense.aggregate([
      { $match: matchStage },
      {
        $group: {
          _id: "$category",
          total: { $sum: "$amount" },
        },
      },
      { $sort: { total: -1 } },
    ]);

    const categoryTotals = {};
    categoryResult.forEach((item) => {
      categoryTotals[item._id] = item.total;
    });

    res.json({
      totalSpent: totalResult[0]?.totalSpent || 0,
      categoryTotals,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch summary" });
  }
});

// Predict next month - ADD AUTH
router.get("/predict-next-month", auth, async (req, res) => {
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
            month: { $month: "$createdAt" },
            year: { $year: "$createdAt" },
          },
          total: { $sum: { $toDouble: "$amount" } },
        },
      },
      { $sort: { "_id.year": 1, "_id.month": 1 } },
    ]);

    if (summary.length === 0) {
      return res.json({ predicted: 0 });
    }

    const recent = summary.slice(-3);
    const avg = recent.reduce((sum, m) => sum + m.total, 0) / recent.length;

    res.json({
      predicted: Math.round(avg),
    });
  } catch (err) {
    res.status(500).json({ error: "Prediction failed" });
  }
});
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
            month: { $month: "$createdAt" },
            year: { $year: "$createdAt" },
          },
          total: { $sum: "$amount" },
        },
      },
      { $sort: { "_id.year": 1, "_id.month": 1 } },
      {
        $project: {
          _id: 0,
          month: "$_id.month",
          year: "$_id.year",
          total: 1,
        },
      },
    ]);

    res.json(summary);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch monthly summary" });
  }
});
router.get("/summary/day", auth, async (req, res) => {
  try {
    const date = new Date(req.query.date);

    // Start of the day (00:00:00)
    const start = new Date(date);
    start.setHours(0, 0, 0, 0);

    // End of the day (23:59:59)
    const end = new Date(date);
    end.setHours(23, 59, 59, 999);

    const matchStage = {
      userId: new mongoose.Types.ObjectId(req.userId),
      createdAt: { $gte: start, $lte: end },
    };

    // TOTAL SPENT FOR THE DAY
    const totalResult = await Expense.aggregate([
      { $match: matchStage },
      {
        $group: {
          _id: null,
          totalSpent: { $sum: "$amount" },
        },
      },
    ]);

    // CATEGORY-WISE TOTALS FOR THE DAY
    const categoryResult = await Expense.aggregate([
      { $match: matchStage },
      {
        $group: {
          _id: "$category",
          total: { $sum: "$amount" },
        },
      },
    ]);

    const categoryTotals = {};
    categoryResult.forEach((item) => {
      categoryTotals[item._id] = item.total;
    });

    res.json({
      totalSpent: totalResult[0]?.totalSpent || 0,
      categoryTotals,
    });
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch day summary" });
  }
});

module.exports = router;
