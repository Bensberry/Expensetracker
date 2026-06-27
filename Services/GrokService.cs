using System.Net.Http;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;

namespace ExpenseTrackerAPI.Services;

public class GroqService
{
    private readonly IConfiguration _config;
    private readonly HttpClient _client;

    public GroqService(IConfiguration config)
    {
        _config = config;
        _client = new HttpClient();
    }

    public async Task<string> ProcessOcrTextAsync(string ocrText)
    {
        var apiKey = _config["Groq:ApiKey"];
        var model = _config["Groq:Model"] ?? "llama-3.1-8b-instant";

        if (string.IsNullOrWhiteSpace(apiKey) || apiKey.Contains("YOUR"))
        {
            throw new InvalidOperationException("Groq API Key is not configured in appsettings.json.");
        }

        var requestBody = new
        {
            model = model,
            messages = new[]
            {
                new
                {
                    role = "system",
                    content = "Extract purchased items and their actual prices from OCR receipt text. " +
                              "IMPORTANT INSTRUCTIONS:\n" +
                              "1. Distinguish between quantity/count (e.g., '1 x', 'qty 2', '1 pcs') and monetary prices. NEVER use the quantity count as the price.\n" +
                              "2. Extracted amount MUST be the total actual price for the item (e.g. in '1 x item = ₹240', the amount is 240, NOT 1).\n" +
                              "3. Support Indian currency formats (e.g., '₹240', 'Rs. 240', 'Rs240', '240.00'). Ignore currency symbols in the numerical amount output.\n" +
                              "4. Prefer values associated with currency symbols (₹, Rs) or labeled with 'price', 'amount', 'total'. Use heuristics to pick the monetary price over standalone integers.\n" +
                              "5. Return ONLY a valid JSON array. Each item must have: title (string), amount (number), category (Food, Transport, Shopping, Utilities, Entertainment).\n" +
                              "6. Do not include any markdown fences, preambles, or explanations."
                },
                new
                {
                    role = "user",
                    content = string.IsNullOrWhiteSpace(ocrText) ? "empty receipt" : ocrText
                }
            },
            temperature = 0.0
        };

        var request = new HttpRequestMessage(
            HttpMethod.Post,
            "https://api.groq.com/openai/v1/chat/completions"
        );

        request.Headers.Add("Authorization", $"Bearer {apiKey}");

        var json = JsonSerializer.Serialize(requestBody);
        request.Content = new StringContent(json, Encoding.UTF8, "application/json");

        var response = await _client.SendAsync(request);

        var responseString = await response.Content.ReadAsStringAsync();

        if (!response.IsSuccessStatusCode)
        {
            throw new Exception($"Groq API failed: {response.StatusCode} - {responseString}");
        }

        using var doc = JsonDocument.Parse(responseString);

        var content = doc.RootElement
            .GetProperty("choices")[0]
            .GetProperty("message")
            .GetProperty("content")
            .GetString();

        if (string.IsNullOrWhiteSpace(content))
            return "[]";

        // Clean markdown if AI wraps response
        var cleaned = content.Trim();

        if (cleaned.StartsWith("```"))
            cleaned = cleaned.Replace("```json", "").Replace("```", "").Trim();

        return cleaned;
    }
}