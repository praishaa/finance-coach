const express = require("express");
const router = express.Router();
const Expense = require("../models/expense");
const auth = require("../middleware/auth");

// POST /advice
router.post("/", auth, async (req, res) => {
  try {
    const expenses = await Expense.find({ userId: req.userId })
      .sort({ createdAt: -1 })
      .limit(20);

    if (expenses.length === 0) {
      return res.json({
        advice: "Start tracking your expenses to get personalized advice!",
      });
    }

    const expenseText = expenses
      .map((e) => `₹${e.amount} - ${e.category}`)
      .join("\n");

    const prompt = `
You are a personal finance coach.
Give short, practical advice.

Recent expenses:
${expenseText}

Provide 2-3 actionable tips.
`;

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [
            {
              role: "user",
              parts: [{ text: prompt }],
            },
          ],
          generationConfig: {
            temperature: 0.9,
            maxOutputTokens: 200,
          },
        }),
      }
    );

    const data = await response.json();

    const advice =
      data?.candidates?.[0]?.content?.parts?.[0]?.text ||
      "AI response unavailable.";

    res.json({ advice });
  } catch (err) {
    console.error("Advice error:", err);
    res.status(500).json({ error: "Advice generation failed" });
  }
});

// POST /advice/investment
router.post("/investment", auth, async (req, res) => {
  try {
    const { riskLevel } = req.body;

    let advice = "";

    if (riskLevel === "Low") {
      advice = "FDs, debt funds, RDs, and emergency fund.";
    } else if (riskLevel === "Medium") {
      advice = "Index fund SIPs, balanced funds, ETFs.";
    } else {
      advice = "Equity funds, ETFs, long-term SIPs.";
    }

    res.json({ investmentAdvice: advice });
  } catch (err) {
    res.status(500).json({ error: "Investment advice failed" });
  }
});

module.exports = router;
