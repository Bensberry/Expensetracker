using System;

namespace ExpenseTrackerAPI.Models;

public class Receipt
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public User? User { get; set; }
    public string ImagePath { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
