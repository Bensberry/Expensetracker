using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using ExpenseTrackerAPI.Services;
using ExpenseTrackerAPI.Data;
using ExpenseTrackerAPI.Models;
using System.Security.Claims;
using System;
using System.IO;

namespace ExpenseTrackerAPI.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class ReceiptController : ControllerBase
{
	private readonly OcrService _ocr;
	private readonly AppDbContext _context;
	private readonly GroqService _groqService;

	public ReceiptController(OcrService ocr, AppDbContext context, GroqService groqService)
	{
		_ocr = ocr;
		_context = context;
		_groqService = groqService;
	}

	[HttpPost("upload")]
	public async Task<IActionResult> Upload(IFormFile file)
	{
		if (file == null || file.Length == 0)
			return BadRequest("No file uploaded");

		// Get current user ID
		var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
		if (string.IsNullOrEmpty(userIdString) || !int.TryParse(userIdString, out int userId))
		{
			return Unauthorized("Invalid user context");
		}

		var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "uploads");

		if (!Directory.Exists(uploadsFolder))
			Directory.CreateDirectory(uploadsFolder);

		var filePath = Path.Combine(uploadsFolder, file.FileName);

		using (var stream = new FileStream(filePath, FileMode.Create))
		{
			await file.CopyToAsync(stream);
		}

		// Perform OCR extraction
		var ocrResult = _ocr.ExtractExpenses(filePath);

		// Calculate total if not extracted
		decimal total = ocrResult.Total ?? ocrResult.Expenses.Sum(e => e.Amount);

		// Save Receipt metadata to database
		var receipt = new Receipt
		{
			UserId = userId,
			ImagePath = filePath,
			TotalAmount = total,
			CreatedAt = DateTime.UtcNow
		};

		_context.Receipts.Add(receipt);
		await _context.SaveChangesAsync();

		// Save each OCR item as an individual Expense record
		var savedExpenses = new List<Expense>();
		foreach (var item in ocrResult.Expenses)
		{
			var expense = new Expense
			{
				UserId = userId,
				Title = item.Item,
				Amount = item.Amount,
				Category = "Receipt Import",
				Date = DateTime.UtcNow,
				ReceiptId = receipt.Id
			};

			_context.Expenses.Add(expense);
			savedExpenses.Add(expense);
		}

		await _context.SaveChangesAsync();

		return Ok(new
		{
			Message = "Receipt uploaded and expenses extracted successfully",
			Receipt = receipt,
			Expenses = savedExpenses
		});
	}

	[AllowAnonymous]
	[HttpPost("process-text")]
	public async Task<IActionResult> ProcessText([FromBody] ProcessTextRequest request)
	{
		if (request == null || string.IsNullOrWhiteSpace(request.OcrText))
			return BadRequest("OCR text is empty");

		try
		{
			var jsonResult = await _groqService.ProcessOcrTextAsync(request.OcrText);
			return Content(jsonResult, "application/json");
		}
		catch (Exception ex)
		{
			return StatusCode(500, $"AI extraction failed: {ex.Message}");
		}
	}
}

public class ProcessTextRequest
{
	public string OcrText { get; set; } = string.Empty;
}