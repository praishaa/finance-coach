exports.getAdvice = (req, res) => {
  const { totalSpent } = req.body;

  if (!totalSpent) {
    return res.status(400).json({ message: "totalSpent is required" });
  }

  let advice = "Your spending looks balanced.";

  if (totalSpent > 5000) {
    advice = "You are spending a lot this month. Consider tracking categories.";
  }

  res.json({
    totalSpent,
    advice,
  });
};
