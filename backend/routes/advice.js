const express = require("express");
const router = express.Router();
const Expense = require("../models/expense");

/* ---------------- POST: Add expense + AI advice ---------------- */
router.post("/", async (req, res) => {
  try {
    const { amount, category } = req.body;

    if (!amount || !category) {
      return res.status(400).json({ message: "amount and category required" });
    }

    // 1️⃣ Save expense
    await new Expense({ amount, category }).save();

    // 2️⃣ Fetch all expenses
    const expenses = await Expense.find();

    // 3️⃣ Build prompt
    const prompt = `
You are a personal finance coach.
Analyze the expenses and give short, practical advice.

Expenses:
${expenses.map((e) => `₹${e.amount} - ${e.category}`).join("\n")}
`;

    // 4️⃣ Call Gemini (REST v1)
    const response = await fetch(
      "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=" +
        process.env.GEMINI_API_KEY,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
        }),
      }
    );

    const data = await response.json();

    const advice =
      data?.candidates?.[0]?.content?.parts?.[0]?.text ||
      "You're doing okay. Try tracking expenses consistently.";

    // 5️⃣ Send response
    res.json({ advice });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Server error" });
  }
});

/* ---------------- GET: Fetch expense history ---------------- */
router.get("/", async (req, res) => {
  try {
    const expenses = await Expense.find().sort({ createdAt: -1 });
    res.json(expenses);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
