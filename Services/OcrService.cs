using Tesseract;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;
using System.Text.RegularExpressions;

namespace ExpenseTrackerAPI.Services;

public class OcrService
{
	public OcrResult ExtractExpenses(string imagePath)
	{
		var processedPath = PreprocessImage(imagePath);

		var tessPath = Path.Combine(Directory.GetCurrentDirectory(), "tessdata");

		using var engine = new TesseractEngine(tessPath, "eng", EngineMode.Default);

		engine.SetVariable(
			"tessedit_char_whitelist",
			"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz₹$.:/- "
		);

		using var img = Pix.LoadFromFile(processedPath);
		using var page = engine.Process(img, PageSegMode.SingleBlock);

		var text = page.GetText();

		return ParseExpenses(text);
	}

	private OcrResult ParseExpenses(string text)
	{
		var lines = text.Split('\n', StringSplitOptions.RemoveEmptyEntries);

		var expenses = new List<OcrItem>();
		decimal? total = null;

		foreach (var line in lines)
		{
			var cleaned = line.Trim();

			// match amount (last number in line)
			var match = Regex.Match(cleaned, @"(\d+(\.\d{1,2})?)$");

			if (!match.Success) continue;

			var amount = decimal.Parse(match.Groups[1].Value);

			if (cleaned.ToLower().Contains("total"))
			{
				total = amount;
				continue;
			}

			var item = cleaned.Substring(0, match.Index).Trim();

			if (string.IsNullOrWhiteSpace(item))
				continue;

			expenses.Add(new OcrItem
			{
				Item = item,
				Amount = amount
			});
		}

		return new OcrResult
		{
			Expenses = expenses,
			Total = total
		};
	}

	private string PreprocessImage(string path)
	{
		var outputPath = Path.Combine(
			Path.GetDirectoryName(path)!,
			"processed_" + Path.GetFileName(path)
		);

		using var image = Image.Load(path);

		image.Mutate(x =>
		{
			x.Grayscale();
			x.Contrast(2.0f);
			x.Resize(image.Width * 3, image.Height * 3);
		});

		image.Save(outputPath);

		return outputPath;
	}
}

public class OcrResult
{
	public List<OcrItem> Expenses { get; set; } = new();
	public decimal? Total { get; set; }
}

public class OcrItem
{
	public string Item { get; set; } = string.Empty;
	public decimal Amount { get; set; }
}