require("dotenv").config();

async function test() {
  const response = await fetch(
    "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=" +
      process.env.GEMINI_API_KEY,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [
          {
            parts: [{ text: "Say hello in one line" }],
          },
        ],
      }),
    }
  );

  const data = await response.json();

  const text =
    data?.candidates?.[0]?.content?.parts?.[0]?.text ||
    JSON.stringify(data, null, 2);

  console.log(text);
}

test();
