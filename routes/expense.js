const express = require("express");
const router = express.Router();
const Expense = require("../models/expense");
const auth = require("../middleware/auth"); // ADD THIS

// POST /advice - ADD AUTH MIDDLEWARE

// POST /advice - AI-powered spending advice
router.post("/", auth, async (req, res) => {
  try {
    console.log("🔑 User ID:", req.userId);

    const expenses = await Expense.find({ userId: req.userId })
      .sort({ createdAt: -1 })
      .limit(20);

    console.log("📊 Expenses found:", expenses.length);

    if (!expenses || expenses.length === 0) {
      return res.json({
        advice: "Start tracking your expenses to get personalized advice!",
      });
    }

    const expenseSummary = expenses
      .map((e) => `₹${e.amount} - ${e.category}`)
      .join("\n");

    const prompt = `
You are a personal finance coach.
Give short, practical advice based on the user's spending patterns.

Recent expenses:
${expenseSummary}

Provide 2-3 actionable tips to improve spending habits.
Keep it concise and friendly.
`;

    console.log("🤖 Calling Gemini API...");
    console.log("🔑 API Key exists:", !!process.env.GEMINI_API_KEY);

    const aiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
        }),
      }
    );

    console.log("📡 Gemini response status:", aiResponse.status);

    const aiData = await aiResponse.json();
    console.log("📄 Gemini response:", JSON.stringify(aiData, null, 2));

    if (!aiResponse.ok) {
      console.error("❌ Gemini API error:", aiData);
      throw new Error(`Gemini API error: ${aiResponse.status}`);
    }

    const advice =
      aiData?.candidates?.[0]?.content?.parts?.[0]?.text ??
      "Track expenses consistently to get better insights.";

    console.log("✅ Final advice:", advice);

    res.json({ advice });
  } catch (error) {
    console.error("❌ AI advice error:", error);
    res
      .status(500)
      .json({ error: "Advice generation failed", details: error.message });
  }
});

// POST /advice/investment
router.post("/investment", async (req, res) => {
  try {
    const { riskLevel } = req.body;

    // fetch expenses
    const expenses = await Expense.find();
    const totalSpent = expenses.reduce((sum, e) => sum + Number(e.amount), 0);

    let advice = "";

    if (riskLevel === "Low") {
      advice = `
You have a low risk appetite.
Recommended options:
• Fixed Deposits
• Debt mutual funds
• Recurring deposits
• Emergency fund (6 months expenses)
Avoid volatile investments.
`;
    } else if (riskLevel === "Medium") {
      advice = `
You have a moderate risk appetite.
Recommended options:
• SIPs in index funds
• Balanced mutual funds
• Some exposure to ETFs
Maintain diversification.
`;
    } else if (riskLevel === "High") {
      advice = `
You have a high risk appetite.
Recommended options:
• Equity mutual funds
• Index ETFs
• Long-term SIPs
Ensure emergency fund before investing.
`;
    }

    res.json({
      investmentAdvice: advice.trim(),
      totalSpent,
    });
  } catch (err) {
    res.status(500).json({ error: "Investment advice failed" });
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
