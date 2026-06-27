using Microsoft.AspNetCore.Mvc;
using ExpenseTrackerAPI.Data;
using ExpenseTrackerAPI.Models;
using ExpenseTrackerAPI.Services;

namespace ExpenseTrackerAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
	private readonly AppDbContext _context;
	private readonly JwtService _jwt;

	public AuthController(AppDbContext context, JwtService jwt)
	{
		_context = context;
		_jwt = jwt;
	}

	// REGISTER
	[HttpPost("register")]
	public async Task<IActionResult> Register(User user)
	{
		_context.Users.Add(user);
		await _context.SaveChangesAsync();
		return Ok("User registered successfully");
	}

	// LOGIN
	[HttpPost("login")]
	public IActionResult Login(User request)
	{
		var user = _context.Users.FirstOrDefault(u =>
			u.Username == request.Username &&
			u.PasswordHash == request.PasswordHash
		);

		if (user == null)
			return Unauthorized("Invalid credentials");

		var token = _jwt.GenerateToken(user);

		return Ok(new { token });
	}
}