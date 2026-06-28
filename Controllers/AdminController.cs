using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using ExpenseTrackerAPI.Data;
using System.Security.Claims;

namespace ExpenseTrackerAPI.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class AdminController : ControllerBase
{
    private readonly AppDbContext _context;

    public AdminController(AppDbContext context)
    {
        _context = context;
    }


    [HttpPost("clear-my-data")]
    public async Task<IActionResult> ClearMyData()
    {
        var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdString) || !int.TryParse(userIdString, out int userId))
        {
            return Unauthorized("Invalid user context");
        }

        // Delete user's expenses
        var userExpenses = _context.Expenses.Where(e => e.UserId == userId);
        _context.Expenses.RemoveRange(userExpenses);

        // Delete user's receipts
        var userReceipts = _context.Receipts.Where(r => r.UserId == userId);
        _context.Receipts.RemoveRange(userReceipts);

        await _context.SaveChangesAsync();
        return Ok(new { success = true, message = "All your data has been successfully cleared." });
    }}
