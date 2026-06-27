namespace ExpenseTrackerAPI.Models;

public class Expense
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string Category { get; set; } = string.Empty;
    public DateTime Date { get; set; }

    public int UserId { get; set; }
    public User? User { get; set; }

    public int? ReceiptId { get; set; }
    public Receipt? Receipt { get; set; }
}