require("dotenv").config();
const express = require("express");
const cors = require("cors");

const connectDB = require("./config/db");
const adviceRoutes = require("./routes/advice");
const expenseRoutes = require("./routes/expense");
const authRoutes = require("./routes/auth");

const app = express();

connectDB();

app.use(cors());
app.use(express.json());

app.use("/expenses", expenseRoutes);
app.use("/advice", adviceRoutes);
app.use("/auth", authRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
